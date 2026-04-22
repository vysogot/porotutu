# frozen_string_literal: true

require_relative '../../test_helper'

module Porotutu
  module Conflicts
    class EditHandlerTest < Tests::TestCase
      def setup
        super
        @user = UserFactory.create
        @conflict = ConflictFactory.create(
          creator_id: @user['id']
        )
      end

      def test_returns_conflict_in_locals_when_owned
        locals = EditHandler.call(
          params: { id: @conflict['id'] },
          current_user_id: @user['id']
        )

        assert_kind_of ConflictMapper, locals[:conflict]
        assert_equal @conflict['id'], locals[:conflict].id
      end

      def test_returns_nil_conflict_when_not_owned
        other = UserFactory.create

        locals = EditHandler.call(
          params: { id: @conflict['id'] },
          current_user_id: other['id']
        )

        assert_nil locals[:conflict]
      end
    end
  end
end
