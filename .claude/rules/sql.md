# SQL Query Formatting

Always put the SQL string on its own line, whether using `exec` or `exec_params`:

```ruby
# GOOD — exec (no params)
DB.connection.exec(
  'SELECT * FROM get_conflicts()'
)

# GOOD — exec_params
DB.connection.exec_params(
  'SELECT * FROM get_conflict($1)',
  [params[:id]]
)

# BAD
DB.connection.exec('SELECT * FROM get_conflicts()')
DB.connection.exec_params('SELECT delete_conflict($1)', [params[:id]])
```

Always leave a blank line between the `exec`/`exec_params` block and the next statement.

## Mapping results

Use `do...end` block form, not inline `{ }`, when mapping query results:

```ruby
# GOOD
result.map do |row|
  Conflict.new(id: row['id'], name: row['name'])
end

# BAD
result.map { |row| Conflict.new(id: row['id'], name: row['name']) }
```

## Functions

All queries must go through a named SQL function. Never write raw `SELECT/INSERT/UPDATE/DELETE` directly in a service. Functions live in `features/<name>/functions/` and are loaded via `rake db:functions`.

## Calling functions from services

Services call SQL functions via `Patterns::Query#call_function`, which accepts a function name and a keyword hash of `p_*` arguments. The keys must match the SQL function's parameter names exactly — Postgres validates them and fails loudly on typos. Never pass a positional array.

```ruby
# GOOD
call_function(
  'conflicts_crud_create',
  p_creator_id: user_id,
  p_title: title,
  p_description: description,
  p_favor: favor,
  p_status: status
)

# BAD — positional array, no name validation
call_function(
  'conflicts_crud_create',
  [user_id, title, description, favor, status]
)
```

Don't align keys and values with extra spaces.

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
