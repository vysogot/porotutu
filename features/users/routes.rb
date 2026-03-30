# frozen_string_literal: true

module Users
  class Routes < Sinatra::Base
    include Helpers::Paths

    get '/register' do
      users_erb :new
    end

    post '/users' do
      Handlers::Create.call(params:)

      redirect '/login'
    end
  end
end
