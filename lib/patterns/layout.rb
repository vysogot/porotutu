# frozen_string_literal: true

module Porotutu
  class Layout < PhlexView
    def initialize(title: nil, show_nav: true, **attrs)
      @title = title
      @show_nav = show_nav
      super(**attrs)
    end

    def view_template(&)
      doctype
      html(lang: 'en') do
        head do
          meta(charset: 'utf-8')
          meta(name: 'viewport', content: 'width=device-width, initial-scale=1')
          meta(name: 'description', content: 'A place to build your conflicts. Good conflicts.')
          link(rel: 'icon', type: 'image/png', sizes: '48x48', href: '/favicon.ico')
          title { @title || t('layouts.main.default_title') }
          link(rel: 'stylesheet', href: 'https://cdn.jsdelivr.net/npm/@picocss/pico@1/css/pico.min.css')
          script(type: 'module') do
            raw safe("import hotwiredTurbo from 'https://cdn.skypack.dev/@hotwired/turbo@7.3.0';")
          end
        end
        body do
          render_nav if @show_nav
          yield
          script(type: 'module', src: '/javascript/application.js')
        end
      end
    end

    private

    def render_nav
      nav(class: 'container') do
        ul { li { a(href: '/conflicts') { t('layouts.main.nav_conflicts') } } }
        ul do
          li do
            form(action: '/logout', method: 'post', data: { turbo: 'false' }) do
              csrf_field
              button(type: 'submit', class: 'outline') { t('layouts.main.logout_button') }
            end
          end
        end
      end
    end
  end
end
