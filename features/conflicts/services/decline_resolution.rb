# frozen_string_literal: true

module Conflicts
  module Services
    class DeclineResolution
      extend Patterns::Service

      def call(id:)
        DB.connection.exec_params(
          'SELECT decline_resolution($1)',
          [id]
        )

        nil
      end
    end
  end
end
