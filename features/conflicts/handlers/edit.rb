# frozen_string_literal: true

module Conflicts
  module Handlers
    class Edit
      extend Patterns::Service

      def call(params:)
        conflict = Services::Find.call(params:)

        { id: conflict.id, name: conflict.name }
      end
    end
  end
end
