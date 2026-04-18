# frozen_string_literal: true

require_relative '../../../test_helper'

module Users
  module Crud
    module Services
      class CreateTest < ::Tests::TestCase
        def test_creates_a_user_and_returns_a_mapper
          user = Users::Crud::Services::Create.call(
            params: { email: "alice-#{SecureRandom.hex(4)}@example.com", password: 'hunter22' }
          )

          assert_kind_of ::Mappers::User, user
          assert_match(/@example\.com\z/, user.email)
          assert_kind_of Time, user.created_at
          refute_respond_to user, :password_digest
        end
      end
    end
  end
end
