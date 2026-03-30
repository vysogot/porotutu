# frozen_string_literal: true

require 'dotenv/load'
require_relative 'app'

use Rack::Session::Cookie,
  key: 'porotutu.session',
  secret: ENV.fetch('SESSION_SECRET', 'dev_secret_change_in_production_must_be_at_least_64_bytes_long!!'),
  httponly: true,
  same_site: :lax

use Patterns::Authentication

run App
