---
name: functions
description: Use when writing or editing SQL files under `features/*/functions/` — the plpgsql functions that back every service in this ORM-less app. Covers the transaction-wrapped DROP+CREATE structure (not `CREATE OR REPLACE`), parameter-type-only DROP signature, and the rule that mutating functions must `RETURNING *` the affected row so services can return a mapped object. Trigger on "SQL function", "plpgsql", or when adding/editing a `*.sql` file loaded by `rake db:functions`.
---

# SQL Functions

All queries in this app go through a named plpgsql function. Functions live in `features/<name>/functions/` and are loaded wholesale via `rake db:functions`. Never write raw `SELECT/INSERT/UPDATE/DELETE` directly in a Ruby service.

## Function file structure

Every SQL function file must wrap its contents in a transaction, drop the existing function first, then create it fresh. Use `CREATE` not `CREATE OR REPLACE` — the DROP makes OR REPLACE redundant, and OR REPLACE silently ignores return type changes instead of failing loudly.

```sql
BEGIN;

DROP FUNCTION IF EXISTS my_function(UUID, TEXT);

CREATE FUNCTION my_function(p_id UUID, p_name TEXT)
RETURNS ... AS $$
BEGIN
  ...
END;
$$ LANGUAGE plpgsql;

COMMIT;
```

The `DROP FUNCTION IF EXISTS` signature must list parameter types only (no names), matching the function's argument list exactly.

## Mutating functions must return the affected row

Functions that INSERT or UPDATE must return the affected row using `RETURNING *` (or a specific column list). Never return `VOID` from a mutating function. Services must return `Model.from_row(result.first)` so callers always have the updated object — never a bare id.

```sql
-- GOOD
CREATE FUNCTION update_thing(p_id UUID, p_name TEXT)
RETURNS SETOF things AS $$
BEGIN
  RETURN QUERY
  UPDATE things SET name = p_name WHERE id = p_id
  RETURNING *;
END;
$$ LANGUAGE plpgsql;

-- BAD
CREATE FUNCTION update_thing(p_id UUID, p_name TEXT)
RETURNS VOID AS $$
BEGIN
  UPDATE things SET name = p_name WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;
```

For calling these functions from Ruby services see the `sql-queries` skill.
