# frozen_string_literal: true

module Conflicts
  module Services
    class Update
      extend Patterns::Service

      def call(params:)
        result = DB.connection.exec_params(
          'SELECT * FROM update_conflict($1, $2)',
          [params[:id], params[:name]]
        )

        row = result.first
        Conflict.new(id: row['id'], name: row['name'])
      end
    end
  end
end
