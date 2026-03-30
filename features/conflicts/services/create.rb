# frozen_string_literal: true

module Conflicts
  module Services
    class Create
      extend Patterns::Service

      def call(params:)
        result = DB.connection.exec_params(
          'SELECT * FROM create_conflict($1)',
          [params[:name]]
        )

        row = result.first
        Conflict.new(id: row['id'], name: row['name'])
      end
    end
  end
end
