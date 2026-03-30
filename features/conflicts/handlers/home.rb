# frozen_string_literal: true

module Conflicts
  module Handlers
    class Home
      extend Patterns::Service

      def call
        result = DB.connection.exec('SELECT id, name FROM conflicts ORDER BY id')
        {
          conflicts: result.map { |row| Conflict.new(id: row['id'], name: row['name']) }
        }
      end
    end
  end
end
