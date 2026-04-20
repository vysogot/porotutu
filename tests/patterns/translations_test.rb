# frozen_string_literal: true

require_relative '../test_helper'
require 'tempfile'

module Porotutu
  class TranslationsTest < Minitest::Test
    FIXTURE_YAML = <<~YAML
      greeting: "Hello"
      nested:
        deep:
          key: "Deep value"
      with_one: "Hi {{name}}"
      with_many: "{{greeting}}, {{name}}!"
    YAML

    def setup
      @original_locales_path = Translations::LOCALES_PATH
      @tmp = write_fixture_yaml
      swap_locales_path(@tmp.path)
      reset_memoization
    end

    def teardown
      swap_locales_path(@original_locales_path)
      reset_memoization
      @tmp.close!
    end

    def test_returns_plain_string_without_interpolations
      assert_equal 'Hello', Translations.t('greeting')
    end

    def test_replaces_single_interpolation
      assert_equal 'Hi Ada', Translations.t('with_one', name: 'Ada')
    end

    def test_replaces_multiple_interpolations
      assert_equal(
        'Hey, Ada!',
        Translations.t('with_many', greeting: 'Hey', name: 'Ada')
      )
    end

    def test_missing_key_returns_prefixed_key
      assert_equal 'TRANSLATE!!: does.not.exist', Translations.t('does.not.exist')
    end

    def test_nested_dot_keys_resolve_through_nested_hashes
      assert_equal 'Deep value', Translations.t('nested.deep.key')
    end

    def test_partial_path_hitting_non_hash_returns_missing_prefix
      assert_equal 'TRANSLATE!!: greeting.nope', Translations.t('greeting.nope')
    end

    def test_mtime_change_triggers_reload
      assert_equal 'Hello', Translations.t('greeting')

      File.write(@tmp.path, "greeting: \"Hola\"\n")
      future = Time.now + 2
      File.utime(future, future, @tmp.path)

      assert_equal 'Hola', Translations.t('greeting')
    end

    private

    def write_fixture_yaml
      tmp = Tempfile.new(['translations', '.yml'])
      tmp.write(FIXTURE_YAML)
      tmp.flush
      tmp
    end

    def swap_locales_path(path)
      with_silenced_warnings do
        Translations.const_set(:LOCALES_PATH, path)
      end
    end

    def reset_memoization
      Translations.instance_variable_set(:@translations, nil)
      Translations.instance_variable_set(:@loaded_at, nil)
    end

    def with_silenced_warnings
      original = $VERBOSE
      $VERBOSE = nil
      yield
    ensure
      $VERBOSE = original
    end
  end
end
