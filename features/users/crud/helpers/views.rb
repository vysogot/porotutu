# frozen_string_literal: true

module Porotutu
  module Users
    module Crud
      module Helpers
        module Views
          include Patterns::Views

          VIEWS_DIR = File.expand_path('../views', __dir__)

          def users_erb(view, **)
            feature_erb(VIEWS_DIR, view, **)
          end
        end
      end
    end
  end
end
