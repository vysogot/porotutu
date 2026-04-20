# frozen_string_literal: true

module Porotutu
  module Conflicts
    class EditView < PhlexView
      def initialize(conflict:, params: {}, errors: nil, layout: true, **attrs)
        @conflict = conflict
        @params = params
        @errors = errors
        @layout = layout
        super(**attrs)
      end

      def view_template
        if @layout
          render Porotutu::Layout.new(csrf_token: @csrf_token) do
            main(class: 'container') { frame }
          end
        else
          frame
        end
      end

      private

      def frame
        tag(:'turbo-frame', id: "conflict-#{@conflict.id}") { edit_article }
      end

      def edit_article
        article do
          header { h3 { t('conflicts.crud.edit.title') } }
          render form_component
        end
      end

      def form_component
        FormView.new(
          csrf_token: @csrf_token,
          action: "/conflicts/#{@conflict.id}",
          method: 'patch',
          t_scope: 'edit',
          cancel_href: "/conflicts/#{@conflict.id}",
          values: {
            title: @params[:title] || @conflict.title,
            description: @params[:description] || @conflict.description,
            favor: @params[:favor] || @conflict.favor
          },
          errors: @errors
        )
      end
    end
  end
end
