# frozen_string_literal: true

namespace :styles do
  desc 'Concatenate styles/**/*.css into public/stylesheets/app.css'
  task :build do
    require_relative '../lib/infra/style_bundler'
    output = Porotutu::StyleBundler.build
    puts "Wrote #{output}"
  end
end
