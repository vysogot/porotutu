# frozen_string_literal: true

module Conflicts
  module Handlers
    class Home
      extend Patterns::Service

      def call
        { conflicts: Services::List.call }
      end
    end
  end
end
