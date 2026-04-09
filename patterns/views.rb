# frozen_string_literal: true

module Patterns
  module Views
    LAYOUTS_DIR = File.expand_path('../layouts', __dir__)
    PARTIALS_DIR = File.expand_path('../partials', __dir__)

    def feature_erb(views_dir, view, **options)
      erb view, { layout: :main, layout_options: { views: LAYOUTS_DIR } }
        .merge(options)
        .merge(views: views_dir)
    end

    def field_error(field, errors: nil)
      erb :field_error, views: PARTIALS_DIR, layout: false, locals: { field:, errors: }
    end
  end
end
