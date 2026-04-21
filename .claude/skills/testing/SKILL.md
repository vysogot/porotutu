---
name: testing
description: Use when writing or editing files under `tests/` — Minitest test files ending in `_test.rb`. Covers inheriting `Porotutu::Tests::TestCase` so each test runs inside a DB transaction that rolls back in teardown, the no-mocks policy (tests hit a real Postgres), not opening your own `PG.connect` / `DbConnection.pool.with`, not cleaning up manually, and generating unique values (`SecureRandom.hex`) for unique columns like `email`. Trigger on "write a test", "add a test", `test_`, `_test.rb`, or anything involving the test runner.
---

# Tests

Minitest, run via `bundle exec rake test`. Tests hit a real Postgres (`APP_ENV=testing`, `DATABASE_URL` pointing at the test DB) — there are no mocks.

## Inherit from `Porotutu::Tests::TestCase`

Every test inherits `Porotutu::Tests::TestCase` (defined in `tests/test_helper.rb`). Its `setup` checks out a connection from `DbConnection.pool`, opens a transaction, and `teardown` rolls it back and returns the connection. That gives each test a clean slate without truncation.

```ruby
# GOOD
require_relative '../test_helper'

module Porotutu
  module Users
    class CreateServiceTest < Tests::TestCase
      def test_creates_a_user_and_returns_a_mapper
        user = Users::CreateService.call(
          params: { email: "alice-#{SecureRandom.hex(4)}@example.com", password: 'hunter22' }
        )

        assert_kind_of UserMapper, user
      end
    end
  end
end
```

```ruby
# BAD — plain Minitest::Test skips the transaction wrapping,
# leaving rows behind that break the next run
class CreateServiceTest < Minitest::Test
end

# BAD — overriding setup/teardown without calling super drops the transaction
def setup
  @user = ...
end
```

If a test needs its own fixtures, override `setup` and call `super` first.

## Don't open your own DB connections

Call the real services / SQL functions — they use `DbConnection.pool` under the hood, and the test's outer transaction will roll back everything they write. Don't `PG.connect(...)` inside a test, don't call `DbConnection.pool.with` to set up fixtures (that takes a *second* connection outside the transaction and its writes will persist).

If you need seeded data, insert it by calling the feature's own service (e.g. `Users::CreateService.call(...)`) at the top of the test — the rollback covers it.

## Don't clean up manually

No `DELETE FROM ...` in `teardown`, no `TRUNCATE`, no explicit cleanup of rows created in the test. The transaction rollback handles it. Manual cleanup hides bugs where a test leaks state and leads to order-dependent failures.

## Unique values where the schema requires them

Columns like `email` have unique constraints. Use `SecureRandom.hex(...)` (or a similar generator) to avoid collisions between tests, rather than hard-coding values that might clash with seed data or parallel runs.

```ruby
# GOOD
email: "alice-#{SecureRandom.hex(4)}@example.com"

# BAD — collides with seeds or a previous test's leftover row
email: 'alice@example.com'
```

## Run a single file

```bash
bundle exec rake test TEST=tests/users/create_service_test.rb
```
