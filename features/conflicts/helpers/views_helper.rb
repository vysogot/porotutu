# frozen_string_literal: true

module Porotutu
  module Conflicts
    module ViewsHelper
      include Patterns::Views

      VIEWS_DIR = File.expand_path('../views', __dir__)

      def view(view_name, **)
        feature_erb(VIEWS_DIR, view_name, **)
      end
    end
  end
end
