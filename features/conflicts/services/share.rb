# frozen_string_literal: true

module Conflicts
  module Services
    class Share
      extend Patterns::Service

      def call(id:)
        result = DB.connection.exec_params(
          'SELECT * FROM share_conflict($1)',
          [id]
        )

        Conflict.from_row(result.first)
      end
    end
  end
end
