# frozen_string_literal: true

module Porotutu
  module Conflicts
    module Crud
      module Validators
        class Conflict
          extend Patterns::Service
          include Patterns::Validations

          TITLE_MAX = 100
          DESCRIPTION_MAX = 1000
          FAVOR_MAX = 100

          def call(params:)
            errors = {}

            validate_presence(errors, params, :title, :description, :favor)
            validate_length(errors, params[:title], :title, TITLE_MAX)
            validate_length(errors, params[:description], :description, DESCRIPTION_MAX)
            validate_length(errors, params[:favor], :favor, FAVOR_MAX)

            raise Errors::ValidationError, errors if errors.any?
          end
        end
      end
    end
  end
end
