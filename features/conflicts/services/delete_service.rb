# frozen_string_literal: true

module Porotutu
  module Conflicts
    class DeleteService
      extend Service
      include DbFunctionCall

      def call(id:, user_id:)
        result = call_function('conflicts_crud_delete', p_id: id, p_user_id: user_id)
        row = result.first

        row && ConflictMapper.from_row(row)
      end
    end
  end
end
