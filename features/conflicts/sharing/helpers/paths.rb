# frozen_string_literal: true

module Conflicts
  module Helpers
    module Paths
      include Patterns::Views

      VIEWS_DIR = File.expand_path('../views', __dir__)

      def view(view_name, **options)
        feature_erb(VIEWS_DIR, view_name, **options)
      end
    end
  end
end
