# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

All commands are in README.md. Follow the instructions there to set up your environment and run the app/tests. Add new ones there too.

### Running Ruby / Bundler

Ruby is managed by **mise** (see `.tool-versions`, pinned to 4.0.1). The system `/usr/bin/ruby` is 2.6 and will fail with bundler errors — do not use it, and do not go hunting through `~/.rbenv`, `~/.asdf`, `/opt/homebrew`, etc. to find a Ruby.

Always prefix commands with `mise exec --`:

```bash
mise exec -- bundle exec rake test
mise exec -- bundle exec rake db:migrate
mise exec -- bundle exec rackup
```

If `mise` itself isn't on PATH, it's at `/opt/homebrew/bin/mise`.

## Architecture

Modular Sinatra app using Zeitwerk autoloading. Entry point is `app.rb`; `config.ru` loads dotenv first then the app.

### Top-level namespace
All autoloaded code lives under `module Porotutu` to avoid collisions with gem-defined constants (`Color`, `App`, `Patterns`, etc.). Every file under `features/`, `patterns/`, `mappers/`, and `tests/` is wrapped — so a class like `Porotutu::Users::CreateService` is the full constant path. Inside that nesting, bare references like `Patterns::Service` resolve via Ruby's outward lookup (it walks up to `Porotutu`, finds `Porotutu::Patterns`). Sibling lookup does **not** descend automatically — `extend Service` from inside `Porotutu::Users::…` won't find `Porotutu::Patterns::Service`; always write `extend Patterns::Service`.

### Zeitwerk layout
`app.rb` calls `loader.push_dir(__dir__, namespace: Porotutu)` and two `collapse` rules:
- `features/` itself is collapsed, so `features/<feature>/…` maps to `Porotutu::<Feature>::…`.
- Per-feature grouping dirs `services/`, `handlers/`, `validators/`, `helpers/`, `errors/`, `mappers/` are collapsed too — they exist as folders for organization but do **not** appear in the constant path.

So `features/conflicts/services/create_service.rb` resolves to `Porotutu::Conflicts::CreateService`, `features/users/helpers/views_helper.rb` to `Porotutu::Users::ViewsHelper`, and `features/users/mappers/user_mapper.rb` to `Porotutu::Users::UserMapper`. Non-autoloaded trees are explicitly ignored: `app.rb`, `bin/`, `tasks/`, `tests/`, `db/`, `ksiaki/`, `public/`, `layouts/`, `partials/`, `locales/`. The same loader config is mirrored in `tests/test_helper.rb`.

### Request pipeline
`Porotutu::App < Sinatra::Base` mounts middleware in order:
1. `Patterns::CsrfProtection` — rejects POST/PATCH/DELETE without a valid `csrf_token` param (skipped only when `APP_ENV=test`). Token is stored in session and emitted via the `csrf_field` helper.
2. `Patterns::Authentication` — redirects to `/login` unless the session has `user_id`. Public paths are hard-coded in `PUBLIC_PATHS` (GET `/login`, `/register`; POST `/session`, `/users`). Before redirecting, it calls `Patterns::ReturnTo.set` so a successful login can bounce the user back to where they came from.
3. Top-level feature route classes (`Users::Routes`, `Conflicts::Routes`) — each is its own `Sinatra::Base` subclass, mounted via `use`. All routes for a feature live in that single `routes.rb`.

### Feature anatomy
A feature under `features/<name>/` has this fixed shape. Files inside grouping dirs are named with a role suffix (`_service`, `_handler`, `_validator`, `_helper`, `_mapper`) so their unqualified constant names are unambiguous once the dir is collapsed away:
- `routes.rb` — the feature's single `Routes` class. Route bodies are thin: call a handler, render a view, or redirect. Validation errors are rescued here and re-rendered.
- `handlers/<action>_handler.rb` → `Porotutu::<Feature>::<Action>Handler`. Orchestrate validators + services, slice params, and return a `locals` hash for the view. No DB calls here.
- `services/<action>_service.rb` → `Porotutu::<Feature>::<Action>Service`. `include Patterns::Query`, call a single Postgres function via `call_function('fn_name', p_*: …)`, map the row to a `<Name>Mapper` Data object.
- `validators/<name>_validator.rb` → `Porotutu::<Feature>::<Name>Validator`. Mix in `Patterns::Validations`, raise a feature-local error (`ValidationError`, etc.) with an `errors` hash on failure.
- `mappers/<name>_mapper.rb` → `Porotutu::<Feature>::<Name>Mapper`. `Data.define` read-models for rows returned by this feature's SQL functions. Services reference them by bare name (`UserMapper.from_row(row)`) because they live in the same feature namespace.
- `functions/*.sql` — one SQL file per named Postgres function. Loaded by `rake db:functions`. All DB access goes through these — no raw SELECT/INSERT/UPDATE/DELETE in services. See `.claude/rules/sql.md` for required file structure (BEGIN/DROP/CREATE/COMMIT; mutating functions `RETURN SETOF <table>` with `RETURNING *`).
- `helpers/<name>_helper.rb` → `Porotutu::<Feature>::<Name>Helper`. Ruby modules mixed into the `Routes` class. `views_helper.rb` defines a `view` method that delegates to `Patterns::Views#feature_erb`. Other helpers (e.g. `users/helpers/session_helper.rb` → `post_login_path`) hold flow logic that doesn't fit a handler.
- `views/*.erb` — rendered through the feature's view helper so the shared `layouts/main.erb` wraps them.
- `errors/<name>.rb` → `Porotutu::<Feature>::<Name>`. Feature-local exception classes; file names match the class names as-is (e.g. `validation_error.rb` → `ValidationError`).

