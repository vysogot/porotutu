# frozen_string_literal: true

module Conflicts
  module Crud
    class Routes < Sinatra::Base
      include Helpers::Views

      get '/conflicts' do
        locals = Handlers::Index.call(current_user_id: session['user_id'])

        view :index, locals:
      end

      get '/conflicts/new' do
        view :new
      end

      get '/conflicts/:id' do
        locals = Handlers::Show.call(params:, current_user_id: session['user_id'])

        view :show, locals:
      end

      get '/conflicts/:id/edit' do
        locals = Handlers::Edit.call(params:, current_user_id: session['user_id'])

        view :edit, locals:
      end

      post '/conflicts' do
        locals = Handlers::Create.call(params:, current_user_id: session['user_id'])

        redirect "/conflicts/#{locals[:conflict].id}", 303
      rescue Errors::ValidationError => e
        view :new, locals: { errors: e.errors, params: }
      end

      patch '/conflicts/:id' do
        locals = Handlers::Update.call(params:)

        content_type settings.turbo_stream
        view :update, layout: false, locals:
      rescue Errors::ValidationError => e
        locals = Handlers::Edit.call(params:, current_user_id: session['user_id'])
        view :edit, locals: locals.merge(errors: e.errors, params:)
      end

      delete '/conflicts/:id' do
        Handlers::Delete.call(params:, current_user_id: session['user_id'])

        redirect '/conflicts', 303
      end
    end
  end
end
