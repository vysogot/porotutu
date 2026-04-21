# frozen_string_literal: true

module Porotutu
  module StyleBundler
    ROOT = File.expand_path('../..', __dir__)
    SOURCE_DIR = File.join(ROOT, 'lib', 'styles')
    OUTPUT_PATH = File.join(ROOT, 'public', 'stylesheets', 'app.css')

    SOURCE_ORDER = %w[
      01_tokens.css
      02_base.css
      components/nav.css
      components/layout.css
      components/card.css
      components/form.css
      components/button.css
      components/tile.css
    ].freeze

    LAYER_DECLARATION = "@layer tokens, base, components, utilities;\n\n"

    def self.build
      bodies = SOURCE_ORDER.map do |name|
        path = File.join(SOURCE_DIR, name)
        raise "missing stylesheet partial: #{path}" unless File.exist?(path)

        "/* #{name} */\n#{File.read(path).chomp}\n"
      end

      FileUtils.mkdir_p(File.dirname(OUTPUT_PATH))
      File.write(OUTPUT_PATH, LAYER_DECLARATION + bodies.join("\n"))
      OUTPUT_PATH
    end
  end
end
