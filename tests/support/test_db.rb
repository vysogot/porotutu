# frozen_string_literal: true

module Porotutu
  module Tests
    module TestDb
      def self.conn
        Thread.current[:porotutu_pinned_conn]
      end

      def self.fetch_one(sql, params = [])
        conn.exec_params(sql, params).first
      end
    end
  end
end
