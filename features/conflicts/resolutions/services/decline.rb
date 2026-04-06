# frozen_string_literal: true

module Conflicts
  module Resolutions
    module Services
      class Decline
        extend Patterns::Service

        def call(id:)
          result = DB.connection.exec_params(
            'SELECT * FROM conflicts_resolutions_decline($1)',
            [id]
          )

          Mappers::Conflict.from_row(result.first)
        end
      end
    end
  end
end
