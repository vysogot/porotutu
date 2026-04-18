# frozen_string_literal: true

module Users
  module Auth
    module Helpers
      module Views
        include Patterns::Views

        VIEWS_DIR = File.expand_path('../views', __dir__)

        def auth_erb(view, **options)
          feature_erb(VIEWS_DIR, view, **options)
        end
      end
    end
  end
end
