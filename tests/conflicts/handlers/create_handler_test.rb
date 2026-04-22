# frozen_string_literal: true

require_relative '../../test_helper'

module Porotutu
  module Conflicts
    class CreateHandlerTest < Tests::TestCase
      def setup
        super
        @user = UserFactory.create
      end

      def test_validates_creates_and_returns_locals_with_draft_status
        locals = CreateHandler.call(
          params: { title: 'T', description: 'D', favor: 'F', status: 'spoofed' },
          current_user_id: @user['id']
        )

        assert_kind_of ConflictMapper, locals[:conflict]
        assert_equal 'draft', locals[:conflict].status
        assert_equal @user['id'], locals[:current_user_id]
      end

      def test_raises_validation_error_when_fields_missing
        assert_raises(ValidationError) do
          CreateHandler.call(
            params: { title: '', description: '', favor: '' },
            current_user_id: @user['id']
          )
        end
      end
    end
  end
end
