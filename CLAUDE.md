# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Conflict-resolution app: Sinatra modular apps, Puma, PostgreSQL, BCrypt, Zeitwerk autoloading, Phlex + Turbo views. No ORM — all database access goes through plpgsql functions called with `pg`. Ruby version pinned in `.tool-versions` (use `mise exec --` to invoke).

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
bundle exec rake styles:build # concatenate lib/styles/**/*.css into public/stylesheets/app.css
bundle exec rubocop           # lint
bin/console                   # IRB with full app loaded
```

`APP_ENV`, `DATABASE_URL`, `SESSION_SECRET` must be set (see `.env`). `db:reset` refuses to run when `APP_ENV` is `production` or `staging`.

## Conventions

Project-specific conventions live as on-demand skills in `.claude/skills/`. They are loaded only when the current task matches the skill's description — not on every turn. One skill mirrors each feature sub-folder, plus a few cross-cutting skills:

Per-feature layer (mirrors `features/<name>/` folders):
- `handlers/` — handler contract: slice params, call validator + service, return `locals`.
- `services/` — `extend Service` pattern, kwarg-only `#call`, `DbFunctionCall` / `Validations` mixins.
- `validators/` — build errors hash, `raise ValidationError`, rescue in the route.
- `errors/` — per-feature `ValidationError` convention.
- `mappers/` — `Data.define` + `.from_row` value objects; services return mapped objects.
- `functions/` — plpgsql file structure (DROP+CREATE, `RETURNING *`).
- `routes/` — thin `Sinatra::Base` subclasses; modular-app reloader placement.
- `views/` — Phlex views, Layout wrapping, turbo-frame/stream fragments.
- `helpers/` — per-feature Ruby modules (paths, DOM ids, session utils).

Cross-cutting:
- `turbo/` — `data-turbo="false"` on auth forms, `303` post-submit redirects, frames/streams.
- `testing/` — `Porotutu::Tests::TestCase` transaction-wrapping, no mocks.
- `sql-queries/` — `call_function(...)` Ruby-side usage and formatting.
- `style/` — no whitespace alignment, full `t(...)` keys, `do...end` for render loops.
- `phlex-components/` — `PhlexView` / `Layout` / shared form mixins in `lib/patterns/phlex_components/`.

To read a skill, open `.claude/skills/<name>/SKILL.md`.

## Architecture

### Entry point

`app.rb` boots `Porotutu::App < Sinatra::Base` via `config.ru`. It wires up Zeitwerk (with `collapse` on `lib`, `lib/*`, `features`, and each feature's `services/handlers/validators/helpers/errors/mappers/views` folders so their contents live at the `Porotutu::<Feature>` namespace), mounts the `CsrfProtection` and `Authentication` Rack middlewares, and `use`s each feature's modular `Routes` app (`Users::Routes`, `Conflicts::Routes`). New features plug in the same way. At boot (non-public envs) `Porotutu::StyleBundler.build` concatenates `lib/styles/**/*.css` into `public/stylesheets/app.css`.

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
  helpers/          # route-level helpers (e.g. SessionHelper) — optional
  views/            # Phlex components under `Porotutu::<Feature>::Views::*`, inherit PhlexView
  functions/        # *.sql — one plpgsql function per file, loaded by rake db:functions
```

Request flow: `Routes` extracts params/session → `Handler.call(...)` → `Validator.call` → `Service.call` → `call_function('<name>_crud_<action>', p_foo: ...)` → `Mapper.from_row(result.first)`. Handlers return a `locals` hash; routes render a view with `Views::Foo.new(csrf_token: session['csrf_token'], **locals).call` or redirect.

### `lib/`

- `lib/infra/` — code that touches DB/ENV/filesystem (`DbConnection` with ConnectionPool, `DbFunctionCall`, `Env`, `StyleBundler`).
- `lib/patterns/` — pure Ruby building blocks (`Service` with its `extend`-able `call(...) = new.call(...)`, `Validations#validate_presence/_length`, `Translations`, `PhlexView` base class with `t`/`csrf_field`/`field_error`, shared `Layout`, reusable `phlex_components`).
- `lib/auth/` — Rack middleware (`Authentication`, `CsrfProtection`, `ReturnTo`).
- `lib/styles/` — CSS partials concatenated into `public/stylesheets/app.css` at boot and via `rake styles:build`.
- `lib/locales/en.yml` — i18n strings loaded by `Translations`.

`Patterns::Service` is an `extend`-only module: every handler/service/validator does `extend Service` so callers use `FooService.call(...)`.

Classification rule (per user memory): code that touches DB/ENV/network goes in `lib/infra/`; pure Ruby goes in `lib/patterns/`.

### Database

Schema lives in `db/bootstrap/*.sql` (pgcrypto + `schema_migrations`), `db/migrations/*.sql` (versioned, `YYYYMMDDHHMMSS_*`), and `db/seeds/*.sql`. All runtime queries go through plpgsql functions in `features/<name>/functions/`, reloaded wholesale by `rake db:functions`. Connections come from a `ConnectionPool` (`DB_POOL_SIZE`, `DB_POOL_TIMEOUT`); UUIDs are decoded as strings via a custom `PG::BasicTypeMapForResults` coder.

### Auth

`Authentication` middleware gates every request: passes through if `session['user_id']` is set, otherwise redirects to `/login` after stashing the intended URL via `ReturnTo`. Public paths are whitelisted in `PUBLIC_PATHS` (`GET /login`, `GET /register`, `POST /session`, `POST /users`). Sessions use Rack's cookie store with `httponly` + `same_site: :lax`; CSRF is enforced by `CsrfProtection` middleware, emitted into forms via the `csrf_field` helper.

### Tests

Minitest, loaded via `tests/test_helper.rb` (which sets up its own Zeitwerk loader mirroring `app.rb`). `Porotutu::Tests::TestCase` wraps each test in a DB transaction checked out of the pool and rolled back in `teardown`, so tests hit a real Postgres without polluting it. Run via `rake test` (pattern `tests/**/*_test.rb`).
