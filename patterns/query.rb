# frozen_string_literal: true

module Porotutu
  module Patterns
    module Query
      def call_function(name, args = {})
        bindings = args.keys.each_with_index.map { |k, i| "#{k} => $#{i + 1}" }.join(', ')
        sql = "SELECT * FROM #{name}(#{bindings})"

        Db.with { |conn| conn.exec_params(sql, args.values) }
      end
    end
  end
end
