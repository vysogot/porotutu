# frozen_string_literal: true

require_relative '../test_helper'

module Porotutu
  module Conflicts
    class RoutesTest < Tests::RequestTestCase
      def setup
        super
        @user = Tests::Factories::UserFactory.create(conn: @_db_conn)
        login_as(@user)
      end

      def test_get_index_renders_with_drafts
        Tests::Factories::ConflictFactory.create(
          conn: @_db_conn,
          creator_id: @user['id'],
          status: 'draft',
          title: 'My draft'
        )

        get '/conflicts'

        assert_equal 200, last_response.status
        assert_includes last_response.body, 'My draft'
      end

      def test_get_new_renders_the_form
        get '/conflicts/new'

        assert_equal 200, last_response.status
        assert_includes last_response.body, 'action="/conflicts"'
      end

      def test_post_conflicts_creates_and_redirects_to_show
        post '/conflicts', title: 'T', description: 'D', favor: 'F'

        assert_equal 303, last_response.status
        assert_match %r{^/conflicts/[\w-]+$}, URI(last_response.location).path

        row = Tests::TestDb.fetch_one('SELECT id FROM conflicts WHERE creator_id = $1', [@user['id']])
        refute_nil row
      end

      def test_post_conflicts_returns_422_when_invalid
        post '/conflicts', title: '', description: '', favor: ''

        assert_equal 422, last_response.status
      end

      def test_get_show_for_owned_conflict
        conflict = Tests::Factories::ConflictFactory.create(
          conn: @_db_conn,
          creator_id: @user['id'],
          title: 'Showable'
        )

        get "/conflicts/#{conflict['id']}"

        assert_equal 200, last_response.status
        assert_includes last_response.body, 'Showable'
      end

      def test_get_edit_for_owned_conflict
        conflict = Tests::Factories::ConflictFactory.create(
          conn: @_db_conn,
          creator_id: @user['id']
        )

        get "/conflicts/#{conflict['id']}/edit"

        assert_equal 200, last_response.status
        assert_includes last_response.body, %(action="/conflicts/#{conflict['id']}")
      end

      def test_patch_updates_owned_conflict
        conflict = Tests::Factories::ConflictFactory.create(
          conn: @_db_conn,
          creator_id: @user['id'],
          title: 'Old'
        )

        patch "/conflicts/#{conflict['id']}", title: 'New', description: 'D', favor: 'F'

        assert_equal 200, last_response.status
        assert_includes last_response.content_type, 'text/vnd.turbo-stream.html'

        row = Tests::TestDb.fetch_one('SELECT title FROM conflicts WHERE id = $1', [conflict['id']])
        assert_equal 'New', row['title']
      end

      def test_patch_returns_422_when_invalid
        conflict = Tests::Factories::ConflictFactory.create(
          conn: @_db_conn,
          creator_id: @user['id']
        )

        patch "/conflicts/#{conflict['id']}", title: '', description: '', favor: ''

        assert_equal 422, last_response.status
      end

      def test_delete_removes_owned_conflict_and_redirects
        conflict = Tests::Factories::ConflictFactory.create(
          conn: @_db_conn,
          creator_id: @user['id']
        )

        delete "/conflicts/#{conflict['id']}"

        assert_equal 303, last_response.status
        assert_equal '/conflicts', URI(last_response.location).path

        row = Tests::TestDb.fetch_one('SELECT id FROM conflicts WHERE id = $1', [conflict['id']])
        assert_nil row
      end

      private

      def login_as(user)
        env 'rack.session', { 'user_id' => user['id'] }
      end
    end
  end
end
