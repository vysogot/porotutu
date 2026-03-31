# frozen_string_literal: true

module Conflicts
  module Services
    class Unshare
      extend Patterns::Service

      def call(id:)
        DB.connection.exec_params(
          'SELECT unshare_conflict($1)',
          [id]
        )

        nil
      end
    end
  end
end
