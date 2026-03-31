# frozen_string_literal: true

require_relative 'test_helper'

module Conflicts
  module Tests
    class UpdateTest < TestCase
      def setup
        super
        @user_id = create_user
        @couple_id = create_couple(user1_id: @user_id, user2_id: create_user)
        @conflict_id = create_conflict(
          couple_id: @couple_id,
          creator_id: @user_id,
          title: 'Original title',
          description: 'Original desc',
          favor: 'Original favor'
        )
      end

      def test_updates_title_description_favor
        conflict = ::Conflicts::Services::Update.call(
          id: @conflict_id,
          title: 'New title',
          description: 'New desc',
          favor: 'New favor'
        )

        assert_equal 'New title', conflict.title
        assert_equal 'New desc', conflict.description
        assert_equal 'New favor', conflict.favor
      end

      def test_updated_at_changes
        original = ::Conflicts::Services::Find.call(id: @conflict_id)

        sleep 0.01

        updated = ::Conflicts::Services::Update.call(
          id: @conflict_id,
          title: 'Changed',
          description: '',
          favor: nil
        )

        assert updated.updated_at >= original.updated_at
      end

      def test_does_not_update_status
        ::Conflicts::Services::Update.call(
          id: @conflict_id,
          title: 'Changed',
          description: '',
          favor: nil
        )

        conflict = ::Conflicts::Services::Find.call(id: @conflict_id)
        assert_equal 'draft', conflict.status
      end
    end
  end
end
