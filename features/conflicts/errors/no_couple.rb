# frozen_string_literal: true

module Conflicts
  module Errors
    class NoCouple < StandardError
      def initialize
        super('No couple found for user.')
      end
    end
  end
end
