# frozen_string_literal: true

require_relative 'test_helper'

module Conflicts
  module Tests
    class ListTest < TestCase
      def setup
        super
        @user1_id = create_user
        @user2_id = create_user
        @couple_id = create_couple(user1_id: @user1_id, user2_id: @user2_id)

        other_user = create_user
        other_user2 = create_user
        @other_couple_id = create_couple(user1_id: other_user, user2_id: other_user2)
      end

      def test_returns_own_drafts
        create_conflict(couple_id: @couple_id, creator_id: @user1_id, title: 'My draft', status: 'draft')

        result = ::Conflicts::Services::List.call(couple_id: @couple_id, user_id: @user1_id)

        assert_equal 1, result[:drafts].length
        assert_equal 'My draft', result[:drafts].first.title
      end

      def test_returns_pending_mine
        create_conflict(couple_id: @couple_id, creator_id: @user1_id, title: 'My pending', status: 'pending')

        result = ::Conflicts::Services::List.call(couple_id: @couple_id, user_id: @user1_id)

        assert_equal 1, result[:pending_mine].length
        assert_equal 'My pending', result[:pending_mine].first.title
      end

      def test_returns_pending_partner_separately
        create_conflict(couple_id: @couple_id, creator_id: @user2_id, title: "Partner's pending", status: 'pending')

        result = ::Conflicts::Services::List.call(couple_id: @couple_id, user_id: @user1_id)

        assert_equal 1, result[:pending_partner].length
        assert_equal "Partner's pending", result[:pending_partner].first.title
      end

      def test_returns_active_for_couple
        create_conflict(couple_id: @couple_id, creator_id: @user1_id, title: 'Active one', status: 'active')
        create_conflict(couple_id: @couple_id, creator_id: @user2_id, title: 'Active two', status: 'active')

        result = ::Conflicts::Services::List.call(couple_id: @couple_id, user_id: @user1_id)

        assert_equal 2, result[:active].length
      end

      def test_excludes_other_couples
        create_conflict(couple_id: @other_couple_id, creator_id: create_user, title: 'Other couple', status: 'draft')

        result = ::Conflicts::Services::List.call(couple_id: @couple_id, user_id: @user1_id)

        all = result[:drafts] + result[:pending_mine] + result[:pending_partner] + result[:active]
        assert all.none? { |c| c.title == 'Other couple' }
      end
    end
  end
end
