# frozen_string_literal: true

module Conflicts
  module Handlers
    class Create
      extend Patterns::Service

      def call(params:)
        params = params.slice(:name)
        conflicts = Services::Create.call(params:)

        {
          id: conflicts.id,
          name: conflicts.name
        }
      end
    end
  end
end
