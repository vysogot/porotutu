# frozen_string_literal: true

module Porotutu
  module Conflicts
    class EditView < PhlexView
      include PathsHelper
      include DomIdsHelper

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
            main { frame }
          end
        else
          frame
        end
      end

      private

      def frame
        tag(:'turbo-frame', id: conflict_frame_id(@conflict)) { edit_article }
      end

      def edit_article
        article do
          header { h3 { t('conflicts.edit.title') } }
          render form_component
        end
      end

      def form_component
        FormView.new(
          csrf_token: @csrf_token,
          action: conflict_path(@conflict),
          method: 'patch',
          cancel_href: conflict_path(@conflict),
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
