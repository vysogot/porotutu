# frozen_string_literal: true

require_relative '../../test_helper'

module Porotutu
  module Conflicts
    class DeleteServiceTest < Tests::TestCase
      def setup
        super
        @user = Tests::Factories::UserFactory.create(conn: @_db_conn)
        @conflict = Tests::Factories::ConflictFactory.create(
          conn: @_db_conn,
          creator_id: @user['id']
        )
      end

      def test_deletes_owned_conflict_and_returns_a_mapper
        deleted = DeleteService.call(id: @conflict['id'], user_id: @user['id'])

        assert_kind_of ConflictMapper, deleted
        assert_equal @conflict['id'], deleted.id

        row = @_db_conn.exec_params(
          'SELECT id FROM conflicts WHERE id = $1',
          [@conflict['id']]
        ).first
        assert_nil row
      end

      def test_returns_nil_and_does_not_delete_when_caller_is_not_creator
        other = Tests::Factories::UserFactory.create(conn: @_db_conn)

        assert_nil DeleteService.call(id: @conflict['id'], user_id: other['id'])

        row = @_db_conn.exec_params(
          'SELECT id FROM conflicts WHERE id = $1',
          [@conflict['id']]
        ).first
        refute_nil row
      end
    end
  end
end
