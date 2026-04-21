---
name: helpers
description: Use when writing or editing files under `features/*/helpers/` — the per-feature Ruby modules for route/view-level concerns. Covers what belongs here (URL builders like `PathsHelper`, DOM-id generators, session utilities like `SessionHelper`) and what does not (business logic, DB access, error types). Trigger when adding `conflict_path(...)` / `new_conflict_path` style helpers or a view needs a shared module.
---

# Feature Helpers

Helpers are optional per-feature Ruby modules under `features/<name>/helpers/`. Zeitwerk collapses the `helpers/` folder so files live directly at the `Porotutu::<Feature>` namespace, which means a view or route can `include PathsHelper` without a `Helpers::` prefix.

## What belongs in a helper

- **Path builders.** URL helpers for the feature's routes, keyed to the record:
  ```ruby
  module Porotutu
    module Conflicts
      module PathsHelper
        def conflicts_path = '/conflicts'
        def new_conflict_path = '/conflicts/new'
        def conflict_path(conflict) = "/conflicts/#{conflict.id}"
        def edit_conflict_path(conflict) = "/conflicts/#{conflict.id}/edit"
      end
    end
  end
  ```
- **DOM ids.** String builders that keep turbo-frame / stream targets in sync across views (e.g. `DomIdsHelper#conflict_frame_id(conflict)`).
- **Session / return-to utilities.** Small modules used by a feature's routes to read session state consistently, e.g. `Users::SessionHelper#post_login_path`.

Helpers can `include` another feature's helper when the concept is shared (see `Users::SessionHelper` including `Conflicts::PathsHelper`).

## What does not belong in a helper

- Business logic → service.
- DB access → service + SQL function.
- HTTP concerns (reading session, setting status codes) → route.
- Error classes → `features/<name>/errors/`.
- Reusable UI/markup → a Phlex component module in `lib/patterns/phlex_components/` (see the `phlex-components` skill).

If a helper starts growing conditionals or calling services, that's the signal to promote the logic out.
