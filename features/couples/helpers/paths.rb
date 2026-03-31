# frozen_string_literal: true

module Couples
  module Helpers
    module Paths
      include Patterns::Views

      VIEWS_DIR = File.expand_path('../views', __dir__)

      def couples_erb(view, **options)
        feature_erb(VIEWS_DIR, view, **options)
      end
    end
  end
end
