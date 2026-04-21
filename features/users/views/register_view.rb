# frozen_string_literal: true

module Porotutu
  module Users
    class RegisterView < PhlexView
      include PathsHelper

      def view_template
        render Porotutu::Layout.new(csrf_token: @csrf_token, show_nav: false) do
          main { article { register_card } }
        end
      end

      private

      def register_card
        h2 { t('users.register.heading') }
        register_form
        p { a(href: login_path) { t('users.register.login_link') } }
      end

      def register_form
        protected_form(action: users_path, method: 'post', data: { turbo: 'false' }) do
          labeled_input(:email, label_text: t('users.register.email_label'), type: 'email', required: true)
          labeled_input(:password, label_text: t('users.register.password_label'), type: 'password', required: true)
          button(type: 'submit') { t('users.register.submit_button') }
        end
      end
    end
  end
end
