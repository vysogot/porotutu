# frozen_string_literal: true

module Porotutu
  module Users
    class RegisterView < PhlexView
      include PathsHelper

      def view_template
        render Porotutu::Layout.new(csrf_token: @csrf_token, show_nav: false) do
          main(class: 'page') do
            article(class: 'card') { register_card }
          end
        end
      end

      private

      def register_card
        h1(class: 'card__title') { t('users.register.heading') }
        register_form
        p(class: 'card__footer') do
          a(href: login_path, class: 'link--accent') { t('users.register.login_link') }
        end
      end

      def register_form
        protected_form(action: users_path, method: 'post', data: { turbo: 'false' }, class: 'form') do
          labeled_input(:email, label_text: t('users.register.email_label'), type: 'email', required: true,
                                autofocus: true)
          labeled_input(:password, label_text: t('users.register.password_label'), type: 'password', required: true)
          button(type: 'submit', class: 'btn btn--primary') { t('users.register.submit_button') }
        end
      end
    end
  end
end
