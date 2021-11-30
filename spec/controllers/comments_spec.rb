# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let(:article) { create :article }

  describe 'GET #index' do
    subject { get :index, params: { article_id: article.id } }

    it 'renders a successful response' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'should return only comments belonging to article' do
      comment = create :comment, article: article
      create :comment
      subject
      expect(json_data.length).to eq(1)
      expect(json_data.first[:id]).to eq(comment.id.to_s)
    end

    it 'should have proper json body' do
      comment = create :comment, article: article
      subject
      expect(json_data.first[:attributes][:content]).to eq comment.content
    end

    it 'should have related objects information in the response' do
      user = create :user
      create :comment, article: article, user: user
      subject
      relationships = json_data.first[:relationships]
      expect(relationships[:user][:data][:id]).to eq(user.id.to_s)
      expect(relationships[:article][:data][:id]).to eq(article.id.to_s)
    end

    context 'when paginated' do
      before { create_list(:comment, 3, article: article) }

      subject { get :index, params: { page: { number: 2, size: 1 }, article_id: article.id } }

      it 'paginates results' do
        subject
        expect(json_data.length).to eq(1)
      end

      it 'contains pagination links in the response' do
        subject
        expect(json[:links].length).to eq(5)
        expect(json[:links].keys).to contain_exactly(:first, :prev, :next, :last, :self)
      end
    end
  end

  describe 'POST #create' do
    subject { post :create, params: { article_id: article.id } }

    context 'unauthorized' do
      context 'when no authorization header provided' do
        it_behaves_like 'forbidden requests'
      end

      context 'when invalid authorization header provided' do
        before { request.headers['authorization'] = 'Invalid token' }

        it_behaves_like 'forbidden requests'
      end
    end

    context 'authorized' do
      let(:valid_attributes) { { data: { attributes: { content: 'My comment for article' } } } }
      let(:invalid_attributes) { { data: { attributes: { content: '' } } } }
      let(:user) { create :user }
      let(:access_token) { user.create_access_token }

      before { request.headers['authorization'] = "Bearer #{access_token.token}" }

      context 'with invalid parameters provided' do
        subject { post :create, params: invalid_attributes.merge(article_id: article.id) }

        it 'returns 422 status code' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not create a new comment' do
          subject
          expect { subject }.not_to change { article.comments.count }
        end

        it 'renders a JSON response with errors for the new comment' do
          subject
          expect(json[:content]).to include("can't be blank")
        end
      end

      context 'with valid parameters' do
        subject { post :create, params: valid_attributes.merge(article_id: article.id) }

        it 'returns 201 status code' do
          subject
          expect(response).to have_http_status(:created)
        end

        it 'creates a new comment' do
          expect { subject }.to change { article.comments.count }.by(1)
        end

        it 'renders a JSON response with the new comment' do
          subject
          expect(json_data[:attributes][:content]).to eq('My comment for article')
        end
      end
    end
  end
end
