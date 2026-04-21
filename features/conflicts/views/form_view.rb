# frozen_string_literal: true

module Porotutu
  module Conflicts
    class FormView < PhlexView
      TITLE_MAX = 100
      DESCRIPTION_MAX = 1000
      FAVOR_MAX = 100

      def initialize(action:, method:, values:, cancel_href:, errors: nil, **attrs)
        @action = action
        @method = method
        @values = values
        @errors = errors
        @cancel_href = cancel_href
        super(**attrs)
      end

      def view_template
        protected_form(action: @action, method: form_method) do
          input(type: 'hidden', name: '_method', value: @method) if method_override?

          labeled_input(
            :title,
            label_text: t('conflicts.form.title_label'),
            value: @values[:title],
            maxlength: TITLE_MAX,
            placeholder: t('conflicts.form.title_placeholder'),
            autofocus: true,
            errors: @errors
          )
          labeled_textarea(
            :description,
            label_text: t('conflicts.form.description_label'),
            value: @values[:description],
            maxlength: DESCRIPTION_MAX,
            rows: 4,
            placeholder: t('conflicts.form.description_placeholder'),
            errors: @errors
          )
          labeled_input(
            :favor,
            label_text: t('conflicts.form.favor_label'),
            value: @values[:favor],
            maxlength: FAVOR_MAX,
            placeholder: t('conflicts.form.favor_placeholder'),
            errors: @errors
          )

          div do
            button(type: 'submit') { t('conflicts.form.submit_button') }
            a(href: @cancel_href) { t('conflicts.form.cancel_button') }
          end
        end
      end

      private

      def form_method = method_override? ? 'post' : @method
      def method_override? = @method == 'patch'
    end
  end
end
