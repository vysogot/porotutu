# frozen_string_literal: true

require_relative '../../test_helper'

module Porotutu
  module Conflicts
    class DeleteServiceTest < Tests::TestCase
      def setup
        super
        @user = UserFactory.create
        @conflict = ConflictFactory.create(
          creator_id: @user['id']
        )
      end

      def test_deletes_owned_conflict_and_returns_a_mapper
        deleted = DeleteService.call(id: @conflict['id'], user_id: @user['id'])

        assert_kind_of ConflictMapper, deleted
        assert_equal @conflict['id'], deleted.id

        row = TestDb.fetch_one('SELECT id FROM conflicts WHERE id = $1', [@conflict['id']])

        assert_nil row
      end

      def test_returns_nil_and_does_not_delete_when_caller_is_not_creator
        other = UserFactory.create

        assert_nil DeleteService.call(id: @conflict['id'], user_id: other['id'])

        row = TestDb.fetch_one('SELECT id FROM conflicts WHERE id = $1', [@conflict['id']])

        refute_nil row
      end
    end
  end
end
