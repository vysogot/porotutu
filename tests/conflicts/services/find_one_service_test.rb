# frozen_string_literal: true

require_relative '../../test_helper'

module Porotutu
  module Conflicts
    class FindOneServiceTest < Tests::TestCase
      def setup
        super
        @user = UserFactory.create(conn: @_db_conn)
        @conflict = ConflictFactory.create(
          conn: @_db_conn,
          creator_id: @user['id']
        )
      end

      def test_returns_mapper_when_owned_by_caller
        found = FindOneService.call(id: @conflict['id'], user_id: @user['id'])

        assert_kind_of ConflictMapper, found
        assert_equal @conflict['id'], found.id
      end

      def test_returns_nil_when_not_owned_by_caller
        other = UserFactory.create(conn: @_db_conn)

        assert_nil FindOneService.call(id: @conflict['id'], user_id: other['id'])
      end
    end
  end
end
