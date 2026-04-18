# frozen_string_literal: true

module Conflicts
  module Crud
    module Services
      class Create
        extend Patterns::Service
        include Patterns::Query

        def call(user_id:, title:, description:, favor:, status:)
          result = call_function(
            'conflicts_crud_create',
            p_creator_id: user_id,
            p_title: title,
            p_description: description,
            p_favor: favor,
            p_status: status
          )

          Mappers::Conflict.from_row(result.first)
        end
      end
    end
  end
end
