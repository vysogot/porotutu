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
            p_id: id,
            p_title: title,
            p_description: description,
            p_favor: favor
          )

          Mappers::Conflict.from_row(result.first)
        end
      end
    end
  end
end
