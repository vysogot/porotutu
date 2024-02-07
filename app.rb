# frozen_string_literal: true

require 'sinatra'
require 'require_all'
require 'sinatra/activerecord'

set :database, { adapter: 'sqlite3', database: 'sqlite3:porotutu.sqlite3' }
set :public_folder, "#{File.dirname(__FILE__)}/public"

require_rel 'patterns'
require_rel 'features'

class App < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  include Habits::Helpers::Paths

  get '/' do
    locals = Habits::Handlers::Home.call

    habits_erb :home, locals:
  end

  get '/new' do
    habits_erb :new
  end

  post '/habits' do
    locals = Habits::Handlers::Create.call(params:)

    content_type 'text/vnd.turbo-stream.html'
    habits_erb :create, locals:
  end

  get '/:id/edit' do
    locals = Habits::Handlers::Edit.call(params:)

    habits_erb :edit, locals:
  end

  put '/:id' do
    locals = Habits::Handlers::Update.call(params:)

    habits_erb :show, locals:
  end

  delete '/:id' do
    locals = Habits::Handlers::Delete.call(params:)

    content_type 'text/vnd.turbo-stream.html'
    habits_erb :delete, locals:
  end
end
