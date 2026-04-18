# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
bundle                        # install gems
bundle exec rackup            # run dev server (Puma via rackup, reads .env)
bundle exec rake test         # run all tests (tests/**/*_test.rb)
bundle exec rake db:reset     # dev/test only: drop schema, create, migrate, load functions, seed
bundle exec rake db:migrate   # run pending migrations from db/migrate
bundle exec rake db:functions # reload every features/*/functions/**/*.sql
bundle exec rake db:seed      # apply db/seeds
bin/console                   # IRB with the full app loaded
```

`APP_ENV`, `DATABASE_URL`, and `SESSION_SECRET` must be set (see `.env`). `rake db:reset` refuses to run unless `APP_ENV` is `development` or `testing`.

A single test file: `bundle exec rake test TEST=tests/path/to/file_test.rb`.

## Architecture

Modular Sinatra app using Zeitwerk autoloading. Entry point is `app.rb`; `config.ru` loads dotenv first then the app.

### Zeitwerk layout
`app.rb` pushes the project root as the autoload root and collapses `features/` — so `features/conflicts/crud/services/create.rb` resolves to `Conflicts::Crud::Services::Create`, not `Conflicts::Features::…`. When adding a new feature directory, the `features/<name>/` layer is collapsed away but every deeper directory becomes part of the module path.

### Request pipeline
`App < Sinatra::Base` mounts middleware in order:
1. `Patterns::CsrfProtection` — rejects POST/PATCH/DELETE without a valid `csrf_token` param (skipped when `RACK_ENV=test`). Token is stored in session and emitted via the `csrf_field` helper.
2. `Patterns::Authentication` — redirects to `/login` unless the session has `user_id`. Public paths are hard-coded in `PUBLIC_PATHS` (GET `/login`, `/register`; POST `/session`, `/users`).
3. Feature route classes (`Auth::Routes`, `Users::Routes`, `Conflicts::Routes`) — each is its own `Sinatra::Base` subclass, mounted via `use`. Sub-feature routes (e.g. `Conflicts::Crud::Routes`) are mounted inside their parent feature's `Routes` class.

### Feature anatomy
A feature (or sub-feature) under `features/<name>/[<subfeature>/]` has this fixed shape:
- `routes.rb` — Sinatra routes. Route bodies are thin: call a handler, render a view, or redirect. Validation errors from handlers are rescued here and re-rendered.
- `handlers/*.rb` — orchestrate validators + services, slice params, and return a `locals` hash for the view. No DB calls here.
- `services/*.rb` — one DB function call each, mapped to a `Mappers::*` Data object.
- `validators/*.rb` — mix in `Patterns::Validations`, raise a feature-local `Errors::ValidationError` with an `errors` hash on failure.
- `functions/*.sql` — one SQL file per named Postgres function. Loaded by `rake db:functions`. All DB access goes through these — no raw SELECT/INSERT/UPDATE/DELETE in services. See `.claude/rules/sql.md` for required file structure (BEGIN/DROP/CREATE/COMMIT; mutating functions `RETURN SETOF <table>` with `RETURNING *`).
- `helpers/views.rb` — defines a feature-specific view helper (e.g. `view`, `auth_erb`, `users_erb`) that delegates to `Patterns::Views#feature_erb` with the feature's `VIEWS_DIR`.
- `views/*.erb` — rendered through the feature's helper so the shared `layouts/main.erb` wraps them.
- `errors/*.rb` — feature-local exception classes.

### Services and the call convention
`Patterns::Service` is a one-method mixin (`extend Patterns::Service`) that makes every class callable as `Klass.call(...)` instead of `Klass.new.call(...)`. Handlers, services, and validators all use it — so everywhere you see `.call(...)` the target is a stateless object with a single `call` instance method.

### Data layer
- Single `PG` connection via `DB.connection` (memoized in `patterns/db.rb`).
- No ORM. Query results become `Mappers::*` objects, defined with `Data.define` plus a `from_row(row)` class method that reads hash keys from the `PG::Result` row (strings, not symbols).
- Mutating SQL functions must return the affected row; services do `Mappers::X.from_row(result.first)` so callers always get the updated model.

### Views
- `Patterns::Views#feature_erb(views_dir, view, **opts)` renders with `layout: :main` from `layouts/` unless overridden.
- Shared partials live in `partials/` and are rendered via `csrf_field` and `field_error(field, errors:)` helpers.
- When a template renders another `feature_erb` helper inline, pass `layout: false` (see `.claude/rules/turbo.md`), otherwise the main layout gets re-rendered inside itself.
- Turbo Stream responses set `content_type settings.turbo_stream` (registered globally on `Sinatra::Base`). Redirects after mutating actions use status `303` because Turbo expects See Other for POST/PATCH/DELETE.

### Dev reloading
`Sinatra::Reloader` is registered inside `configure :development` in `app.rb` and reloads `patterns/**`, `features/**`, and `mappers/**`. Reloader only works on modular apps when registered inside the class body (see `.claude/rules/sinatra.md`).

## Project rules (must follow)

These live in `.claude/rules/` and are part of the spec:
- `.claude/rules/sql.md` — SQL string on its own line inside `exec`/`exec_params`; blank line after; `do...end` for mapping; every query goes through a named SQL function with the prescribed file structure.
- `.claude/rules/sinatra.md` — modular-app reloader placement.
- `.claude/rules/turbo.md` — `data-turbo="false"` on auth forms; `layout: false` when composing templates; `303` redirects after Turbo form submissions.

## Not part of the Ruby app

The top-level `ksiaki/` directory is an unrelated PHP project (separate `composer.json`, `deploy.php`, own README). Ignore it when working on the Sinatra app.
