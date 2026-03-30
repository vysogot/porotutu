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
