# frozen_string_literal: true

module Couples
  module Services
    class FindForUser
      extend Patterns::Service

      def call(user_id:)
        result = DB.connection.exec_params(
          'SELECT * FROM get_couple_for_user($1)',
          [user_id]
        )

        row = result.first
        return nil unless row

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
