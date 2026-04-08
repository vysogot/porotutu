# frozen_string_literal: true

module DB
  def self.connection
    @connection ||= PG.connect(
      ENV.fetch('DATABASE_URL')
    )
  end
end
