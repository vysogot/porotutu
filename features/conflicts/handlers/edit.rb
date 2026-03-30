# frozen_string_literal: true

module Conflicts
  module Handlers
    class Edit
      extend Patterns::Service

      def call(params:)
        result = DB.connection.exec_params(
          'SELECT id, name FROM conflicts WHERE id = $1',
          [params[:id]]
        )
        row = result.first
        conflict = Conflict.new(id: row['id'], name: row['name'])

        { id: conflict.id, name: conflict.name }
      end
    end
  end
end
