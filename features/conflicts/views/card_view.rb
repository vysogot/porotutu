# frozen_string_literal: true

module Porotutu
  module Conflicts
    class CardView < PhlexView
      include PathsHelper
      include DomIdsHelper

      def initialize(conflict:, **attrs)
        @conflict = conflict
        super(**attrs)
      end

      def view_template
        tag(:'turbo-frame', id: conflict_frame_id(@conflict)) do
          article do
            card_header
            p { @conflict.description } unless @conflict.description.nil?
            draft_actions if @conflict.status == 'draft'
          end
        end
      end

      private

      def card_header
        header do
          h3 { a(href: conflict_path(@conflict), data: { 'turbo-frame': '_top' }) { @conflict.title } }
          small { t('conflicts.card.favor_label', favor: @conflict.favor) } if @conflict.favor
        end
      end

      def draft_actions
        footer do
          div(class: 'grid') do
            a(href: edit_conflict_path(@conflict), role: 'button', class: 'outline') do
              t('conflicts.card.edit_button')
            end
            delete_form
          end
        end
      end

      def delete_form
        protected_form(method: 'delete', action: conflict_path(@conflict), data: { 'turbo-frame': '_top' }) do
          button(type: 'submit', class: 'secondary outline') { t('conflicts.card.delete_button') }
        end
      end
    end
  end
end
