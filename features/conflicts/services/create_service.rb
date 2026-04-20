# frozen_string_literal: true

module Porotutu
  module Conflicts
    class CreateService
      extend Service
      include DbFunctionCall

      def call(user_id:, title:, description:, favor:, status:)
        result = call_function(
          'conflicts_crud_create',
          p_creator_id: user_id,
          p_title: title,
          p_description: description,
          p_favor: favor,
          p_status: status
        )

        ConflictMapper.from_row(result.first)
      end
    end
  end
end
