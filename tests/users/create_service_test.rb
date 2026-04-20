# frozen_string_literal: true

require_relative '../test_helper'

module Porotutu
  module Users
    class CreateServiceTest < Tests::TestCase
      def test_creates_a_user_and_returns_a_mapper
        user = Users::CreateService.call(
          params: { email: "alice-#{SecureRandom.hex(4)}@example.com", password: 'hunter22' }
        )

        assert_kind_of UserMapper, user
        assert_match(/@example\.com\z/, user.email)
        assert_kind_of Time, user.created_at
        refute_respond_to user, :password_digest
      end
    end
  end
end
