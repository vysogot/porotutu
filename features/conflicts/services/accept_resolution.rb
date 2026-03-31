# frozen_string_literal: true

module Conflicts
  module Services
    class AcceptResolution
      extend Patterns::Service

      def call(id:)
        result = DB.connection.exec_params(
          'SELECT * FROM accept_resolution($1)',
          [id]
        )

        Conflict.from_row(result.first)
      end
    end
  end
end
