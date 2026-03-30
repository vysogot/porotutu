# frozen_string_literal: true

module Conflicts
  module Services
    class Delete
      extend Patterns::Service

      def call(params:)
        DB.connection.exec_params(
          'SELECT delete_conflict($1)',
          [params[:id]]
        )
      end
    end
  end
end
