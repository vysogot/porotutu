# frozen_string_literal: true

module Conflicts
  module Sharing
    module Services
      class Share
        extend Patterns::Service

        def call(id:)
          result = DB.connection.exec_params(
            'SELECT * FROM conflicts_sharing_share($1)',
            [id]
          )

          Mappers::Conflict.from_row(result.first)
        end
      end
    end
  end
end
