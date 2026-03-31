# frozen_string_literal: true

require_relative 'test_helper'

module Conflicts
  module Tests
    class FindTest < TestCase
      def setup
        super
        @user_id = create_user
        @couple_id = create_couple(user1_id: @user_id, user2_id: create_user)
        @conflict_id = create_conflict(couple_id: @couple_id, creator_id: @user_id, title: 'Find me')
      end

      def test_returns_correct_conflict
        conflict = ::Conflicts::Services::Find.call(id: @conflict_id)

        assert_equal @conflict_id, conflict.id
        assert_equal 'Find me', conflict.title
      end

      def test_returns_nil_for_unknown_id
        result = ::Conflicts::Services::Find.call(id: '00000000-0000-0000-0000-000000000000')

        assert_nil result
      end
    end
  end
end
