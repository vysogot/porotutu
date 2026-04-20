# frozen_string_literal: true

module Porotutu
  module Conflicts
    class UpdateService
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

        ConflictMapper.from_row(result.first)
      end
    end
  end
end
