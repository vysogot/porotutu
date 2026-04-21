---
name: sql-queries
description: Use when writing Ruby code that talks to Postgres in this app — especially services calling `call_function(...)` (from `lib/infra/db_function_call.rb`) or the rare direct `DB.connection.exec`/`exec_params` call. Covers SQL-string-on-its-own-line formatting, `p_*` keyword-arg convention for function calls, and the `do...end` block form for mapping results. Trigger when editing files under `features/*/services/` or anywhere a SQL query appears in Ruby.
---

# SQL Queries (Ruby side)

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

## Calling functions from services

Services call SQL functions via `DbFunctionCall#call_function` (from `lib/infra/db_function_call.rb`), which accepts a function name and a keyword hash of `p_*` arguments. The keys must match the SQL function's parameter names exactly — Postgres validates them and fails loudly on typos. Never pass a positional array.

```ruby
# GOOD
call_function(
  'conflicts_create',
  p_creator_id: user_id,
  p_title: title,
  p_description: description,
  p_favor: favor,
  p_status: status
)

# BAD — positional array, no name validation
call_function(
  'conflicts_create',
  [user_id, title, description, favor, status]
)
```

Don't align keys and values with extra spaces.

For the plpgsql function file structure itself (DROP+CREATE, `RETURNING *`), see the `functions` skill.
