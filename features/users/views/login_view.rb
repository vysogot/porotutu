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
          main(class: 'container') { article { login_card } }
        end
      end

      private

      def login_card
        h2 { t('users.login.heading') }
        p { @error } if @error
        login_form
        p { a(href: register_path) { t('users.login.register_link') } }
      end

      def login_form
        form(action: session_path, method: 'post', data: { turbo: 'false' }) do
          csrf_field
          labeled_input(t('users.login.email_label'), type: 'email', name: 'email', required: true)
          labeled_input(t('users.login.password_label'), type: 'password', name: 'password', required: true)
          button(type: 'submit') { t('users.login.submit_button') }
        end
      end
    end
  end
end
