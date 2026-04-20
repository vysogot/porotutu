# frozen_string_literal: true

module Porotutu
  module Conflicts
    class UpdateView < PhlexView
      def initialize(conflict:, **attrs)
        @conflict = conflict
        super(**attrs)
      end

      def view_template
        tag(:'turbo-stream', action: 'replace', target: "conflict-#{@conflict.id}") do
          template do
            render CardView.new(conflict: @conflict, csrf_token: @csrf_token)
          end
        end
      end
    end
  end
end
