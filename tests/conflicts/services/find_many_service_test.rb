# frozen_string_literal: true

require_relative '../../test_helper'

module Porotutu
  module Conflicts
    class FindManyServiceTest < Tests::TestCase
      def setup
        super
        @user = UserFactory.create
      end

      def test_groups_drafts_for_the_given_user
        draft = ConflictFactory.create(
          creator_id: @user['id'],
          status: 'draft'
        )
        ConflictFactory.create(
          creator_id: @user['id'],
          status: 'resolved'
        )

        result = FindManyService.call(user_id: @user['id'])

        assert_equal [draft['id']], result[:drafts].map(&:id)
      end

      def test_does_not_return_other_users_conflicts
        other = UserFactory.create
        ConflictFactory.create(
          creator_id: other['id'],
          status: 'draft'
        )

        result = FindManyService.call(user_id: @user['id'])

        assert_empty result[:drafts]
      end
    end
  end
end
