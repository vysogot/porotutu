# frozen_string_literal: true

require_relative '../../test_helper'

module Porotutu
  module Users
    class LoginHandlerTest < Tests::TestCase
      def setup
        super
        @email = "login-handler-#{SecureRandom.hex(4)}@example.com"
        @password = 'hunter22'
        UserFactory.create(
          email: @email,
          password: @password
        )
      end

      def test_returns_user_in_locals_on_valid_credentials
        locals = LoginHandler.call(params: { email: @email, password: @password })

        assert_kind_of UserMapper, locals[:user]
        assert_equal @email, locals[:user].email
      end

      def test_raises_invalid_credentials_when_password_wrong
        assert_raises(InvalidCredentials) do
          LoginHandler.call(params: { email: @email, password: 'nope' })
        end
      end
    end
  end
end
