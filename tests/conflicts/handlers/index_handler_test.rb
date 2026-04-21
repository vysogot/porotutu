# frozen_string_literal: true

require_relative '../../test_helper'

module Porotutu
  module Conflicts
    class IndexHandlerTest < Tests::TestCase
      def setup
        super
        @user = Tests::Factories::UserFactory.create(conn: @_db_conn)
      end

      def test_returns_drafts_for_user
        draft = Tests::Factories::ConflictFactory.create(
          conn: @_db_conn,
          creator_id: @user['id'],
          status: 'draft'
        )

        locals = IndexHandler.call(current_user_id: @user['id'])

        assert_equal [draft['id']], locals[:drafts].map(&:id)
      end
    end
  end
end
