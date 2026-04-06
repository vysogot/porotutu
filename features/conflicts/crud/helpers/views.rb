# frozen_string_literal: true

module Conflicts
  module Crud
    module Helpers
      module Views
        include Patterns::Views

        VIEWS_DIR = File.expand_path('../views', __dir__)

        def view(view_name, **options)
          feature_erb(VIEWS_DIR, view_name, **options)
        end
      end
    end
  end
end
