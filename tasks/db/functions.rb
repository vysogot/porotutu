# frozen_string_literal: true

module Porotutu
  module Tasks
    module Db
      class Functions
        extend Patterns::Service
        include Support::Runner

        def call(root_dir:)
          print_header("Running scripts in 'functions'")

          errors = with_connection do |conn|
            run_all(conn, files(root_dir), root_dir)
          end

          report(errors)
        end

        private

        def files(root_dir)
          Dir["#{root_dir}/features/**/functions/**/*.sql"]
        end

        def run_all(conn, files, root_dir)
          files.each_with_object([]) do |filepath, failed|
            rel = relative_path(filepath, root_dir)
            failed << rel if run_file(conn, filepath, rel) == :error
          end
        end

        def report(errors)
          if errors.empty?
            print_footer('Completed functions')
          else
            print_footer("Completed functions with errors: #{errors.join(', ')}", color: :error)
          end
        end
      end
    end
  end
end
