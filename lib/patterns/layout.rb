# frozen_string_literal: true

module Porotutu
  class Layout < PhlexView
    def initialize(title: nil, show_nav: true, **attrs)
      @title = title
      @show_nav = show_nav
      super(**attrs)
    end

    THEME_INIT_SCRIPT = <<~JS
      (function(){try{var t=localStorage.getItem('porotutu.theme');if(!t){t=window.matchMedia('(prefers-color-scheme: dark)').matches?'dark':'light';}document.documentElement.dataset.theme=t;}catch(e){document.documentElement.dataset.theme='light';}})();
    JS

    def view_template(&)
      doctype
      html(lang: 'en') do
        head do
          meta(charset: 'utf-8')
          meta(name: 'viewport', content: 'width=device-width, initial-scale=1')
          meta(name: 'description', content: 'A place to build your conflicts. Good conflicts.')
          link(rel: 'icon', type: 'image/png', sizes: '48x48', href: '/favicon.ico')
          title { @title || t('layouts.main.default_title') }
          link(rel: 'stylesheet', href: '/stylesheets/app.css')
          script { raw safe(THEME_INIT_SCRIPT) }
          script(type: 'module') do
            raw safe("import hotwiredTurbo from 'https://cdn.skypack.dev/@hotwired/turbo@7.3.0';")
          end
        end
        body do
          render_nav if @show_nav
          yield
          script(src: '/javascript/theme.js')
          script(type: 'module', src: '/javascript/application.js')
        end
      end
    end

    private

    def render_nav
      nav(class: 'nav') do
        div(class: 'nav__inner') do
          a(href: '/conflicts', class: 'nav__brand') { t('layouts.main.nav_conflicts') }
          div(class: 'nav__actions') do
            render_theme_toggle
            form(action: '/logout', method: 'post', data: { turbo: 'false' }) do
              csrf_field
              button(type: 'submit', class: 'btn btn--ghost') { t('layouts.main.logout_button') }
            end
          end
        end
      end
    end

    def render_theme_toggle
      button(
        type: 'button',
        class: 'btn btn--ghost btn--icon',
        'aria-label': t('layouts.main.theme_toggle_label'),
        data: { theme_toggle: true }
      ) do
        span(class: 'theme-toggle__sun', 'aria-hidden': 'true') { '☾' }
        span(class: 'theme-toggle__moon', 'aria-hidden': 'true') { '☀' }
      end
    end
  end
end
