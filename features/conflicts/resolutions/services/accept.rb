# frozen_string_literal: true

module Conflicts
  module Resolutions
    module Services
      class Accept
        extend Patterns::Service

        def call(id:)
          result = DB.connection.exec_params(
            'SELECT * FROM conflicts_resolutions_accept($1)',
            [id]
          )

          Mappers::Conflict.from_row(result.first)
        end
      end
    end
  end
end
