# SQL Query Formatting

Always format `exec_params` calls with the SQL string and params array on separate lines:

```ruby
# GOOD
DB.connection.exec_params(
  'SELECT * FROM create_conflict($1)',
  [params[:name]]
)

# BAD
DB.connection.exec_params('SELECT delete_conflict($1)', [params[:id]])
```
