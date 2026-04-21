---
name: phlex-components
description: Use when touching the shared view infrastructure — `lib/patterns/phlex_view.rb`, `lib/patterns/layout.rb`, or anything under `lib/patterns/phlex_components/`. Covers the `PhlexView` base class (provides `t`, `csrf_field`, `field_error` + includes `LabeledInput` / `LabeledTextarea` / `ProtectedForm`), the shared `Layout`'s responsibilities (head, Turbo import, theme init, nav), and how to add a new reusable form/UI mixin. Trigger when adding a cross-feature UI helper or debugging why every view has `t` / `labeled_input` available.
---

# Phlex Components and Base Classes

The app has a small shared view layer in `lib/patterns/` that every feature view inherits from. Understand this before adding new UI primitives — chances are a mixin already exists.

## `PhlexView` base class

`lib/patterns/phlex_view.rb` — every feature view inherits this.

```ruby
module Porotutu
  class PhlexView < Phlex::HTML
    include PhlexComponents::LabeledInput
    include PhlexComponents::LabeledTextarea
    include PhlexComponents::ProtectedForm

    def initialize(csrf_token: nil, **attrs)
      @csrf_token = csrf_token
      super(**attrs)
    end

    def t(key, **interpolations) = Translations.t(key, **interpolations)

    def csrf_field
      input(type: 'hidden', name: 'csrf_token', value: @csrf_token)
    end

    def field_error(field, errors: nil)
      return unless errors&.key?(field)

      p(class: 'field__error') { errors[field] }
    end
  end
end
```

What this buys every view:
- `t('some.i18n.key', name: ...)` — translation lookup via `Translations`.
- `csrf_field` — emits the hidden input; `@csrf_token` is set from the `csrf_token:` kwarg the route passes.
- `field_error(:title, errors: @errors)` — renders `<p class="field__error">message</p>` when present.
- `labeled_input`, `labeled_textarea`, `protected_form` — see below.

## `Layout` (lib/patterns/layout.rb)

A `PhlexView` subclass that handles the boilerplate every page needs:

- `<!doctype>`, `<html lang="en">`, meta, favicon, stylesheet link.
- Inline theme-init script (reads `porotutu.theme` from `localStorage`, sets `data-theme`).
- Turbo 7.3.0 import from skypack.
- `<body>` with a nav (brand / theme-toggle / logout form) unless `show_nav: false`.
- Yields to the block for the page content.

Call it from a page view:

```ruby
render Porotutu::Layout.new(csrf_token: @csrf_token, title: t('...'), show_nav: false) do
  main(class: 'page') do
    # ...
  end
end
```

Do **not** render Layout from a sub-component (card, turbo-stream fragment, etc.) — those embed inside a page that already has Layout.

## Reusable mixins

### `labeled_input(name, label_text:, ...)` — `lib/patterns/phlex_components/labeled_input.rb`

```ruby
labeled_input(
  :title,
  label_text: t('conflicts.form.title_label'),
  value: @values[:title],
  maxlength: 100,
  placeholder: t('conflicts.form.title_placeholder'),
  autofocus: true,
  errors: @errors
)
```

Emits `<div class="field">` (or `field field--invalid` when `errors` has a key for this field) containing `<label>`, `<input>`, and the `field_error`. Accepts `type`, `value`, `required`, `maxlength`, `placeholder`, `autofocus`.

### `labeled_textarea(name, label_text:, ...)` — `lib/patterns/phlex_components/labeled_textarea.rb`

Same shape as `labeled_input` but renders a `<textarea>`. Supports `rows:` (default 4), `value:`, `required:`, `maxlength:`, `placeholder:`, `errors:`.

### `protected_form(**attrs, &block)` — `lib/patterns/phlex_components/protected_form.rb`

Wraps a `<form>` and auto-injects `csrf_field` at the top:

```ruby
protected_form(action: @action, method: 'post', class: 'form') do
  labeled_input(:title, ...)
  button(type: 'submit') { ... }
end
```

Use this instead of a bare `form(...)` — the CSRF token is non-optional.

## Adding a new reusable component

When a form/UI pattern appears in two or more views, promote it to a mixin:

1. Create `lib/patterns/phlex_components/<thing>.rb` defining a module inside `Porotutu::PhlexComponents`.
2. Add `include PhlexComponents::<Thing>` to `PhlexView`.
3. The helper is now available on every view.

Keep these modules dumb — they compose Phlex primitives and read ivars/args, no side effects.
