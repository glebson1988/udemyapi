# frozen_string_literal: true

FactoryBot.define do
  factory :access_token do
    token { 'SomeString' }
    user
  end
end
