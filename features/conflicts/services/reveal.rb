# frozen_string_literal: true

module Conflicts
  module Services
    class Reveal
      extend Patterns::Service

      def call(couple_id:, partner_id:)
        result = DB.connection.exec_params(
          'SELECT * FROM reveal_conflicts($1, $2)',
          [couple_id, partner_id]
        )

        result.map do |row|
          Conflict.from_row(row)
        end
      end
    end
  end
end
