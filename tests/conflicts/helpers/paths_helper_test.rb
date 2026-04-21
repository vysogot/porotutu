# frozen_string_literal: true

require_relative '../../test_helper'

module Porotutu
  module Conflicts
    class PathsHelperTest < Minitest::Test
      include PathsHelper

      def test_static_paths
        assert_equal '/conflicts', conflicts_path
        assert_equal '/conflicts/new', new_conflict_path
      end

      def test_conflict_paths_use_conflict_id
        conflict = Struct.new(:id).new('abc-123')

        assert_equal '/conflicts/abc-123', conflict_path(conflict)
        assert_equal '/conflicts/abc-123/edit', edit_conflict_path(conflict)
      end
    end
  end
end
