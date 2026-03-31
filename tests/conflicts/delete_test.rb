# frozen_string_literal: true

require_relative 'test_helper'

module Conflicts
  module Tests
    class DeleteTest < TestCase
      def setup
        super
        @user_id = create_user
        @couple_id = create_couple(user1_id: @user_id, user2_id: create_user)
        @conflict_id = create_conflict(couple_id: @couple_id, creator_id: @user_id, title: 'To delete')
      end

      def test_deletes_the_record
        ::Conflicts::Services::Delete.call(id: @conflict_id)

        result = ::Conflicts::Services::Find.call(id: @conflict_id)
        assert_nil result
      end
    end
  end
end
