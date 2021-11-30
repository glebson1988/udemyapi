# frozen_string_literal: true

class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :login, :name, :url, :avatar_url, :provider
end
