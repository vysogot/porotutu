# frozen_string_literal: true

def with_db
  conn = PG.connect(ENV.fetch('DATABASE_URL'))
  yield conn
ensure
  conn&.close
end

def run_sql_file(conn, filepath)
  rel = filepath.delete_prefix("#{ROOT_DIR}/")
  conn.exec(File.read(filepath))
  yield if block_given?
  puts "#{Color.path(rel)} #{Color.success('=> Success')}"
  :ok
rescue PG::Error => e
  puts "#{Color.path(rel)} #{Color.error('=> Error:')} #{e.message}"
  :error
end

def print_header(title) = puts("\n#{Color.header("--- #{title} ---")}\n\n")
def print_footer(message, color: :success) = puts("\n#{Color.send(color, message)}\n")
