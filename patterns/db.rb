# frozen_string_literal: true

require 'connection_pool'

module DB
  POOL_SIZE = Integer(ENV.fetch('DB_POOL_SIZE', 5))
  POOL_TIMEOUT = Integer(ENV.fetch('DB_POOL_TIMEOUT', 5))

  def self.pool
    @pool ||= ConnectionPool.new(size: POOL_SIZE, timeout: POOL_TIMEOUT) do
      conn = PG.connect(ENV.fetch('DATABASE_URL'))
      conn.type_map_for_results = PG::BasicTypeMapForResults.new(conn)
      conn
    end
  end

  def self.with(&block)
    pool.with(&block)
  end
end
