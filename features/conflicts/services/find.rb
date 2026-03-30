# frozen_string_literal: true

module Conflicts
  module Services
    class Find
      extend Patterns::Service

      def call(params:)
        result = DB.connection.exec_params(
          'SELECT * FROM get_conflict($1)',
          [params[:id]]
        )
        row = result.first
        Conflict.new(id: row['id'], name: row['name'])
      end
    end
  end
end
