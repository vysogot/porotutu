# frozen_string_literal: true

module Conflicts
  module Services
    class Update
      extend Patterns::Service

      def call(id:, title:, description:, favor:)
        result = DB.connection.exec_params(
          'SELECT * FROM update_conflict($1, $2, $3, $4)',
          [id, title, description, favor]
        )

        Conflict.from_row(result.first)
      end
    end
  end
end
