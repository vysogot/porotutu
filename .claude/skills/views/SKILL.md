---
name: views
description: Use when writing or editing files under `features/*/views/` — the Phlex view classes that render every page, card, and turbo-stream response. Covers inheriting `Porotutu::PhlexView`, wrapping page views in `Porotutu::Layout`, sub-components rendering their own markup (no Layout) so they can be embedded, the `csrf_token:` keyword arg, `tag(:'turbo-frame', ...)` / `tag(:'turbo-stream', ...)`, and passing errors keyed by field name. Trigger on any task touching view files or adding a new Phlex component for a feature.
---

# Views

Views live at `features/<name>/views/*.rb` under the `Porotutu::<Feature>::Views` namespace (Zeitwerk collapses the `views/` folder) and inherit `Porotutu::PhlexView`. Routes render them with:

```ruby
Views::Foo.new(csrf_token: session['csrf_token'], **locals).call
```

## Page views wrap themselves in Layout

A page view renders the shared `Porotutu::Layout` component at the top level; everything else nests inside the block. Pass `csrf_token:` through so the layout's logout/theme-toggle forms have a token; pass `show_nav: false` for auth pages.

```ruby
# GOOD — page view
module Porotutu
  module Conflicts
    class IndexView < PhlexView
      include PathsHelper

      def initialize(drafts:, **attrs)
        @drafts = drafts
        super(**attrs)
      end

      def view_template
        render Porotutu::Layout.new(csrf_token: @csrf_token) do
          main(id: 'conflicts-container', class: 'container') do
            # ...
          end
        end
      end
    end
  end
end
```

## Sub-components render their own markup only

A sub-component (e.g. `CardView`) **does not** wrap itself in `Layout`. It emits only its own markup so it can be embedded inside an `Index`, a `Show`, or a turbo-stream `Update` without double-layout.

```ruby
class CardView < PhlexView
  def view_template
    tag(:'turbo-frame', id: conflict_frame_id(@conflict)) do
      article(class: 'tile') do
        # ...
      end
    end
  end
end
```

## Turbo frames and streams

Custom elements are rendered with `tag(:'turbo-frame', ...)` / `tag(:'turbo-stream', ...)`. Partial-replacement responses (e.g. after PATCH) render only the component that goes inside `<template>`, not a full page:

```ruby
# features/conflicts/views/update_view.rb — turbo-stream that swaps the card
def view_template
  tag(:'turbo-stream', action: 'replace', target: conflict_frame_id(@conflict)) do
    template do
      render CardView.new(conflict: @conflict, csrf_token: @csrf_token)
    end
  end
end
```

## Initialize signatures

Every view takes keyword args including `csrf_token:` (via `PhlexView`'s initializer). Domain-specific args come first; call `super(**attrs)` last so `csrf_token` is forwarded.

```ruby
def initialize(conflict:, **attrs)
  @conflict = conflict
  super(**attrs)
end
```

## Errors are a hash keyed by field name

Forms receive `errors:` as a hash like `{ title: 'can't be blank' }`. The reusable `labeled_input` / `labeled_textarea` helpers render the error under the field; see the `phlex-components` skill for those helpers.

## What views include

- `include PathsHelper` (or similar feature helper) for URL builders — don't hard-code paths in the markup.
- `include DomIdsHelper` when a view needs to emit DOM ids that must match what other views target (e.g. turbo-frame ids).

Keep views dumb about HTTP: no `session['...']` access, no redirects, no `request.xhr?`. The route + handler decide which view to render.
