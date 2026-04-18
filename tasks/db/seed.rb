# frozen_string_literal: true

module Porotutu
  module Tasks
    module Db
      class Seed
        extend Patterns::Service
        include Support::Runner

        def call(root_dir:, db_dir:)
          print_header("Running scripts in 'seeds'")

          with_connection do |conn|
            run_all(conn, files(db_dir), root_dir)
          end

          print_footer('Completed seeds')
        end

        private

        def files(db_dir)
          Dir["#{db_dir}/seeds/*.sql"]
        end

        def run_all(conn, files, root_dir)
          files.each do |filepath|
            rel = relative_path(filepath, root_dir)
            exit 1 if run_file(conn, filepath, rel) == :error
          end
        end
      end
    end
  end
end
