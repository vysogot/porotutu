# frozen_string_literal: true

require 'dotenv/load'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << '.'
  t.pattern = 'tests/**/*_test.rb'
end

Rake.add_rakelib 'lib/tasks'
