# frozen_string_literal: true

module Porotutu
  module Conflicts
    class NewView < PhlexView
      def initialize(params: {}, errors: nil, **attrs)
        @params = params
        @errors = errors
        super(**attrs)
      end

      def view_template
        render Porotutu::Layout.new(csrf_token: @csrf_token) do
          main(class: 'container', id: 'new_conflict_frame') do
            h2 { t('conflicts.crud.new.title') }
            render FormView.new(
              csrf_token: @csrf_token,
              action: '/conflicts',
              method: 'post',
              t_scope: 'new',
              values: { title: @params[:title], description: @params[:description], favor: @params[:favor] },
              errors: @errors,
              cancel_href: '/conflicts'
            )
          end
        end
      end
    end
  end
end
