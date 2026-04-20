# frozen_string_literal: true

require 'zeitwerk'
require 'sinatra'
require 'sinatra/reloader'
require 'bcrypt'
require 'pg'
require 'debug'

module Porotutu; end

loader = Zeitwerk::Loader.new
loader.push_dir(__dir__, namespace: Porotutu)
loader.collapse("#{__dir__}/lib")
loader.collapse("#{__dir__}/lib/*")
loader.collapse("#{__dir__}/features")
loader.collapse("#{__dir__}/features/*/{services,handlers,validators,helpers,errors,mappers}")
loader.ignore(
  "#{__dir__}/app.rb",
  "#{__dir__}/bin",
  "#{__dir__}/tasks",
  "#{__dir__}/tests",
  "#{__dir__}/db",
  "#{__dir__}/ksiaki",
  "#{__dir__}/public",
  "#{__dir__}/layouts",
  "#{__dir__}/partials",
  "#{__dir__}/locales"
)
loader.setup

module Sinatra # rubocop:disable Style/OneClassPerFile
  class Base
    set :turbo_stream, 'text/vnd.turbo-stream.html'
  end
end

module Porotutu # rubocop:disable Style/OneClassPerFile
  class App < Sinatra::Base
    configure :development do
      register Sinatra::Reloader
      also_reload File.join(__dir__, 'lib/**/*.rb')
      also_reload File.join(__dir__, 'features/**/*.rb')
    end

    set :public_folder, File.join(__dir__, 'public')

    enable :sessions
    set :session_secret, ENV.fetch('SESSION_SECRET')
    set :sessions, key: 'porotutu.session', httponly: true, same_site: :lax

    use CsrfProtection
    use Authentication

    use Users::Routes
    use Conflicts::Routes

    get '/' do
      redirect '/conflicts'
    end
  end
end
