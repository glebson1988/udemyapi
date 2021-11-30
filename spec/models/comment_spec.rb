# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe '#validations' do
    it 'should have a valid factory' do
      expect(build(:comment)).to be_valid
    end

    it 'should test presence of attributes' do
      comment = described_class.new
      expect(comment).not_to be_valid
      expect(comment.errors.full_messages).to eq(['Article must exist', 'User must exist', "Content can't be blank"])
    end
  end
end
