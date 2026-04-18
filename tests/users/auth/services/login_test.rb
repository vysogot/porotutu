# frozen_string_literal: true

require_relative '../../../test_helper'

module Users
  module Auth
    module Services
      class LoginTest < ::Tests::TestCase
        def setup
          super
          @email = "login-#{SecureRandom.hex(4)}@example.com"
          @password = 'hunter22'
          ::Users::Crud::Services::Create.call(
            params: { email: @email, password: @password }
          )
        end

        def test_returns_user_mapper_on_valid_credentials
          user = ::Users::Auth::Services::Login.call(
            params: { email: @email, password: @password }
          )

          assert_kind_of ::Mappers::User, user
          assert_equal @email, user.email
          refute_respond_to user, :password_digest
        end

        def test_raises_invalid_credentials_when_email_unknown
          assert_raises(::Users::Auth::Errors::InvalidCredentials) do
            ::Users::Auth::Services::Login.call(
              params: { email: 'nobody@example.com', password: @password }
            )
          end
        end

        def test_raises_invalid_credentials_when_password_wrong
          assert_raises(::Users::Auth::Errors::InvalidCredentials) do
            ::Users::Auth::Services::Login.call(
              params: { email: @email, password: 'wrong-password' }
            )
          end
        end
      end
    end
  end
end
