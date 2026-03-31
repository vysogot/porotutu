# Models

Models are plain `Data.define` structs — no ORM. Define them in `features/<name>/models/<name>.rb`.

## Row casting

Each model defines a `from_row` class method that maps a `PG::Result` row hash to the struct. All type coercions (e.g. `to_i`) live here.

```ruby
Conflict = Data.define(
  :id, :couple_id, :creator_id,
  :title, :description, :favor,
  :status, :deadline, :recur_count,
  :proposed_status, :proposed_by_id,
  :created_at, :updated_at, :archived_at
) do
  def self.from_row(row)
    new(
      id: row['id'],
      couple_id: row['couple_id'],
      creator_id: row['creator_id'],
      title: row['title'],
      description: row['description'],
      favor: row['favor'],
      status: row['status'],
      deadline: row['deadline'],
      recur_count: row['recur_count'].to_i,
      proposed_status: row['proposed_status'],
      proposed_by_id: row['proposed_by_id'],
      created_at: row['created_at'],
      updated_at: row['updated_at'],
      archived_at: row['archived_at']
    )
  end
end
```

Services call `Model.from_row(row)` — never inline `Model.new(...)` with raw row access.

```ruby
# GOOD
Conflict.from_row(result.first)

result.map do |row|
  Conflict.from_row(row)
end

# BAD — casting belongs in the model, not the service
Conflict.new(id: row['id'], recur_count: row['recur_count'].to_i, ...)
```

Never define a `row_to_model` helper in services — that's `from_row`'s job.
