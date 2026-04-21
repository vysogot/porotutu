---
name: errors
description: Use when creating or editing files under `features/*/errors/` — especially per-feature `ValidationError` classes. Covers the why of feature-scoped errors (so a route's `rescue` can't accidentally catch another feature's error) and the canonical class shape. Trigger on "ValidationError", "feature error", or when moving/adding error classes across features.
---

# Feature-local errors

Each feature defines its own error classes under `features/<name>/errors/`. The canonical example is `ValidationError`, raised by that feature's validator and carrying an errors hash so the route can re-render the form with per-field messages.

```ruby
# features/conflicts/errors/validation_error.rb
module Porotutu
  module Conflicts
    class ValidationError < StandardError
      attr_reader :errors

      def initialize(errors)
        @errors = errors
        super('Validation failed')
      end
    end
  end
end
```

Don't share a single global `ValidationError` across features — keep the class scoped to the feature that raises it, so the route's `rescue ValidationError => e` resolves to the feature's own constant (via Zeitwerk's `Porotutu::<Feature>` namespace) and can't accidentally catch a different feature's error.

The same principle applies to any other error: scope it to the feature that raises and rescues it. Promote an error into shared space only when two features legitimately share the same exception semantics.
