# frozen_string_literal: true

module Porotutu
  module Conflicts
    class Routes < Sinatra::Base
      include ViewsHelper

      get '/conflicts' do
        locals = IndexHandler.call(current_user_id: session['user_id'])

        view :index, locals:
      end

      get '/conflicts/new' do
        view :new
      end

      get '/conflicts/:id' do
        locals = ShowHandler.call(params:, current_user_id: session['user_id'])

        view :show, locals:
      end

      get '/conflicts/:id/edit' do
        locals = EditHandler.call(params:, current_user_id: session['user_id'])

        view :edit, locals:
      end

      post '/conflicts' do
        locals = CreateHandler.call(params:, current_user_id: session['user_id'])

        redirect "/conflicts/#{locals[:conflict].id}", 303
      rescue ValidationError => e
        view :new, locals: { errors: e.errors, params: }
      end

      patch '/conflicts/:id' do
        locals = UpdateHandler.call(params:)

        content_type settings.turbo_stream
        view :update, layout: false, locals:
      rescue ValidationError => e
        locals = EditHandler.call(params:, current_user_id: session['user_id'])
        view :edit, locals: locals.merge(errors: e.errors, params:)
      end

      delete '/conflicts/:id' do
        DeleteHandler.call(params:, current_user_id: session['user_id'])

        redirect '/conflicts', 303
      end
    end
  end
end
