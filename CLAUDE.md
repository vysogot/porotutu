# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
bundle                  # Install dependencies
bundle exec rackup      # Start development server
bundle exec rubocop     # Lint Ruby code
rake db:migrate         # Run pending migrations
rake db:functions       # Load/reload all SQL functions
rake db:seed            # Seed the database
rake db:reset           # Drop, recreate, migrate, functions, seed (dev/test only)
rake test               # Run all tests
```

Set `DATABASE_URL` to your Postgres connection string (defaults to `postgres://localhost/porotutu`).

Ruby version: 4.0.1 (managed via asdf, see `.tool-versions`)

## Architecture

Porotutu is a Sinatra + Turbo + PostgreSQL conflict tracker. The codebase follows a layered, feature-driven structure.

**Request flow:** `app.rb` → `features/<name>/routes.rb` → `handlers/` → `services/` → SQL functions → DB

### Layer responsibilities

- **app.rb** — Configuration and `use Feature::Routes` mounts only. No routes defined here.
- **routes.rb** — Sinatra route definitions for a feature. Lives at `features/<name>/routes.rb` as `Feature::Routes < Sinatra::Base`.
- **handlers/** — Thin layer: whitelist/slice params, call one service, return locals hash for the view. Validation (presence, format) goes here — after whitelisting, before calling the service.
- **services/** — One class per operation. Extend `Patterns::Service`. Call a SQL function via `DB.connection`. Return a mapper struct. Authorization (ownership checks) goes here — before mutating.
- **functions/** — SQL functions. One file per function. Loaded via `rake db:functions`.
- **mappers/** — Plain `Data.define` structs with a `from_row` class method for DB row casting. One file per entity. Services call `Mapper.from_row(result.first)` — never inline `Model.new(...)` with raw row access.
- **views/** — ERB templates. A `view()` helper in `helpers/views.rb` resolves paths within the feature namespace. Shared layout lives in `layouts/main.erb`.
- **errors/** — Custom `StandardError` subclasses raised by handlers (validation) or services (authorization). Rescued in routes.

### Nested features

A feature can contain sub-features (e.g. `conflicts/crud`). The parent `routes.rb` mounts the sub-feature's routes via `use SubFeature::Routes`. Code is namespaced accordingly: `Conflicts::Crud::Services::Create`, etc.

```
features/conflicts/
  routes.rb             # mounts Crud::Routes
  crud/
    routes.rb           # actual HTTP endpoints
    handlers/
    services/
    mappers/
    functions/
    views/
    helpers/
    errors/
```

### Adding a new feature

Create `features/<name>/` with:

```
features/<name>/
  routes.rb             # Feature::Routes < Sinatra::Base
  mappers/<name>.rb     # Feature::Thing = Data.define(...) { def self.from_row... }
  handlers/index.rb
  handlers/show.rb
  handlers/new.rb
  handlers/create.rb
  handlers/edit.rb
  handlers/update.rb
  handlers/delete.rb
  services/index.rb     # calls <feature>_index()
  services/find.rb      # calls <feature>_find(id)
  services/create.rb    # calls <feature>_create(...)
  services/update.rb    # calls <feature>_update(...)
  services/delete.rb    # calls <feature>_delete(id)
  functions/index.sql
  functions/find.sql
  functions/create.sql
  functions/update.sql
  functions/delete.sql
  views/index.erb
  views/new.erb
  views/show.erb
  views/edit.erb
  views/create.erb      # Turbo Stream response
  views/update.erb      # Turbo Stream response
  views/delete.erb      # Turbo Stream response
  helpers/views.rb      # include Patterns::Views; defines view() helper
  errors/               # custom StandardError subclasses
```

Then in `app.rb`, add `use Feature::Routes`.

**Database:** `patterns/database.rb` exposes `DB.connection`, a lazy singleton `PG::Connection`. All queries call named SQL functions — never raw SQL in services.

**Frontend:** Turbo Frames scope DOM updates; Turbo Streams handle server-driven mutations (prepend on create, remove on delete). Stimulus controllers add lightweight interactivity (e.g., copy to clipboard). Pico CSS loaded from CDN.

**Conventions:**
- All Ruby files use `# frozen_string_literal: true`
- All code is namespaced under `FeatureName::` (e.g., `Conflicts::Crud::Services::Create`)
- Features are organized by domain (`features/<name>/`), not by technical layer
- Handlers whitelist params before validating; services authorize before mutating

## Testing

Tests live in `tests/`, not inside `features/`. Structure:

```
tests/
  test_helper.rb              # Zeitwerk boot, DB connection, base TestCase (BEGIN/ROLLBACK)
  <feature>/
    helpers.rb                # Feature-specific factory helpers as an includeable module
    test_helper.rb            # require both above; includes helpers into TestCase
    *_test.rb                 # require_relative 'test_helper'
```

Each test runs inside a transaction rolled back on teardown — no data persists between tests.

`TestCase` lives in `<Feature>::Tests::TestCase`. Factory helpers (`create_user`, `create_couple`, etc.) live in `<Feature>::Tests::Helpers` and are included into `TestCase` via the feature's `test_helper.rb`.

Use `BCrypt::Engine::MIN_COST` when hashing passwords in tests — default cost adds ~350ms per call.

## Coding Rules

See [`.claude/rules/`](.claude/rules/) for detailed rules.

- **SQL** — [`.claude/rules/sql.md`](.claude/rules/sql.md): always put SQL string on its own line; all queries go through named SQL functions
- **Sinatra** — [`.claude/rules/sinatra.md`](.claude/rules/sinatra.md): use `register Sinatra::Reloader` inside `configure :development` in the class, not at top level
- **Turbo** — [`.claude/rules/turbo.md`](.claude/rules/turbo.md): auth forms need `data-turbo="false"`; redirects after form submission use `303`
- **Models** — [`.claude/rules/models.md`](.claude/rules/models.md): define `from_row` on the mapper for DB row casting; never inline `Model.new(...)` with raw row access in services
