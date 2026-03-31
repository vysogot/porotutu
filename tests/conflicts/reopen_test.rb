# frozen_string_literal: true

require_relative 'test_helper'

module Conflicts
  module Tests
    class ReopenTest < TestCase
      def setup
        super
        @user_id = create_user
        @couple_id = create_couple(user1_id: @user_id, user2_id: create_user)
        @conflict_id = create_conflict(couple_id: @couple_id, creator_id: @user_id, title: 'Reopen me', status: 'active')

        # Propose + accept to archive it
        ::Conflicts::Services::ProposeResolution.call(
          id: @conflict_id,
          status: 'resolved',
          proposed_by_id: @user_id
        )
        ::Conflicts::Services::AcceptResolution.call(id: @conflict_id)
      end

      def test_reopen_sets_active_status
        ::Conflicts::Services::Reopen.call(id: @conflict_id)

        result = DB.connection.exec_params(
          'SELECT status::TEXT, archived_at, recur_count FROM conflicts WHERE id = $1',
          [@conflict_id]
        ).first

        assert_equal 'active', result['status']
      end

      def test_reopen_clears_archived_at
        ::Conflicts::Services::Reopen.call(id: @conflict_id)

        result = DB.connection.exec_params(
          'SELECT archived_at FROM conflicts WHERE id = $1',
          [@conflict_id]
        ).first

        assert_nil result['archived_at']
      end

      def test_reopen_increments_recur_count
        ::Conflicts::Services::Reopen.call(id: @conflict_id)

        result = DB.connection.exec_params(
          'SELECT recur_count FROM conflicts WHERE id = $1',
          [@conflict_id]
        ).first

        assert_equal 1, result['recur_count'].to_i
      end

      def test_reopen_sets_fresh_deadline
        ::Conflicts::Services::Reopen.call(id: @conflict_id)

        result = DB.connection.exec_params(
          'SELECT deadline FROM conflicts WHERE id = $1',
          [@conflict_id]
        ).first

        assert result['deadline']
      end
    end
  end
end
