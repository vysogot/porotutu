# frozen_string_literal: true

module Conflicts
  module Services
    class List
      extend Patterns::Service

      def call
        result = DB.connection.exec(
          'SELECT * FROM get_conflicts()'
        )

        result.map do |row|
          Conflict.new(id: row['id'], name: row['name'])
        end
      end
    end
  end
end
