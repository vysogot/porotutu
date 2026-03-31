# frozen_string_literal: true

module Conflicts
  module Services
    class DeclineResolution
      extend Patterns::Service

      def call(id:)
        result = DB.connection.exec_params(
          'SELECT * FROM decline_resolution($1)',
          [id]
        )

        Conflict.from_row(result.first)
      end
    end
  end
end
