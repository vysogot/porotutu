# frozen_string_literal: true

module Porotutu
  module Conflicts
    class CardView < PhlexView
      def initialize(conflict:, **attrs)
        @conflict = conflict
        super(**attrs)
      end

      def view_template
        tag(:'turbo-frame', id: "conflict-#{@conflict.id}") do
          article do
            card_header
            p { @conflict.description } if @conflict.description && !@conflict.description.empty?
            draft_actions if @conflict.status == 'draft'
          end
        end
      end

      private

      def card_header
        header do
          h3 { a(href: "/conflicts/#{@conflict.id}", data: { 'turbo-frame': '_top' }) { @conflict.title } }
          small { t('conflicts.crud.card.favor_label', favor: @conflict.favor) } if @conflict.favor
        end
      end

      def draft_actions
        footer do
          div(class: 'grid') do
            a(href: "/conflicts/#{@conflict.id}/edit", role: 'button', class: 'outline') do
              t('conflicts.crud.card.edit_button')
            end
            delete_form
          end
        end
      end

      def delete_form
        form(method: 'delete', action: "/conflicts/#{@conflict.id}", data: { 'turbo-frame': '_top' }) do
          csrf_field
          button(type: 'submit', class: 'secondary outline') { t('conflicts.crud.card.delete_button') }
        end
      end
    end
  end
end
