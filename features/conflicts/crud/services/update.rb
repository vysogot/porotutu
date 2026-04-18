# frozen_string_literal: true

module Conflicts
  module Crud
    module Services
      class Update
        extend Patterns::Service
        include Patterns::Query

        def call(id:, title:, description:, favor:)
          result = call_function(
            'conflicts_crud_update',
            [id, title, description, favor]
          )

          Mappers::Conflict.from_row(result.first)
        end
      end
    end
  end
end
