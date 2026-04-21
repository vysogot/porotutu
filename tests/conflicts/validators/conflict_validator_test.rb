# frozen_string_literal: true

require_relative '../../test_helper'

module Porotutu
  module Conflicts
    class ConflictValidatorTest < Minitest::Test
      def test_passes_when_all_fields_present_and_within_limits
        assert_nil ConflictValidator.call(
          params: { title: 'T', description: 'D', favor: 'F' }
        )
      end

      def test_raises_with_presence_errors_when_fields_missing
        error = assert_raises(ValidationError) do
          ConflictValidator.call(params: { title: '', description: nil, favor: '' })
        end

        assert_includes error.errors.keys, :title
        assert_includes error.errors.keys, :description
        assert_includes error.errors.keys, :favor
      end

      def test_raises_with_length_errors_when_fields_exceed_limits
        error = assert_raises(ValidationError) do
          ConflictValidator.call(
            params: {
              title: 'a' * (ConflictValidator::TITLE_MAX + 1),
              description: 'b' * (ConflictValidator::DESCRIPTION_MAX + 1),
              favor: 'c' * (ConflictValidator::FAVOR_MAX + 1)
            }
          )
        end

        assert_includes error.errors.keys, :title
        assert_includes error.errors.keys, :description
        assert_includes error.errors.keys, :favor
      end
    end
  end
end
