# frozen_string_literal: true

module Porotutu
  module Users
    class Routes < Sinatra::Base
      include ViewsHelper
      include SessionHelper

      get '/register' do
        view :register
      end

      post '/users' do
        CreateHandler.call(params:)

        redirect '/login'
      end

      get '/login' do
        view :login, locals: { error: nil }
      end

      post '/session' do
        locals = LoginHandler.call(params:)

        session['user_id'] = locals[:user].id
        redirect post_login_path, 303
      rescue InvalidCredentials => e
        view :login, locals: { error: e.message }
      end

      post '/logout' do
        session.clear
        redirect '/login'
      end
    end
  end
end
