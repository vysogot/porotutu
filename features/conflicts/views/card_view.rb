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
          article(class: 'tile') do
            card_header
            p(class: 'tile__body') { @conflict.description } unless @conflict.description.nil?
            draft_actions if @conflict.status == 'draft'
          end
        end
      end

      private

      def card_header
        header(class: 'tile__header') do
          h3(class: 'tile__title') do
            a(href: conflict_path(@conflict), data: { 'turbo-frame': '_top' }) { @conflict.title }
          end
          span(class: 'badge') { t('conflicts.card.favor_label', favor: @conflict.favor) } if @conflict.favor
        end
      end

      def draft_actions
        footer(class: 'tile__footer') do
          a(href: edit_conflict_path(@conflict), class: 'btn btn--ghost') do
            t('conflicts.card.edit_button')
          end
          delete_form
        end
      end

      def delete_form
        protected_form(method: 'delete', action: conflict_path(@conflict), data: { 'turbo-frame': '_top' }) do
          button(type: 'submit', class: 'btn btn--danger') { t('conflicts.card.delete_button') }
        end
      end
    end
  end
end
