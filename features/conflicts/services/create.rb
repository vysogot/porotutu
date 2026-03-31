# frozen_string_literal: true

module Conflicts
  module Services
    class Create
      extend Patterns::Service

      def call(user_id:, title:, description:, favor:)
        couple = Couples::Services::FindForUser.call(user_id:)
        raise Conflicts::Errors::NoCouple unless couple

        result = DB.connection.exec_params(
          'SELECT * FROM create_conflict($1, $2, $3, $4, $5)',
          [couple.id, user_id, title, description, favor]
        )

        Conflict.from_row(result.first)
      end
    end
  end
end
