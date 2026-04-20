# frozen_string_literal: true

module Porotutu
  module Conflicts
    class FormView < PhlexView
      TITLE_MAX = 100
      DESCRIPTION_MAX = 1000
      FAVOR_MAX = 100

      def initialize(action:, method:, t_scope:, values:, cancel_href:, errors: nil, **attrs)
        @action = action
        @method = method
        @t_scope = t_scope
        @values = values
        @errors = errors
        @cancel_href = cancel_href
        super(**attrs)
      end

      def view_template
        form(action: @action, method: form_method) do
          input(type: 'hidden', name: '_method', value: @method) if method_override?
          csrf_field

          text_field(:title, autofocus: true, max: TITLE_MAX)
          textarea_field(:description, max: DESCRIPTION_MAX, rows: 4)
          text_field(:favor, max: FAVOR_MAX)

          div(class: 'grid') do
            button(type: 'submit') { ts('submit_button') }
            a(href: @cancel_href, role: 'button', class: 'secondary outline') { ts('cancel_button') }
          end
        end
      end

      private

      def form_method = method_override? ? 'post' : @method
      def method_override? = @method == 'patch'

      def ts(key) = t("conflicts.crud.#{@t_scope}.#{key}")

      def text_field(name, max:, autofocus: false)
        label(for: name) do
          plain ts("#{name}_label")
          input(
            **{
              type: 'text',
              id: name,
              name: name,
              value: @values[name],
              maxlength: max,
              placeholder: placeholder_for(name),
              autofocus: autofocus || nil
            }.compact
          )
          field_error(name, errors: @errors)
        end
      end

      def textarea_field(name, max:, rows:)
        label(for: name) do
          plain ts("#{name}_label")
          textarea(
            **{
              id: name,
              name: name,
              maxlength: max,
              rows: rows,
              placeholder: placeholder_for(name)
            }.compact
          ) { @values[name] }
          field_error(name, errors: @errors)
        end
      end

      def placeholder_for(name)
        value = Translations.t("conflicts.crud.#{@t_scope}.#{name}_placeholder")
        value.start_with?('TRANSLATE!!') ? nil : value
      end
    end
  end
end
