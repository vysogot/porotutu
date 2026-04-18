# frozen_string_literal: true

require 'connection_pool'

module Porotutu
  module Patterns
    module Db
      POOL_SIZE = Integer(ENV.fetch('DB_POOL_SIZE', 5))
      POOL_TIMEOUT = Integer(ENV.fetch('DB_POOL_TIMEOUT', 5))

      def self.pool
        @pool ||= ConnectionPool.new(size: POOL_SIZE, timeout: POOL_TIMEOUT) do
          conn = PG.connect(ENV.fetch('DATABASE_URL'))
          type_map = PG::BasicTypeMapForResults.new(conn)
          type_map.add_coder(PG::TextDecoder::String.new(name: 'uuid', oid: 2950))
          conn.type_map_for_results = type_map
          conn
        end
      end

      def self.with(&)
        pool.with(&)
      end
    end
  end
end
