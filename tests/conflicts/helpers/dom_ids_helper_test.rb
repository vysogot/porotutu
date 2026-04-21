# frozen_string_literal: true

require_relative '../../test_helper'

module Porotutu
  module Conflicts
    class DomIdsHelperTest < Minitest::Test
      include DomIdsHelper

      def test_conflict_frame_id_uses_conflict_id
        conflict = Struct.new(:id).new('abc-123')

        assert_equal 'conflict-abc-123', conflict_frame_id(conflict)
      end
    end
  end
end
