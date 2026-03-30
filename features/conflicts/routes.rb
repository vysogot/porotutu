# frozen_string_literal: true

module Conflicts
  class Routes < Sinatra::Base
    include Helpers::Paths

    get '/' do
      locals = Handlers::Home.call

      conflicts_erb :home, locals:
    end

    get '/new' do
      conflicts_erb :new
    end

    post '/conflicts' do
      locals = Handlers::Create.call(params:)

      content_type 'text/vnd.turbo-stream.html'
      conflicts_erb :create, locals:
    end

    get '/:id/edit' do
      locals = Handlers::Edit.call(params:)

      conflicts_erb :edit, locals:
    end

    put '/:id' do
      locals = Handlers::Update.call(params:)

      conflicts_erb :show, locals:
    end

    delete '/:id' do
      locals = Handlers::Delete.call(params:)

      content_type 'text/vnd.turbo-stream.html'
      conflicts_erb :delete, locals:
    end
  end
end
