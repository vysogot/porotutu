# frozen_string_literal: true

module Porotutu
  module Conflicts
    class IndexView < PhlexView
      def initialize(drafts:, **attrs)
        @drafts = drafts
        super(**attrs)
      end

      def view_template
        render Porotutu::Layout.new(csrf_token: @csrf_token) do
          main(class: 'container', id: 'conflicts-container') do
            page_header
            @drafts.empty? ? empty_state : drafts_section
          end
        end
      end

      private

      def page_header
        header(class: 'container') do
          hgroup do
            h1 { t('conflicts.crud.index.heading') }
            p { t('conflicts.crud.index.subheading') }
            nav do
              a(href: '/conflicts/new', role: 'button', class: 'outline') do
                t('conflicts.crud.index.new_button')
              end
            end
          end
        end
      end

      def empty_state
        article { p { t('conflicts.crud.index.empty') } }
      end

      def drafts_section
        section(id: 'conflicts-drafts-section') do
          h2 { t('conflicts.crud.index.drafts_heading') }
          div(id: 'conflicts-drafts') do
            @drafts.each { |conflict| render CardView.new(conflict:, csrf_token: @csrf_token) }
          end
        end
      end
    end
  end
end
