# frozen_string_literal: true

module Porotutu
  module Conflicts
    class ShowView < PhlexView
      include PathsHelper

      def initialize(conflict:, **attrs)
        @conflict = conflict
        super(**attrs)
      end

      def view_template
        render Porotutu::Layout.new(csrf_token: @csrf_token) do
          main(class: 'container') do
            nav('aria-label': 'breadcrumb') do
              a(href: conflicts_path) { t('conflicts.show.back') }
            end
            render CardView.new(conflict: @conflict, csrf_token: @csrf_token)
          end
        end
      end
    end
  end
end
