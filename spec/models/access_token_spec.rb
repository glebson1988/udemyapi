# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccessToken, type: :model do
  describe '#validations' do
    it 'should has valid factory' do
      token = build :access_token
      expect(token).to be_valid
    end

    it 'should validates presence of user' do
      access_token = build :access_token, user: nil
      expect(access_token).not_to be_valid
      expect(access_token.errors.messages[:user]).to include('must exist')
    end

    it 'should validates token uniqueness' do
      access_token = create :access_token
      other_token = build :access_token, token: access_token.token
      expect(other_token).not_to be_valid
      other_token.token = 'newtoken'
      expect(other_token).to be_valid
    end
  end

  describe '#new' do
    it 'should has a token present after initialize' do
      expect(AccessToken.new.token).to be_present
    end

    it 'should generates uniq token' do
      user = create :user
      expect { user.create_access_token }.to change { AccessToken.count }.by(1)
      expect(user.build_access_token).to be_valid
    end
  end
end
