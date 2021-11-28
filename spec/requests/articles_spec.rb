# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ArticlesController, type: :controller do
  describe 'GET #index' do
    subject { get :index }

    it 'returns a success response' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'returns a proper JSON' do
      article = create :article
      subject
      expect(json_data.length).to eq(1)
      expected = json_data.first
      aggregate_failures do
        expect(expected[:id]).to eq(article.id.to_s)
        expect(expected[:type]).to eq('article')
        expect(expected[:attributes]).to eq(
          title: article.title,
          content: article.content,
          slug: article.slug
        )
      end
    end

    it 'returns articles in the proper order' do
      older_article = create(:article, created_at: 1.hour.ago)
      recent_article = create(:article)
      subject
      ids = json_data.map { |item| item[:id].to_i }

      expect(ids).to eq([recent_article.id, older_article.id])
    end

    context 'when paginated' do
      subject { get :index, params: { page: { number: 2, size: 1 } } }

      before { create_list(:article, 3) }

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

  describe 'GET #show' do
    let(:article) { create :article }

    subject { get :show, params: { id: article.id } }

    before { subject }

    it 'returns a success response' do
      expect(response).to have_http_status :ok
    end

    it 'returns a proper JSON' do
      aggregate_failures do
        expect(json_data[:id]).to eq(article.id.to_s)
        expect(json_data[:type]).to eq('article')
        expect(json_data[:attributes]).to eq(
          title: article.title,
          content: article.content,
          slug: article.slug
        )
      end
    end
  end

  describe 'POST #create' do
    subject { post :create }

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
      let(:access_token) { create :access_token }
      before { request.headers['authorization'] = "Bearer #{access_token.token}" }

      context 'when invalid parameters provided' do
        let(:invalid_attributes) do
          {
            data: {
              attributes: {
                title: '',
                content: '',
                slug: ''
              }
            }
          }
        end

        subject { post :create, params: invalid_attributes }

        it 'should return 422 status code' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should return proper errors' do
          subject
          expect(JSON.parse(response.body)).to include("Title can't be blank")
          expect(JSON.parse(response.body)).to include("Content can't be blank")
          expect(JSON.parse(response.body)).to include("Slug can't be blank")
        end
      end
    end

    context 'when success request sent' do
      let(:access_token) { create :access_token }
      before { request.headers['authorization'] = "Bearer #{access_token.token}" }

      let(:valid_attributes) do
        {
          data: {
            attributes: {
              title: 'Awesome article',
              content: 'Super content',
              slug: 'awesome-article'
            }
          }
        }
      end

      subject { post :create, params: valid_attributes }

      it 'should have 201 status code' do
        subject
        expect(response).to have_http_status(:created)
      end

      it 'should have proper json body' do
        subject
        expect(json_data[:attributes]).to include(valid_attributes[:data][:attributes])
      end

      it 'should create the article' do
        expect { subject }.to change { Article.count }.by(1)
      end
    end
  end
end
