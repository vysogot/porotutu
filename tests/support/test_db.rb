# frozen_string_literal: true

module Porotutu
  module Tests
    module TestDb
      def self.fetch_one(sql, params = [])
        Thread.current[:porotutu_pinned_conn].exec_params(sql, params).first
      end
    end
  end
end
