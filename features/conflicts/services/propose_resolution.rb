# frozen_string_literal: true

module Conflicts
  module Services
    class ProposeResolution
      extend Patterns::Service

      def call(id:, status:, proposed_by_id:)
        DB.connection.exec_params(
          'SELECT propose_resolution($1, $2, $3)',
          [id, status, proposed_by_id]
        )

        nil
      end
    end
  end
end
