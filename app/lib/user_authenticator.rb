# frozen_string_literal: true

class UserAuthenticator
  attr_reader :authenticator

  def initialize(code: nil, login: nil, password: nil)
    @authenticator = if code.present?
                       Oauth.new(code)
                     else
                       Standard.new(login, password)
                     end
  end

  def perform
    authenticator.perform
  end

  def access_token
    authenticator.access_token
  end

  def user
    authenticator.user
  end
end
