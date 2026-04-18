# frozen_string_literal: true

module Porotutu
  module Users
    module Auth
      module Errors
        class InvalidCredentials < StandardError
          def initialize
            super('Invalid email or password.')
          end
        end
      end
    end
  end
end
