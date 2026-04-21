# frozen_string_literal: true

require_relative 'lib/initializers/suppress_phlex_warnings'

require 'sinatra'
require 'sinatra/reloader'
require 'bcrypt'
require 'pg'
require 'debug'

module Porotutu; end

require_relative 'lib/initializers/zeitwerk'
Porotutu::Zeitwerk.setup(root: __dir__)
Porotutu::StyleBundler.build unless Porotutu::Env.public?

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

    enable :method_override
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
