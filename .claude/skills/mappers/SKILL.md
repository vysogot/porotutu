---
name: mappers
description: Use when writing or editing files under `features/*/mappers/`, or when a service needs to return a typed value object instead of a raw `PG::Result` row. Covers `Data.define(...)` shape, `.from_row(row)` by explicit string keys, naming (`<Thing>Mapper` suffix), and what must not leak (password_digest and other sensitive columns). Trigger on "mapper", "Data.define", "from_row", or when shaping service return values.
---

# Mappers

Services never return raw `PG::Result` rows to callers. They map the first row into a value object defined with `Data.define`, so handlers, views, and tests work with a typed object instead of a string-keyed hash.

## Mapper shape

One mapper per domain object, named `<Thing>Mapper`, under `features/<name>/mappers/`. It's a `Data.define(...)` with a `.from_row(row)` class method that pulls each attribute out by string key.

```ruby
# GOOD
module Porotutu
  module Conflicts
    ConflictMapper = Data.define(
      :id,
      :creator_id,
      :title,
      :description,
      :favor,
      :status,
      :created_at,
      :updated_at
    ) do
      def self.from_row(row)
        new(
          id: row['id'],
          creator_id: row['creator_id'],
          title: row['title'],
          description: row['description'],
          favor: row['favor'],
          status: row['status'],
          created_at: row['created_at'],
          updated_at: row['updated_at']
        )
      end
    end
  end
end
```

```ruby
# BAD — Struct is mutable and has surprising equality / to_a behaviour
ConflictMapper = Struct.new(:id, :title, ...)

# BAD — splat hides typos in column names; we want an explicit attribute list
def self.from_row(row)
  new(**row.transform_keys(&:to_sym))
end

# BAD — class named after the domain object without the Mapper suffix
class Conflict < Data.define(...)
```

Don't put behaviour on mappers beyond `.from_row`. If you need derived logic, put it in a service — mappers stay dumb data.

## Services return mapped objects

A service that calls a mutating function returns `Mapper.from_row(result.first)`. Finders that return a collection map each row.

```ruby
# GOOD — single row
def call(user_id:, title:, ...)
  result = call_function('conflicts_crud_create', p_creator_id: user_id, ...)
  ConflictMapper.from_row(result.first)
end

# GOOD — collection
def call(user_id:)
  result = call_function('conflicts_crud_find_many', p_user_id: user_id)
  result.map do |row|
    ConflictMapper.from_row(row)
  end
end
```

```ruby
# BAD — returning raw PG::Result or string-keyed hashes leaks DB types into views
def call(...)
  call_function(...)
end

# BAD — returning only an id forces callers to do a second lookup
result.first['id']
```

Sensitive columns (`password_digest`, internal flags, etc.) must not appear in the mapper's attribute list — if it's not in `Data.define`, it can't accidentally be serialised into a view.
