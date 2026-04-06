# frozen_string_literal: true

module Conflicts
  module Reopening
    module Services
      class Reopen
        extend Patterns::Service

        def call(id:)
          result = DB.connection.exec_params(
            'SELECT * FROM conflicts_reopening_reopen($1)',
            [id]
          )

          Mappers::Conflict.from_row(result.first)
        end
      end
    end
  end
end
