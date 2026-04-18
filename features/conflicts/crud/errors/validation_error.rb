# frozen_string_literal: true

module Porotutu
  module Conflicts
    module Crud
      module Errors
        class ValidationError < StandardError
          attr_reader :errors

          def initialize(errors)
            @errors = errors
            super('Validation failed')
          end
        end
      end
    end
  end
end
