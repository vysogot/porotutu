# frozen_string_literal: true

require 'zeitwerk'

module Porotutu
  module Zeitwerk
    def self.setup(root:, extra_ignores: [])
      loader = ::Zeitwerk::Loader.new
      loader.push_dir(root, namespace: Porotutu)
      loader.collapse("#{root}/lib")
      loader.collapse("#{root}/lib/*")
      loader.collapse("#{root}/features")
      loader.collapse("#{root}/features/*/{services,handlers,validators,helpers,errors,mappers,views}")
      loader.ignore(
        "#{root}/app.rb",
        "#{root}/bin",
        "#{root}/tasks",
        "#{root}/tests",
        "#{root}/db",
        "#{root}/ksiaki",
        "#{root}/public",
        "#{root}/locales",
        "#{root}/lib/initializers",
        "#{root}/lib/styles",
        *extra_ignores
      )
      loader.setup
      loader
    end
  end
end
