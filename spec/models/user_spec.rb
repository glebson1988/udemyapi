require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#validations' do
    it 'should has valid factory' do
      user = build :user
      expect(user).to be_valid
    end

    it 'should validates presence of attributes' do
      user = build :user, login: nil, provider: nil
      expect(user).not_to be_valid
      expect(user.errors.messages[:login]).to include("can't be blank")
      expect(user.errors.messages[:provider]).to include("can't be blank")
    end

    it 'should validates login uniqueness' do
      user = create :user
      other_user = build :user, login: user.login
      expect(other_user).not_to be_valid
      other_user.login = 'newlogin'
      expect(other_user).to be_valid
    end
  end
end
