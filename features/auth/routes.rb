# frozen_string_literal: true

module Auth
  class Routes < Sinatra::Base
    include Helpers::Views

    get '/login' do
      auth_erb :new, locals: { error: nil }
    end

    post '/session' do
      locals = Handlers::Login.call(params:)

      session['user_id'] = locals[:user].id
      redirect '/conflicts', 303
    rescue Errors::InvalidCredentials => e
      auth_erb :new, locals: { error: e.message }
    end

    post '/logout' do
      session.clear
      redirect '/login'
    end
  end
end
