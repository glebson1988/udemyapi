# frozen_string_literal: true

class CommentSerializer
  include JSONAPI::Serializer
  attributes :id, :content
  has_one :user
  has_one :article
end
