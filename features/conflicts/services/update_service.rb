# frozen_string_literal: true

module Porotutu
  module Conflicts
    class UpdateService
      extend Service
      include DbFunctionCall

      def call(id:, title:, description:, favor:)
        result = call_function(
          'conflicts_update',
          p_id: id,
          p_title: title,
          p_description: description,
          p_favor: favor
        )

        ConflictMapper.from_row(result.first)
      end
    end
  end
end