### Services and the call convention
`Patterns::Service` is a one-method mixin (`extend Patterns::Service`) that makes every class callable as `Klass.call(...)` instead of `Klass.new.call(...)`. Handlers, services, and validators all use it — so everywhere you see `.call(...)` the target is a stateless object with a single `call` instance method.

`Patterns::Query` is the only thing services touch the DB through. It exposes `call_function(name, args = [])` which expands to `SELECT * FROM name($1..$N)` and runs inside a `Patterns::Db.with` checkout. Never call `Patterns::Db.with` or `conn.exec_params` directly in a service.

### Data layer
- `patterns/database.rb` holds a `connection_pool`-backed pool; `Patterns::Db.with { |c| ... }` checks out a connection (nested `with` calls on the same thread reuse the same connection, which is what makes test transactions work).
- `PG::BasicTypeMapForResults` is set on every connection when it's created, so `TIMESTAMP` columns come back as `Time` objects, booleans as booleans, etc. UUIDs stay as strings, registered explicitly via `PG::TextDecoder::String` for oid 2950 to silence the default "no type cast defined" warning.
- No ORM. Query results become `<Name>Mapper` objects, defined with `Data.define` plus a `from_row(row)` class method that reads hash keys from the `PG::Result` row (strings, not symbols). `UserMapper` deliberately does **not** carry `password_digest` — auth services pull it off the raw row before mapping.
- Mutating SQL functions must return the affected row (`RETURNS SETOF <table>`, `RETURNING *`) so services always return an up-to-date mapper object. This applies to `DELETE` too.

### Tests
- `tests/test_helper.rb` builds its own Zeitwerk loader rooted at the project root and defines `Porotutu::Tests::TestCase` as the base class. Test files are wrapped in `module Porotutu` and inherit from `Tests::TestCase`.
- `setup` checks out a pool connection and opens a transaction; `teardown` rolls back and checks the connection back in. Anything the service under test does via `Patterns::Db.with` inside reuses the same connection (`connection_pool` pins per-thread), so the ROLLBACK wipes it.
- Use `APP_ENV=test bundle exec rake test` so CSRF is bypassed for any request-level tests.
- Test files live at `tests/<feature>/<class_under_test>_test.rb` (e.g. `tests/users/login_service_test.rb` → `Porotutu::Users::LoginServiceTest`). Tests are not autoloaded (Zeitwerk ignores `tests/`) and pull their own references via `require_relative`.
- TODO: no tests exist yet for the `conflicts` feature — only `users` services are covered. Add them when touching conflicts code.

### Views
- `Patterns::Views#feature_erb(views_dir, view, **opts)` renders with `layout: :main` from `layouts/` unless overridden.
- Shared partials live in `partials/` and are rendered via `csrf_field` and `field_error(field, errors:)` helpers.
- When a template renders another `feature_erb` helper inline, pass `layout: false` (see `.claude/rules/turbo.md`), otherwise the main layout gets re-rendered inside itself.
- Turbo Stream responses set `content_type settings.turbo_stream` (registered globally on `Sinatra::Base`). Redirects after mutating actions use status `303` because Turbo expects See Other for POST/PATCH/DELETE.

### Dev reloading
`Sinatra::Reloader` is registered inside `configure :development` in `app.rb` and reloads `patterns/**` and `features/**` (mappers live inside features now, so they're already covered). Reloader only works on modular apps when registered inside the class body (see `.claude/rules/sinatra.md`).

### Rake tasks
Rake tasks live in `tasks/db.rake` and delegate to service classes under `Porotutu::Tasks::Db` (`Migrate`, `Functions`, `Seed`, `Reset`). Each is a `Patterns::Service` callable broken into small private methods. Shared helpers live under `Porotutu::Tasks::Support` — `Runner` (DB connection, file execution, logging) and `Color` (ANSI colors). The rake tree is **not** autoloaded by Zeitwerk; `db.rake` brings in dependencies via `require_relative` (`patterns/service`, `patterns/db`, `patterns/env_helpers`, `support/runner`, `support/color`, the four task services).

`Runner#with_connection` uses `Patterns::Db.with` (same connection pool as the app), so rake tasks share the production DB pool config and don't need a separate `DATABASE_URL` constant.

## Project rules (must follow)

These live in `.claude/rules/` and are part of the spec:
- `.claude/rules/style.md` — no whitespace alignment on `=`, hashes, or method bodies.
- `.claude/rules/sql.md` — SQL string on its own line inside `exec`/`exec_params`; blank line after; `do...end` for mapping; every query goes through a named SQL function with the prescribed file structure.
- `.claude/rules/sinatra.md` — modular-app reloader placement.
- `.claude/rules/turbo.md` — `data-turbo="false"` on auth forms; `layout: false` when composing templates; `303` redirects after Turbo form submissions.

## Not part of the Ruby app

The top-level `ksiaki/` directory is an unrelated PHP project (separate `composer.json`, `deploy.php`, own README). Ignore it when working on the Sinatra app.
