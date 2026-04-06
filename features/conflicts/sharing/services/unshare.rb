# frozen_string_literal: true

module Conflicts
  module Sharing
    module Services
      class Unshare
        extend Patterns::Service

        def call(id:)
          result = DB.connection.exec_params(
            'SELECT * FROM conflicts_sharing_unshare($1)',
            [id]
          )

          Mappers::Conflict.from_row(result.first)
        end
      end
    end
  end
end
