# frozen_string_literal: true

FactoryBot.define do
  factory :article do
    sequence(:title) { |n| "Some title#{n}" }
    content { 'Sample content' }
    sequence(:slug) { |n| "slug#{n}" }
  end
end
