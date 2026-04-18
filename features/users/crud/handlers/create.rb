# frozen_string_literal: true

module Porotutu
  module Users
    module Crud
      module Handlers
        class Create
          extend Patterns::Service

          def call(params:)
            params = params.slice(:email, :password)

            Services::Create.call(params:)

            {}
          end
        end
      end
    end
  end
end
