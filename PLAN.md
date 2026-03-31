# Conflicts Feature Implementation Plan

Everything below is built on top of the existing Sinatra + Turbo + PostgreSQL stack.
The existing `conflicts` table (toy scaffold with just `name`) will be replaced.
All new code follows the established patterns: services call named SQL functions, handlers
whitelist params, views use Turbo Frames/Streams.

---

## Phase 1 — Database Foundation

No Ruby code. Just migrations and updated seeds.

### Migrations

**`db/migrate/20260330000001_create_couples_table.sql`**
```sql
CREATE TABLE IF NOT EXISTS couples (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  partner1_id             UUID NOT NULL REFERENCES users(id),
  partner2_id             UUID NOT NULL REFERENCES users(id),
  disconnected_partner_id UUID,
  created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**`db/migrate/20260330000002_create_conflict_resolutions_table.sql`**
```sql
CREATE TABLE IF NOT EXISTS conflict_resolutions (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conflict_id UUID NOT NULL REFERENCES conflicts(id) ON DELETE CASCADE,
  status      TEXT NOT NULL,
  favor       TEXT,
  resolved_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

**`db/migrate/20260330000003_replace_conflicts_table.sql`**
```sql
DROP TABLE IF EXISTS conflicts CASCADE;

DO $$ BEGIN
  CREATE TYPE conflict_status AS ENUM (
    'draft', 'pending', 'active',
    'resolved', 'postponed', 'favor_done', 'canceled'
  );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE conflicts (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id        UUID NOT NULL REFERENCES couples(id),
  creator_id       UUID NOT NULL REFERENCES users(id),
  title            TEXT NOT NULL,
  description      TEXT NOT NULL DEFAULT '',
  favor            TEXT,
  status           conflict_status NOT NULL DEFAULT 'draft',
  deadline         TIMESTAMP,
  recur_count      INTEGER NOT NULL DEFAULT 0,
  proposed_status  TEXT,
  proposed_by_id   UUID REFERENCES users(id),
  notified_overdue INTEGER NOT NULL DEFAULT 0,
  created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  archived_at      TIMESTAMP
);
```

### Seeds

**`db/seeds/couples.sql`** — link the two seed users into one couple.

**`db/seeds/conflicts.sql`** — replace toy data with realistic examples in `draft`
and `active` states, referencing the seeded couple.

---

## Phase 2 — Couples Feature (services only, no routes yet)

Conflicts need to look up a user's couple. A thin `Couples` feature provides this.

### Files

```
features/couples/
  models/couple.rb              # Couple = Data.define(:id, :partner1_id, :partner2_id, :disconnected_partner_id)
  services/find_for_user.rb     # calls get_couple_for_user($user_id)
  services/create.rb            # calls create_couple($p1_id, $p2_id)
  functions/get_couple_for_user.sql
  functions/create_couple.sql
  helpers/paths.rb              # couples_erb helper (for future routes)
```

No routes yet — other features call `Couples::Services::FindForUser` directly.

### SQL function signatures

```sql
-- get_couple_for_user(p_user_id UUID) → TABLE(id, partner1_id, partner2_id, disconnected_partner_id)
-- create_couple(p_partner1_id UUID, p_partner2_id UUID) → TABLE(id, partner1_id, partner2_id, ...)
```

`find_for_user` returns `nil` (empty result) if the user has no couple yet.

---

## Phase 3 — Test Infrastructure

Add `minitest` to `Gemfile`. Add `rake test` task to `Rakefile`.

### `features/tests/test_helper.rb`

- Requires `dotenv/load`, `minitest/autorun`, `pg`, `bcrypt`, `zeitwerk`
- Boots Zeitwerk with the same config as `app.rb` (collapses `features/` and `features/*/models`)
- Requires `patterns/database`
- Defines `TestCase < Minitest::Test` with:
  - `setup` → `DB.connection.exec('BEGIN')`
  - `teardown` → `DB.connection.exec('ROLLBACK')`
  - Helper `create_user(email:)` — inserts via `create_user()` SQL function
  - Helper `create_couple(user1_id:, user2_id:)` — inserts via `create_couple()` SQL function
  - Helper `create_conflict(couple_id:, creator_id:, title:, **opts)` — inserts via `create_conflict()` SQL function

Every test runs inside a transaction that is rolled back on teardown. No data persists between tests.

### `Rakefile` addition

```ruby
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << '.'
  t.pattern = 'features/tests/**/*_test.rb'
end
```

Run with: `rake test`

---

## Phase 4 — Conflict Services + SQL Functions (TDD)

Write test files first, then implement services and SQL functions to make them pass.

### Test files

```
features/tests/conflicts/
  create_test.rb
  list_test.rb
  find_test.rb
  update_test.rb
  delete_test.rb
  share_test.rb
  reveal_test.rb
  resolution_test.rb
  reopen_test.rb
```

### What each test covers

| Test file | Assertions |
|---|---|
| `create_test.rb` | Creates a draft; title/description/favor stored; status = 'draft'; deadline nil; creator_id set |
| `list_test.rb` | Returns own drafts; returns own pending; returns partner's pending separately; returns active for couple; excludes other couples |
| `find_test.rb` | Returns correct conflict by id; returns nil for unknown id |
| `update_test.rb` | Updates title/description/favor on draft; updated_at changes; does not update status |
| `delete_test.rb` | Deletes the record; subsequent find returns nil |
| `share_test.rb` | Share: draft → pending; Unshare: pending → draft |
| `reveal_test.rb` | All pending for couple → active; deadline set to `now + 7 days`; other couples unaffected |
| `resolution_test.rb` | Propose sets proposed_status + proposed_by_id; Accept archives + records in conflict_resolutions; Decline clears proposed fields; Withdraw clears proposed fields |
| `reopen_test.rb` | Archived → active; fresh deadline; recur_count incremented; archived_at cleared |

### SQL functions (new/replaced)

All live in `features/conflicts/functions/`.

| File | Signature | Notes |
|---|---|---|
| `get_conflicts.sql` | `get_conflicts(p_couple_id, p_user_id)` | Returns all non-archived conflicts for couple; columns include `status` so callers can filter |
| `get_conflict.sql` | `get_conflict(p_id)` | Single conflict by id |
| `create_conflict.sql` | `create_conflict(p_couple_id, p_creator_id, p_title, p_description, p_favor)` | Status = 'draft', deadline NULL |
| `update_conflict.sql` | `update_conflict(p_id, p_title, p_description, p_favor)` | Updates draft fields + updated_at |
| `delete_conflict.sql` | `delete_conflict(p_id)` | Hard delete |
| `share_conflict.sql` | `share_conflict(p_id)` | Sets status = 'pending' |
| `unshare_conflict.sql` | `unshare_conflict(p_id)` | Sets status = 'draft' |
| `reveal_conflicts.sql` | `reveal_conflicts(p_couple_id, p_partner_id)` | Sets status = 'active' + deadline = now + interval '7 days' WHERE status = 'pending' AND creator_id = p_partner_id AND couple_id = p_couple_id |
| `propose_resolution.sql` | `propose_resolution(p_id, p_status, p_proposed_by_id)` | Sets proposed_status + proposed_by_id |
| `accept_resolution.sql` | `accept_resolution(p_id)` | Sets status = proposed_status, archived_at = now, clears proposed fields; inserts into conflict_resolutions |
| `decline_resolution.sql` | `decline_resolution(p_id)` | Clears proposed_status + proposed_by_id |
| `reopen_conflict.sql` | `reopen_conflict(p_id)` | Sets status = 'active', deadline = now + 7 days, recur_count + 1, archived_at = NULL |

### Model

Replace `features/conflicts/models/conflict.rb`:

```ruby
Conflict = Data.define(
  :id, :couple_id, :creator_id,
  :title, :description, :favor,
  :status, :deadline, :recur_count,
  :proposed_status, :proposed_by_id,
  :created_at, :updated_at, :archived_at
)
```

Add `features/conflicts/models/resolution.rb`:
```ruby
Resolution = Data.define(:id, :conflict_id, :status, :favor, :resolved_at)
```

### Services

All in `features/conflicts/services/`, each extending `Patterns::Service`:

```
create.rb         # create_conflict(...)
list.rb           # get_conflicts(couple_id, user_id) → array; splits into {drafts:, pending_mine:, pending_partner:, active:}
find.rb           # get_conflict(id)
update.rb         # update_conflict(id, title, description, favor)
delete.rb         # delete_conflict(id)
share.rb          # share_conflict(id)
unshare.rb        # unshare_conflict(id)
reveal.rb         # reveal_conflicts(couple_id, partner_id)
propose_resolution.rb   # propose_resolution(id, status, proposed_by_id)
accept_resolution.rb    # accept_resolution(id)
decline_resolution.rb   # decline_resolution(id)
reopen.rb         # reopen_conflict(id)
```

`Services::List` returns a struct/hash with four keys so the home handler can pass them
all as locals:

```ruby
{ drafts:, pending_mine:, pending_partner:, active: }
```

---

## Phase 5 — Routes + Handlers

### Routes

Expand `features/conflicts/routes.rb`. Routes pass `current_user_id: session['user_id']`
to handlers that need it.

| Method | Path | Handler | Turbo Stream? |
|---|---|---|---|
| GET | `/` | `Home` | No |
| GET | `/new` | — | No |
| POST | `/conflicts` | `Create` | Yes — prepend to `#conflicts-drafts` |
| GET | `/:id` | `Show` | No |
| GET | `/:id/edit` | `Edit` | No |
| PATCH | `/:id` | `Update` | Yes — replace `#conflict-<id>` |
| DELETE | `/:id` | `Delete` | Yes — remove `#conflict-<id>` |
| POST | `/:id/share` | `Share` | Yes — replace `#conflict-<id>` |
| POST | `/:id/unshare` | `Unshare` | Yes — replace `#conflict-<id>` |
| POST | `/reveal` | `Reveal` | Yes — replace `#pending-partner` + update `#active-conflicts` |
| POST | `/:id/propose` | `ProposeResolution` | Yes — replace `#conflict-<id>` |
| POST | `/:id/accept` | `AcceptResolution` | Yes — remove `#conflict-<id>` |
| POST | `/:id/decline` | `DeclineResolution` | Yes — replace `#conflict-<id>` |
| POST | `/:id/reopen` | `Reopen` | No — redirect to `/:id` |

All POST/PATCH/DELETE after form submission redirect with `303` or return a Turbo Stream.

### Handlers

One file per route action in `features/conflicts/handlers/`. Each whitelists params,
calls one service, returns locals hash.

New handlers needed:
```
show.rb, share.rb, unshare.rb, reveal.rb,
propose_resolution.rb, accept_resolution.rb,
decline_resolution.rb, reopen.rb
```

---

## Phase 6 — Views (Turbo/Hotwire)

All views in `features/conflicts/views/`.

### `home.erb`

Four sections wrapped in distinct Turbo Frame or `id`-tagged elements:

```
#conflicts-drafts        — Your drafts (each rendered via show partial)
#conflicts-pending-mine  — Shared, awaiting partner
#pending-partner         — Partner wants to share (banner + reveal form)
#conflicts-active        — Active conflicts
```

Empty state shown when all four sections are empty.

### `new.erb`

Form inside `<turbo-frame id="new_conflict_frame">`.
Fields: `title` (required, maxlength 120), `description` (maxlength 1000), `favor` (maxlength 200).

### `show.erb`

Single `<turbo-frame id="conflict-<%= id %>">`. Content varies by status:

- **draft** — shows title/description/favor + Edit, Share, Delete buttons
- **pending** (creator's view) — waiting notice + Unshare button
- **active** — full view with deadline countdown, resolution proposal buttons;
  if `proposed_status` present: shows proposal banner with Agree/Decline (for the other partner)
  or Withdraw (for proposer)
- **archived** — read-only + Reopen button

### `edit.erb`

Inline edit form inside `<turbo-frame id="conflict-<%= id %>">`.

### `reveal.erb`

Turbo Frame `#pending-partner`. Initially shows the banner: "X wants to share N conflict(s)".
On "Show me" click: replaces frame with the readiness checklist (4 checkboxes).
"I'm ready" submits `POST /reveal` → Turbo Stream updates home sections.
"Not yet" collapses the frame back to the banner.

The checklist is a separate partial (`_readiness.erb`) rendered inside the same frame.

### Turbo Stream partials

| Partial | Action | Target |
|---|---|---|
| `create.erb` | prepend | `conflicts-drafts` |
| `update.erb` | replace | `conflict-<id>` |
| `delete.erb` | remove | `conflict-<id>` |
| `share.erb` | replace | `conflict-<id>` |
| `unshare.erb` | replace | `conflict-<id>` |
| `reveal.erb` (stream) | replace `#pending-partner` + append to `#conflicts-active` | multiple targets |
| `propose.erb` | replace | `conflict-<id>` |
| `accept.erb` | remove | `conflict-<id>` |
| `decline.erb` | replace | `conflict-<id>` |

---

## Implementation Order

```
Phase 1  →  Phase 2  →  Phase 3  →  Phase 4 (tests first, then services)
         →  Phase 5  →  Phase 6
```

Phases 4–6 can be done incrementally by lifecycle stage:
1. Draft CRUD (create, list, show, edit, update, delete)
2. Share/Unshare + Reveal flow
3. Resolution flow (propose, accept, decline, withdraw)
4. Reopen
