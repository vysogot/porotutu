# frozen_string_literal: true

require_relative '../../test_helper'

module Porotutu
  module Conflicts
    class IndexHandlerTest < Tests::TestCase
      def setup
        super
        @user = UserFactory.create
      end

      def test_returns_drafts_for_user
        draft = ConflictFactory.create(
          creator_id: @user['id'],
          status: 'draft'
        )

        locals = IndexHandler.call(current_user_id: @user['id'])

        assert_equal [draft['id']], locals[:drafts].map(&:id)
      end
    end
  end
end
