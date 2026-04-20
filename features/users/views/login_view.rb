# frozen_string_literal: true

module Porotutu
  module Users
    class LoginView < PhlexView
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
        h2 { t('users.auth.new.heading') }
        p { @error } if @error
        login_form
        p { a(href: '/register') { t('users.auth.new.register_link') } }
      end

      def login_form
        form(action: '/session', method: 'post', data: { turbo: 'false' }) do
          csrf_field
          labeled_input(t('users.auth.new.email_label'), type: 'email', name: 'email', required: true)
          labeled_input(t('users.auth.new.password_label'), type: 'password', name: 'password', required: true)
          button(type: 'submit') { t('users.auth.new.submit_button') }
        end
      end
    end
  end
end
