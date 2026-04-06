# frozen_string_literal: true

module Conflicts
  module Resolutions
    module Services
      class Propose
        extend Patterns::Service

        def call(id:, status:, proposed_by_id:)
          result = DB.connection.exec_params(
            'SELECT * FROM conflicts_resolutions_propose($1, $2, $3)',
            [id, status, proposed_by_id]
          )

          Mappers::Conflict.from_row(result.first)
        end
      end
    end
  end
end
