# frozen_string_literal: true

module Conflicts
  module Services
    class Delete
      extend Patterns::Service

      def call(id:)
        DB.connection.exec_params(
          'SELECT delete_conflict($1)',
          [id]
        )

        nil
      end
    end
  end
end
