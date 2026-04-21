---
name: testing
description: Use when writing or editing files under `tests/` — Minitest test files ending in `_test.rb`. Covers inheriting `Porotutu::Tests::TestCase` (DB-transaction rollback), `Tests::RequestTestCase` (Rack::Test + same-connection pinning), factories under `tests/support/factories/` that INSERT directly (not through feature services), folder structure mirroring `features/<name>/`, the no-mocks policy, and unique values (`SecureRandom.hex`) for unique columns. Trigger on "write a test", "add a test", `test_`, `_test.rb`, or anything involving the test runner.
---

# Tests

Minitest, run via `bundle exec rake test`. Tests hit a real Postgres (`APP_ENV=test` set by `test_helper.rb`, `DATABASE_URL` pointing at the test DB) — there are no mocks.

## Folder structure mirrors `features/<name>/`

For each `features/<name>/<layer>/<file>.rb` there's a `tests/<name>/<layer>/<file>_test.rb`:

```
tests/
  test_helper.rb
  support/
    factories/
      user_factory.rb
      conflict_factory.rb
  users/
    routes_test.rb
    services/, handlers/, helpers/, mappers/
  conflicts/
    routes_test.rb
    services/, handlers/, validators/, helpers/, mappers/
```

Not currently tested as units: views (rendered via request specs instead), SQL functions (covered via services), per-feature error classes (trivial data).

## Inherit from `Porotutu::Tests::TestCase`

`Tests::TestCase` (in `tests/test_helper.rb`) checks out a connection from `DbConnection.pool`, opens a transaction in `setup`, rolls it back in `teardown`, and **pins** that connection so `DbConnection.with` yields the same one throughout the test. That means factories and services both see each other's writes, and the rollback covers everything.

```ruby
# GOOD
require_relative '../test_helper'

module Porotutu
  module Users
    class CreateServiceTest < Tests::TestCase
      def test_creates_a_user_and_returns_a_mapper
        user = CreateService.call(
          params: { email: "alice-#{SecureRandom.hex(4)}@example.com", password: 'hunter22' }
        )

        assert_kind_of UserMapper, user
      end
    end
  end
end
```

```ruby
# BAD — plain Minitest::Test skips transaction wrapping and connection pinning
class CreateServiceTest < Minitest::Test
end

# BAD — overriding setup without `super` drops the transaction and pinning
def setup
  @user = ...
end
```

If a test needs seeded data, override `setup` and call `super` first, then use a factory.

## Use factories, not feature services, for test setup

Factories live in `tests/support/factories/` and `INSERT` directly into tables using the test's checked-out `@_db_conn`. They do NOT go through feature plpgsql functions or services. That isolates tests from feature code: a broken `CreateService` won't cascade into every login test.

```ruby
# GOOD — factory writes directly to the `users` table
@user = Tests::Factories::UserFactory.create(conn: @_db_conn)
# row hash, e.g. @user['id'], @user['email']

# BAD — couples the login test to CreateService
Users::CreateService.call(params: { email: ..., password: ... })
```

Factories return **raw row hashes** (`PG::Result` rows), not mappers. Mappers are feature code; factories are deliberately feature-free. If a test wants a mapper it can pass the row through one itself.

When adding a new table, add a matching factory module under `tests/support/factories/` (naming: `<thing>_factory.rb` → `Tests::Factories::<Thing>Factory.create(conn:, **fields)`). Generate unique defaults (`SecureRandom.hex`) for uniquely-constrained columns.

## Request/route tests: `Tests::RequestTestCase`

Route tests inherit `Tests::RequestTestCase`, which adds `Rack::Test::Methods` and mounts the full `Porotutu::App`. Authentication is done by writing the user id into the Rack session directly — do **not** drive login through `POST /session` unless that's what the test is about.

```ruby
class RoutesTest < Tests::RequestTestCase
  def setup
    super
    @user = Tests::Factories::UserFactory.create(conn: @_db_conn)
    env 'rack.session', { 'user_id' => @user['id'] }
  end

  def test_get_index
    get '/conflicts'
    assert_equal 200, last_response.status
  end
end
```

CSRF is disabled in test (`CsrfProtection` skips when `APP_ENV == 'test'`), so mutating requests don't need a token.

Sinatra appends `;charset=utf-8` to some content types — match with `assert_includes`, not `assert_equal`.

## Don't open your own DB connections

Don't `PG.connect(...)` inside a test. Don't call `DbConnection.pool.with` or `.checkout` for fixture setup — the pinning only redirects `DbConnection.with`, but you'd be bypassing pinning entirely and double-checking-out from the pool. Use the factory (which takes `conn: @_db_conn`) or write `@_db_conn.exec_params(...)` directly for one-off assertions.

## Don't clean up manually

No `DELETE FROM ...` in `teardown`, no `TRUNCATE`, no explicit cleanup. The transaction rollback handles it. Manual cleanup hides bugs where a test leaks state and leads to order-dependent failures.

## Unique values where the schema requires them

Factories default to `SecureRandom.hex` for unique columns. When you override (e.g. passing an explicit `email:`), make it unique yourself:

```ruby
# GOOD
email: "alice-#{SecureRandom.hex(4)}@example.com"

# BAD — collides with seeds or a previous test's leftover row if rollback ever fails
email: 'alice@example.com'
```

## Run a single file

```bash
bundle exec rake test TEST=tests/users/create_service_test.rb
```
