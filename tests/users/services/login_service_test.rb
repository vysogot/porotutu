# frozen_string_literal: true

require_relative '../../test_helper'

module Porotutu
  module Users
    class LoginServiceTest < Tests::TestCase
      def setup
        super
        @email = "login-#{SecureRandom.hex(4)}@example.com"
        @password = 'hunter22'
        UserFactory.create(
          email: @email,
          password: @password
        )
      end

      def test_returns_user_mapper_on_valid_credentials
        user = LoginService.call(params: { email: @email, password: @password })

        assert_kind_of UserMapper, user
        assert_equal @email, user.email
        refute_respond_to user, :password_digest
      end

      def test_raises_invalid_credentials_when_email_unknown
        assert_raises(InvalidCredentials) do
          LoginService.call(params: { email: 'nobody@example.com', password: @password })
        end
      end

      def test_raises_invalid_credentials_when_password_wrong
        assert_raises(InvalidCredentials) do
          LoginService.call(params: { email: @email, password: 'wrong-password' })
        end
      end
    end
  end
end
