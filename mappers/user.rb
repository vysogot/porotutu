# frozen_string_literal: true

module Mappers
  User = Data.define(
    :id,
    :email,
    :password_digest,
  ) do
    def self.from_row(row)
      new(
        id: row['id'],
        email: row['email'],
        password_digest: row['password_digest']
      )
    end
  end
end
