# frozen_string_literal: true

require_relative '../../test_helper'

module Porotutu
  module Conflicts
    class DeleteHandlerTest < Tests::TestCase
      def setup
        super
        @user = Tests::Factories::UserFactory.create(conn: @_db_conn)
        @conflict = Tests::Factories::ConflictFactory.create(
          conn: @_db_conn,
          creator_id: @user['id']
        )
      end

      def test_deletes_owned_conflict
        DeleteHandler.call(
          params: { id: @conflict['id'] },
          current_user_id: @user['id']
        )

        row = Tests::TestDb.fetch_one('SELECT id FROM conflicts WHERE id = $1', [@conflict['id']])
        assert_nil row
      end

      def test_does_not_delete_conflict_owned_by_other_user
        other = Tests::Factories::UserFactory.create(conn: @_db_conn)

        DeleteHandler.call(
          params: { id: @conflict['id'] },
          current_user_id: other['id']
        )

        row = Tests::TestDb.fetch_one('SELECT id FROM conflicts WHERE id = $1', [@conflict['id']])
        refute_nil row
      end
    end
  end
end
