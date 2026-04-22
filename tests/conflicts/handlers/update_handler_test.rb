# frozen_string_literal: true

require_relative '../../test_helper'

module Porotutu
  module Conflicts
    class UpdateHandlerTest < Tests::TestCase
      def setup
        super
        @user = UserFactory.create
        @conflict = ConflictFactory.create(
          creator_id: @user['id'],
          title: 'Old',
          description: 'Old',
          favor: 'Old'
        )
      end

      def test_validates_updates_and_returns_locals
        locals = UpdateHandler.call(
          params: { id: @conflict['id'], title: 'New', description: 'New', favor: 'New' }
        )

        assert_kind_of ConflictMapper, locals[:conflict]
        assert_equal 'New', locals[:conflict].title
      end

      def test_raises_validation_error_when_fields_missing
        assert_raises(ValidationError) do
          UpdateHandler.call(
            params: { id: @conflict['id'], title: '', description: '', favor: '' }
          )
        end
      end
    end
  end
end
