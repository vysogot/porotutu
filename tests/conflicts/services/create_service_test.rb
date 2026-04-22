# frozen_string_literal: true

require_relative '../../test_helper'

module Porotutu
  module Conflicts
    class CreateServiceTest < Tests::TestCase
      def setup
        super
        @user = UserFactory.create
      end

      def test_creates_a_conflict_and_returns_a_mapper
        conflict = CreateService.call(
          user_id: @user['id'],
          title: 'Title',
          description: 'Description',
          favor: 'Favor',
          status: 'draft'
        )

        assert_kind_of ConflictMapper, conflict
        assert_equal 'Title', conflict.title
        assert_equal 'draft', conflict.status
        assert_equal @user['id'], conflict.creator_id
      end
    end
  end
end
