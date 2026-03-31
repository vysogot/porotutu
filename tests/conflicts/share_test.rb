# frozen_string_literal: true

require_relative 'test_helper'

module Conflicts
  module Tests
    class ShareTest < TestCase
      def setup
        super
        @user_id = create_user
        @couple_id = create_couple(user1_id: @user_id, user2_id: create_user)
        @conflict_id = create_conflict(couple_id: @couple_id, creator_id: @user_id, title: 'Shareable')
      end

      def test_share_moves_draft_to_pending
        ::Conflicts::Services::Share.call(id: @conflict_id)

        conflict = ::Conflicts::Services::Find.call(id: @conflict_id)
        assert_equal 'pending', conflict.status
      end

      def test_unshare_moves_pending_to_draft
        ::Conflicts::Services::Share.call(id: @conflict_id)
        ::Conflicts::Services::Unshare.call(id: @conflict_id)

        conflict = ::Conflicts::Services::Find.call(id: @conflict_id)
        assert_equal 'draft', conflict.status
      end
    end
  end
end
