# frozen_string_literal: true

module Conflicts
  module Sharing
    module Services
      class Reveal
        extend Patterns::Service

        def call(couple_id:, partner_id:)
          result = DB.connection.exec_params(
            'SELECT * FROM conflicts_sharing_reveal($1, $2)',
            [couple_id, partner_id]
          )

          result.map do |row|
            Mappers::Conflict.from_row(row)
          end
        end
      end
    end
  end
end
