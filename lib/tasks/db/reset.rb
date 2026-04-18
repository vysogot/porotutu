# frozen_string_literal: true

module Porotutu
  module Tasks
    module Db
      class Reset
        extend Patterns::Service
        include Support::Runner

        def call(root_dir:, db_dir:)
          guard_environment!

          drop_and_recreate_pg_schema
          run_basics(files(db_dir), root_dir)
        end

        private

        def files(db_dir)
          Dir["#{db_dir}/basics/*.sql"]
        end

        def guard_environment!
          return unless EnvHelpers.public?

          warn "\n#{Support::Color.error("Refusing to reset in '#{ENV.fetch('APP_ENV')}'")}\n\n"
          exit 1
        end

        def drop_and_recreate_pg_schema
          with_connection do |conn|
            conn.exec('SET client_min_messages = WARNING')
            conn.exec('DROP SCHEMA public CASCADE')
            conn.exec('CREATE SCHEMA public')
          end
          label = Support::Color.label('Database reset')
          detail = Support::Color.success('(schema dropped and recreated)')
          puts "\n#{label} #{detail}\n"
        end

        def run_basics(files, root_dir)
          print_header("Running scripts in 'basics'")

          with_connection do |conn|
            files.each do |filepath|
              rel = relative_path(filepath, root_dir)
              exit 1 if run_file(conn, filepath, rel) == :error
            end
          end

          print_footer('Completed basics')
        end
      end
    end
  end
end
