# frozen_string_literal: true

module Conflicts
  module Handlers
    class Update
      extend Patterns::Service

      def call(params:)
        conflicts = Services::Update.call(params:)

        {
          id: conflicts.id,
          name: conflicts.name
        }
      end
    end
  end
end
