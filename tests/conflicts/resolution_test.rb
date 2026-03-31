# frozen_string_literal: true

require_relative 'test_helper'

module Conflicts
  module Tests
    class ResolutionTest < TestCase
      def setup
        super
        @user1_id = create_user
        @user2_id = create_user
        @couple_id = create_couple(user1_id: @user1_id, user2_id: @user2_id)
        @conflict_id = create_conflict(couple_id: @couple_id, creator_id: @user1_id, title: 'Resolution test', status: 'active')
      end

      def test_propose_sets_proposed_status_and_by
        ::Conflicts::Services::ProposeResolution.call(
          id: @conflict_id,
          status: 'resolved',
          proposed_by_id: @user1_id
        )

        conflict = ::Conflicts::Services::Find.call(id: @conflict_id)
        assert_equal 'resolved', conflict.proposed_status
        assert_equal @user1_id, conflict.proposed_by_id
      end

      def test_accept_archives_and_records_resolution
        ::Conflicts::Services::ProposeResolution.call(
          id: @conflict_id,
          status: 'resolved',
          proposed_by_id: @user1_id
        )
        ::Conflicts::Services::AcceptResolution.call(id: @conflict_id)

        conflict = ::Conflicts::Services::Find.call(id: @conflict_id)
        refute_nil conflict.archived_at
        assert_nil conflict.proposed_status
        assert_nil conflict.proposed_by_id

        resolution_count = DB.connection.exec_params(
          'SELECT COUNT(*) FROM conflict_resolutions WHERE conflict_id = $1',
          [@conflict_id]
        ).first['count'].to_i
        assert_equal 1, resolution_count
      end

      def test_decline_clears_proposed_fields
        ::Conflicts::Services::ProposeResolution.call(
          id: @conflict_id,
          status: 'resolved',
          proposed_by_id: @user1_id
        )
        ::Conflicts::Services::DeclineResolution.call(id: @conflict_id)

        conflict = ::Conflicts::Services::Find.call(id: @conflict_id)
        assert_nil conflict.proposed_status
        assert_nil conflict.proposed_by_id
      end
    end
  end
end
