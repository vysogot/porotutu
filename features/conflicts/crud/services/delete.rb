# frozen_string_literal: true

module Conflicts
  module Crud
    module Services
      class Delete
        extend Patterns::Service

        def call(id:)
          DB.connection.exec_params(
            'SELECT conflicts_crud_delete($1)',
            [id]
          )

          nil
        end
      end
    end
  end
end
