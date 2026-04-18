# frozen_string_literal: true

module Porotutu
  module Tasks
    module Db
      class Migrate
        extend Patterns::Service
        include Support::Runner

        def call(root_dir:, db_dir:)
          print_header("Running scripts in 'migrations'")

          with_connection do |conn|
            run_pending(conn, files(db_dir), root_dir)
          end

          print_footer('Completed migrations')
        end

        private

        def files(db_dir)
          Dir["#{db_dir}/migrations/*.sql"]
        end

        def applied_versions(conn)
          conn.exec(
            'SELECT version FROM schema_migrations'
          ).to_set { |r| r['version'] }
        end

        def run_pending(conn, files, root_dir)
          applied = applied_versions(conn)

          files.each do |filepath|
            rel = relative_path(filepath, root_dir)
            version = File.basename(filepath).split('_').first

            if applied.include?(version)
              puts "#{Support::Color.path(rel)} #{Support::Color.skipped('=> Skipped (already applied)')}"
              next
            end

            exit 1 if run_file(conn, filepath, rel, &recorder(conn, version)) == :error
          end
        end

        def recorder(conn, version)
          lambda {
            conn.exec_params(
              'INSERT INTO schema_migrations (version) VALUES ($1)',
              [version]
            )
          }
        end
      end
    end
  end
end
