# frozen_string_literal: true

require_relative 'test_helper'

module Conflicts
  module Tests
    class CreateTest < TestCase
      def setup
        super
        @user_id = create_user
        @couple_id = create_couple(user1_id: @user_id, user2_id: create_user)
      end

      def test_creates_with_draft_status
        conflict = ::Conflicts::Services::Create.call(
          couple_id: @couple_id,
          creator_id: @user_id,
          title: 'The dishes conflict',
          description: 'Who does them',
          favor: 'Cook for a week'
        )

        assert_equal 'draft', conflict.status
      end

      def test_stores_title_description_favor
        conflict = ::Conflicts::Services::Create.call(
          couple_id: @couple_id,
          creator_id: @user_id,
          title: 'The dishes conflict',
          description: 'Who does them',
          favor: 'Cook for a week'
        )

        assert_equal 'The dishes conflict', conflict.title
        assert_equal 'Who does them', conflict.description
        assert_equal 'Cook for a week', conflict.favor
      end

      def test_sets_creator_id
        conflict = ::Conflicts::Services::Create.call(
          couple_id: @couple_id,
          creator_id: @user_id,
          title: 'Test',
          description: '',
          favor: nil
        )

        assert_equal @user_id, conflict.creator_id
      end

      def test_deadline_is_nil
        conflict = ::Conflicts::Services::Create.call(
          couple_id: @couple_id,
          creator_id: @user_id,
          title: 'Test',
          description: '',
          favor: nil
        )

        assert_nil conflict.deadline
      end
    end
  end
end
