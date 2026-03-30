# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
bundle                  # Install dependencies
bundle exec rackup      # Start development server
bundle exec rubocop     # Lint Ruby code
```

Set `DATABASE_URL` to your Postgres connection string (defaults to `postgres://localhost/porotutu`).

Ruby version: 4.0.1 (managed via asdf, see `.tool-versions`)

## Architecture

Porotutu is a Sinatra + Turbo + PostgreSQL conflict tracker. The codebase follows a layered, feature-driven structure:

**Request flow:** `app.rb` (routes) → `features/conflicts/handlers/` → `features/conflicts/services/` → `features/conflicts/models/`

- **app.rb** — All Sinatra routes. Routes call handlers by instantiating them with request params.
- **handlers/** — Thin layer: slice/validate params, call a service, pass locals to a view.
- **services/** — Business logic (create, update, delete). Extend `Patterns::Service` from `patterns/service.rb`, which provides a `.call(...)` class method that delegates to `#call`. Use `DB.connection` (from `patterns/database.rb`) for raw pg queries.
- **models/** — Plain `Data.define` structs; no ORM. `Conflicts::Conflict = Data.define(:id, :name)`.
- **views/** — ERB templates. A custom `conflicts_erb()` helper resolves view paths within the feature namespace.

**Database:** `patterns/database.rb` exposes `DB.connection`, a lazy singleton `PG::Connection`. All queries use `exec_params` with `$1`-style placeholders. Schema is managed via plain SQL — no migration framework.

**Frontend:** Turbo Frames scope DOM updates; Turbo Streams handle server-driven mutations (prepend on create, remove on delete). Stimulus controllers add lightweight interactivity (e.g., copy to clipboard). Pico CSS loaded from CDN.

**Conventions:**
- All Ruby files use `# frozen_string_literal: true`
- All code is namespaced under `Conflicts::` (e.g., `Conflicts::Services::Create`)
- Features are organized by domain (`features/conflicts/`), not by technical layer
- Handlers whitelist params before passing to services

## Coding Rules

See [`.claude/rules/`](.claude/rules/) for detailed rules.

- **SQL** — [`.claude/rules/sql.md`](.claude/rules/sql.md): `exec_params` SQL string and params array always on separate lines
