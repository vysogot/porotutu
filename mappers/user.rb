# frozen_string_literal: true

module Porotutu
  module Mappers
    User = Data.define(
      :id,
      :email,
      :created_at,
      :updated_at
    ) do
      def self.from_row(row)
        new(
          id: row['id'],
          email: row['email'],
          created_at: row['created_at'],
          updated_at: row['updated_at']
        )
      end
    end
  end
end
