# frozen_string_literal: true

require 'pg'
require_relative 'color'

module Runner
  module_function

  def with_connection(url)
    conn = PG.connect(url)
    yield conn
  ensure
    conn&.finish
  end

  def relative_path(filepath, root)
    filepath.delete_prefix("#{root}/")
  end

  def print_header(title)
    puts "\n#{Color.header("--- #{title} ---")}\n\n"
  end

  def print_footer(message, color: :success)
    puts "\n#{Color.send(color, message)}\n"
  end

  def run_file(conn, filepath, rel)
    conn.exec(File.read(filepath))
    yield if block_given?
    puts "#{Color.path(rel)} #{Color.success('=> Success')}"
    :ok
  rescue PG::Error => e
    puts "#{Color.path(rel)} #{Color.error('=> Error:')} #{e.message}"
    :error
  end
end
