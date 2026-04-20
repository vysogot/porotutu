# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Conflict-resolution app: Sinatra modular apps, Puma, PostgreSQL, BCrypt, Zeitwerk autoloading, ERB + Turbo views. No ORM — all database access goes through plpgsql functions called with `pg`. Ruby version pinned in `.tool-versions` (use `mise exec --` to invoke).

## Commands

```bash
bundle                        # install gems
bundle exec rackup            # dev server (Puma, reads .env)
bundle exec rake test         # all tests (tests/**/*_test.rb)
bundle exec rake test TEST=tests/users/login_service_test.rb   # single file
bundle exec rake db:reset     # dev/testing only: drop schema, bootstrap, migrate, functions, seed
bundle exec rake db:migrate   # apply pending db/migrations/*.sql (tracked in schema_migrations)
bundle exec rake db:functions # reload every features/*/functions/**/*.sql
bundle exec rake db:seed      # apply db/seeds/*.sql
bundle exec rubocop           # lint
bin/console                   # IRB with full app loaded
```

`APP_ENV`, `DATABASE_URL`, `SESSION_SECRET` must be set (see `.env`). `db:reset` refuses to run when `APP_ENV` is `production` or `staging`.

## Conventions in `.claude/rules/`

Project-specific style rules live in `.claude/rules/` and are loaded automatically:
- `service.md` — `extend Service` pattern, keyword args, never `new.call` or `def self.call`.
- `handler.md` — thin routes, handlers slice params, call validator + service, return a `locals` hash; handlers never touch `session`/`request`/`response`.
- `validation.md` — validators build an errors hash and `raise ValidationError`; per-feature `ValidationError` class; routes rescue and re-render.
- `mapper.md` — `Data.define(...)` + `.from_row(row)`; services return mapped objects, never raw `PG::Result` rows.
- `sql.md` — SQL function structure, `DbFunctionCall#call_function` usage (named `p_*` args), mapping with `do...end`, mutations must `RETURN`ing rows.
- `sinatra.md` — `register Sinatra::Reloader` must be inside `configure :development` (modular apps).
- `turbo.md` — `data-turbo="false"` on auth forms, pass `layout: false` when rendering a `feature_erb` from inside another template, use `303` for post-submit redirects.
- `testing.md` — inherit `Porotutu::Tests::TestCase` for transaction-wrapped tests; no mocks; don't open extra DB connections.
- `style.md` — no whitespace alignment on `=`, hash values, keyword args, etc.

Follow these without repeating their rationale here.

## Architecture

### Entry point

`app.rb` boots `Porotutu::App < Sinatra::Base` via `config.ru`. It wires up Zeitwerk (with `collapse` on `lib`, `lib/*`, `features`, and each feature's `services/handlers/validators/helpers/errors/mappers` folders so their contents live at the `Porotutu::<Feature>` namespace), mounts the `CsrfProtection` and `Authentication` Rack middlewares, and `use`s each feature's modular `Routes` app (`Users::Routes`, `Conflicts::Routes`). New features plug in the same way.

### Feature layout

Each directory under `features/` is a self-contained vertical slice:

```
features/<name>/
  routes.rb         # Sinatra::Base subclass, HTTP verbs only
  handlers/         # orchestration: validate → call service → shape locals
  services/         # one call_function to a SQL function, returns mapped object
  validators/       # raise ValidationError with an errors hash
  mappers/          # Data.define(...) with .from_row(row)
  errors/           # feature-specific exceptions (e.g. ValidationError)
  helpers/          # ViewsHelper exposes `view` → feature_erb with VIEWS_DIR
  views/            # ERB templates
  functions/        # *.sql — one plpgsql function per file, loaded by rake db:functions
```

Request flow: `Routes` extracts params/session → `Handler.call(...)` → `Validator.call` → `Service.call` → `call_function('<name>_crud_<action>', p_foo: ...)` → `Mapper.from_row(result.first)`. Handlers return a `locals` hash; routes call `view :name, locals:` or redirect.

### `lib/`

- `lib/infra/` — code that touches DB/ENV (`DbConnection` with ConnectionPool, `DbFunctionCall`, `Env`).
- `lib/patterns/` — pure Ruby building blocks (`Service` with its `extend`-able `call(...) = new.call(...)`, `Validations#validate_presence/_length`, `Views#feature_erb/field_error/csrf_field/t`, `Translations`).
- `lib/web/` — Rack middleware (`Authentication`, `CsrfProtection`, `ReturnTo`).
- `lib/layouts/main.erb`, `lib/partials/`, `lib/locales/en.yml` — shared views/i18n, ignored by Zeitwerk.

`Patterns::Service` is an `extend`-only module: every handler/service/validator does `extend Service` so callers use `FooService.call(...)`.

Classification rule (per user memory): code that touches DB/ENV/network goes in `lib/infra/`; pure Ruby goes in `lib/patterns/`.

### Database

Schema lives in `db/bootstrap/*.sql` (pgcrypto + `schema_migrations`), `db/migrations/*.sql` (versioned, `YYYYMMDDHHMMSS_*`), and `db/seeds/*.sql`. All runtime queries go through plpgsql functions in `features/<name>/functions/`, reloaded wholesale by `rake db:functions`. Connections come from a `ConnectionPool` (`DB_POOL_SIZE`, `DB_POOL_TIMEOUT`); UUIDs are decoded as strings via a custom `PG::BasicTypeMapForResults` coder.

### Auth

`Authentication` middleware gates every request: passes through if `session['user_id']` is set, otherwise redirects to `/login` after stashing the intended URL via `ReturnTo`. Public paths are whitelisted in `PUBLIC_PATHS` (`GET /login`, `GET /register`, `POST /session`, `POST /users`). Sessions use Rack's cookie store with `httponly` + `same_site: :lax`; CSRF is enforced by `CsrfProtection` middleware, emitted into forms via the `csrf_field` helper.

### Tests

Minitest, loaded via `tests/test_helper.rb` (which sets up its own Zeitwerk loader mirroring `app.rb`). `Porotutu::Tests::TestCase` wraps each test in a DB transaction checked out of the pool and rolled back in `teardown`, so tests hit a real Postgres without polluting it. Run via `rake test` (pattern `tests/**/*_test.rb`).
