# frozen_string_literal: true

require_relative 'test_helper'

module Conflicts
  module Tests
    class RevealTest < TestCase
      def setup
        super
        @user1_id = create_user
        @user2_id = create_user
        @couple_id = create_couple(user1_id: @user1_id, user2_id: @user2_id)
      end

      def test_all_pending_for_partner_become_active
        id1 = create_conflict(couple_id: @couple_id, creator_id: @user2_id, title: 'First', status: 'pending')
        id2 = create_conflict(couple_id: @couple_id, creator_id: @user2_id, title: 'Second', status: 'pending')

        ::Conflicts::Services::Reveal.call(couple_id: @couple_id, partner_id: @user2_id)

        assert_equal 'active', ::Conflicts::Services::Find.call(id: id1).status
        assert_equal 'active', ::Conflicts::Services::Find.call(id: id2).status
      end

      def test_sets_deadline_to_seven_days
        id = create_conflict(couple_id: @couple_id, creator_id: @user2_id, title: 'Check deadline', status: 'pending')

        ::Conflicts::Services::Reveal.call(couple_id: @couple_id, partner_id: @user2_id)

        conflict = ::Conflicts::Services::Find.call(id:)
        assert conflict.deadline, 'expected deadline to be set'
      end

      def test_other_couples_unaffected
        other_user1 = create_user
        other_user2 = create_user
        other_couple_id = create_couple(user1_id: other_user1, user2_id: other_user2)
        other_id = create_conflict(couple_id: other_couple_id, creator_id: other_user2, title: 'Other', status: 'pending')

        ::Conflicts::Services::Reveal.call(couple_id: @couple_id, partner_id: @user2_id)

        assert_equal 'pending', ::Conflicts::Services::Find.call(id: other_id).status
      end
    end
  end
end
