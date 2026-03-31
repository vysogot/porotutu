# frozen_string_literal: true

module Conflicts
  module Services
    class Share
      extend Patterns::Service

      def call(id:)
        DB.connection.exec_params(
          'SELECT share_conflict($1)',
          [id]
        )

        nil
      end
    end
  end
end
