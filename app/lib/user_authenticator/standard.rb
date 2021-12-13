# frozen_string_literal: true

class UserAuthenticator::Standard < UserAuthenticator
  class AuthenticationError < StandardError; end

  def initialize(login, password); end
end
