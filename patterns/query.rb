# frozen_string_literal: true

module Patterns
  module Query
    def call_function(name, args = [])
      placeholders = Array.new(args.length) { |i| "$#{i + 1}" }.join(', ')
      sql = "SELECT * FROM #{name}(#{placeholders})"

      DB.with { |conn| conn.exec_params(sql, args) }
    end
  end
end
