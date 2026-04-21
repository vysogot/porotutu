---
name: style
description: Use when writing or editing any Ruby file in this repo. Covers the small set of non-Rubocop style rules the project enforces: no whitespace alignment on `=`/hashes/kwargs, full translation keys at the call site (no `ts(...)` prefix helper), multi-entry hash literals spanning lines inside method calls, `do...end` (not inline `{}`) when a block renders a full component, and nil-only nil checks (no redundant `empty?`). Trigger on any Ruby edit, not just new files.
---

# General Coding Style

## No whitespace alignment

Never pad with extra spaces to align `=`, `=>`, hash values, or method bodies. One space before and after operators, always.

```ruby
# GOOD
DATABASE_URL = ENV.fetch('DATABASE_URL')
ROOT_DIR = File.expand_path('..', __dir__)
DB_DIR = File.join(ROOT_DIR, 'db')

def production? = ENV['APP_ENV'] == 'production'
def testing? = ENV['APP_ENV'] == 'testing'
def development? = ENV['APP_ENV'] == 'development'

# BAD
DATABASE_URL = ENV.fetch('DATABASE_URL')
ROOT_DIR     = File.expand_path('..', __dir__)
DB_DIR       = File.join(ROOT_DIR, 'db')

def production?  = ENV['APP_ENV'] == 'production'
def testing?     = ENV['APP_ENV'] == 'testing'
def development? = ENV['APP_ENV'] == 'development'
```

Same rule for hash literals, keyword arguments, and case/when bodies. Let the code flow on its own; do not reformat neighbors when renaming one of them.

## Translation keys are written in full

Always pass the complete key to `t(...)`. Don't add a helper that prefixes a scope and takes a short key — it makes the call site unreadable and breaks grep.

```ruby
# GOOD
label_text: t('conflicts.form.favor_label')
placeholder: t('conflicts.form.favor_placeholder')

# BAD — scope hidden in a helper
def ts(key) = t("conflicts.form.#{key}")
label_text: ts('favor_label')

# BAD — placeholder name inferred from the field symbol
def placeholder_for(name) = ts("#{name}_placeholder")
```

The extra repetition is the point: the full key is searchable and self-explanatory.

## Multi-entry hash literals span lines

When a hash literal has more than one key/value pair nested inside a method call (especially a keyword arg like `values: { ... }`), put each pair on its own line with the braces on their own lines too. Single-pair hashes stay inline.

```ruby
# GOOD
render FormView.new(
  values: {
    title: @params[:title],
    description: @params[:description],
    favor: @params[:favor]
  },
  errors: @errors
)

# BAD — long multi-pair hash jammed onto one line
render FormView.new(
  values: { title: @params[:title], description: @params[:description], favor: @params[:favor] },
  errors: @errors
)
```

## Block form for rendering full objects

When iterating to render a full component/object per element, use `do...end` on its own lines. Inline `{ ... }` is fine for short value transforms, but not when the block body is a `render` of a component.

```ruby
# GOOD
@drafts.each do |conflict|
  render CardView.new(conflict:, csrf_token: @csrf_token)
end

# BAD
@drafts.each { |conflict| render CardView.new(conflict:, csrf_token: @csrf_token) }
```

## Nil checks

Check only for what can actually happen. If a column is nullable but never set to an empty string, guard against `nil` only — don't also check `empty?` "just in case".

```ruby
# GOOD
p { @conflict.description } unless @conflict.description.nil?

# BAD — redundant empty? check for a value that's either nil or a real string
p { @conflict.description } if @conflict.description && !@conflict.description.empty?
```
