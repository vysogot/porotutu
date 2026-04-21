# frozen_string_literal: true

require_relative '../../test_helper'

module Porotutu
  module Conflicts
    class UpdateServiceTest < Tests::TestCase
      def setup
        super
        @user = Tests::Factories::UserFactory.create(conn: @_db_conn)
        @conflict = Tests::Factories::ConflictFactory.create(
          conn: @_db_conn,
          creator_id: @user['id'],
          title: 'Old',
          description: 'Old desc',
          favor: 'Old favor'
        )
      end

      def test_updates_fields_and_returns_mapper
        updated = UpdateService.call(
          id: @conflict['id'],
          title: 'New',
          description: 'New desc',
          favor: 'New favor'
        )

        assert_kind_of ConflictMapper, updated
        assert_equal 'New', updated.title
        assert_equal 'New desc', updated.description
        assert_equal 'New favor', updated.favor
      end
    end
  end
end
