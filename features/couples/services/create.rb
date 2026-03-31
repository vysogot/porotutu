# frozen_string_literal: true

module Couples
  module Services
    class Create
      extend Patterns::Service

      def call(partner1_id:, partner2_id:)
        result = DB.connection.exec_params(
          'SELECT * FROM create_couple($1, $2)',
          [partner1_id, partner2_id]
        )

        row = result.first

        Couple.new(
          id: row['id'],
          partner1_id: row['partner1_id'],
          partner2_id: row['partner2_id'],
          disconnected_partner_id: row['disconnected_partner_id']
        )
      end
    end
  end
end
