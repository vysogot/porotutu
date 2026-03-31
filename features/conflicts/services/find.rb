# frozen_string_literal: true

module Conflicts
  module Services
    class Find
      extend Patterns::Service

      def call(id:)
        result = DB.connection.exec_params(
          'SELECT * FROM get_conflict($1)',
          [id]
        )

        row = result.first
        return nil unless row

        Conflict.from_row(row)
      end
    end
  end
end
