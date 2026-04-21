# frozen_string_literal: true

module Porotutu
  module Users
    class LoginView < PhlexView
      include PathsHelper

      def initialize(error: nil, **attrs)
        @error = error
        super(**attrs)
      end

      def view_template
        render Porotutu::Layout.new(csrf_token: @csrf_token, show_nav: false) do
          main(class: 'page') do
            article(class: 'card') { login_card }
          end
        end
      end

      private

      def login_card
        h1(class: 'card__title') { t('users.login.heading') }
        div(role: 'alert', class: 'alert') { @error } if @error
        login_form
        p(class: 'card__footer') do
          a(href: register_path, class: 'link--accent') { t('users.login.register_link') }
        end
      end

      def login_form
        protected_form(action: session_path, method: 'post', data: { turbo: 'false' }, class: 'form') do
          labeled_input(:email, label_text: t('users.login.email_label'), type: 'email', required: true, autofocus: true)
          labeled_input(:password, label_text: t('users.login.password_label'), type: 'password', required: true)
          button(type: 'submit', class: 'btn btn--primary') { t('users.login.submit_button') }
        end
      end
    end
  end
end
