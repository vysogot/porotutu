# frozen_string_literal: true

require_relative '../../test_helper'

module Porotutu
  module Conflicts
    class ConflictMapperTest < Minitest::Test
      def test_from_row_maps_expected_columns
        now = Time.now
        row = {
          'id' => 'c-1',
          'creator_id' => 'u-1',
          'title' => 'T',
          'description' => 'D',
          'favor' => 'F',
          'status' => 'draft',
          'created_at' => now,
          'updated_at' => now
        }

        conflict = ConflictMapper.from_row(row)

        assert_equal 'c-1', conflict.id
        assert_equal 'u-1', conflict.creator_id
        assert_equal 'T', conflict.title
        assert_equal 'D', conflict.description
        assert_equal 'F', conflict.favor
        assert_equal 'draft', conflict.status
        assert_equal now, conflict.created_at
        assert_equal now, conflict.updated_at
      end
    end
  end
end
