# frozen_string_literal: true

require 'sinatra'
require 'require_all'
require 'pg'

set :public_folder, "#{File.dirname(__FILE__)}/public"

require_rel 'patterns'
require_rel 'features'

class App < Sinatra::Base
  include Conflicts::Helpers::Paths

  get '/' do
    locals = Conflicts::Handlers::Home.call

    conflicts_erb :home, locals:
  end

  get '/new' do
    conflicts_erb :new
  end

  post '/conflicts' do
    locals = Conflicts::Handlers::Create.call(params:)

    content_type 'text/vnd.turbo-stream.html'
    conflicts_erb :create, locals:
  end

  get '/:id/edit' do
    locals = Conflicts::Handlers::Edit.call(params:)

    conflicts_erb :edit, locals:
  end

  put '/:id' do
    locals = Conflicts::Handlers::Update.call(params:)

    conflicts_erb :show, locals:
  end

  delete '/:id' do
    locals = Conflicts::Handlers::Delete.call(params:)

    content_type 'text/vnd.turbo-stream.html'
    conflicts_erb :delete, locals:
  end
end
