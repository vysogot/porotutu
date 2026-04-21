# frozen_string_literal: true

module Porotutu
  module Conflicts
    class IndexView < PhlexView
      include PathsHelper

      def initialize(drafts:, **attrs)
        @drafts = drafts
        super(**attrs)
      end

      def view_template
        render Porotutu::Layout.new(csrf_token: @csrf_token) do
          main(id: 'conflicts-container', class: 'container') do
            page_header
            @drafts.empty? ? empty_state : drafts_section
          end
        end
      end

      private

      def page_header
        header(class: 'page-header') do
          div do
            h1(class: 'page-header__title') { t('conflicts.index.heading') }
            p(class: 'page-header__subtitle') { t('conflicts.index.subheading') }
          end
          div(class: 'page-header__actions') do
            a(href: new_conflict_path, class: 'btn btn--primary btn--auto') do
              t('conflicts.index.new_button')
            end
          end
        end
      end

      def empty_state
        div(class: 'empty-state') { p { t('conflicts.index.empty') } }
      end

      def drafts_section
        section(id: 'conflicts-drafts-section') do
          h2(class: 'section-title') { t('conflicts.index.drafts_heading') }
          div(id: 'conflicts-drafts', class: 'grid') do
            @drafts.each do |conflict|
              render CardView.new(conflict:, csrf_token: @csrf_token)
            end
          end
        end
      end
    end
  end
end
