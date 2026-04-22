# frozen_string_literal: true

require_relative '../../test_helper'

module Porotutu
  module Conflicts
    class ShowHandlerTest < Tests::TestCase
      def setup
        super
        @user = UserFactory.create(conn: @_db_conn)
        @conflict = ConflictFactory.create(
          conn: @_db_conn,
          creator_id: @user['id']
        )
      end

      def test_returns_conflict_when_owned
        locals = ShowHandler.call(
          params: { id: @conflict['id'] },
          current_user_id: @user['id']
        )

        assert_kind_of ConflictMapper, locals[:conflict]
      end

      def test_returns_nil_conflict_when_not_owned
        other = UserFactory.create(conn: @_db_conn)

        locals = ShowHandler.call(
          params: { id: @conflict['id'] },
          current_user_id: other['id']
        )

        assert_nil locals[:conflict]
      end
    end
  end
end
