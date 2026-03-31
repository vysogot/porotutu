# Decoupling Conflicts from Couples

Make `couple_id` nullable so conflicts can exist without a couple. Paired users are
unaffected — their conflicts still carry a `couple_id` and the reveal feature works
as before. Solo users simply get `couple_id = NULL`.

---

## 1. Migration

New file: `db/migrate/20260401000000_make_conflicts_couple_nullable.sql`

```sql
BEGIN;
ALTER TABLE conflicts ALTER COLUMN couple_id DROP NOT NULL;
COMMIT;
```

UPDATE: Just edit the current migration and db reset.

---

## 2. `features/conflicts/functions/get_conflicts.sql`

The current `WHERE c.couple_id = p_couple_id` breaks when couple_id is NULL.
Change the filter to scope by couple when present, otherwise by creator.

```sql
BEGIN;

DROP FUNCTION IF EXISTS get_conflicts(UUID, UUID);

CREATE FUNCTION get_conflicts(p_couple_id UUID, p_user_id UUID)
RETURNS TABLE(
  id UUID, couple_id UUID, creator_id UUID,
  title TEXT, description TEXT, favor TEXT,
  status TEXT, deadline TIMESTAMP, recur_count INTEGER,
  proposed_status TEXT, proposed_by_id UUID,
  created_at TIMESTAMP, updated_at TIMESTAMP, archived_at TIMESTAMP
) AS $$
BEGIN
  RETURN QUERY
    SELECT
      c.id, c.couple_id, c.creator_id,
      c.title, c.description, c.favor,
      c.status::TEXT, c.deadline, c.recur_count,
      c.proposed_status, c.proposed_by_id,
      c.created_at, c.updated_at, c.archived_at
    FROM conflicts c
    WHERE c.archived_at IS NULL
      AND (
        (p_couple_id IS NOT NULL AND c.couple_id = p_couple_id)
        OR
        (p_couple_id IS NULL AND c.creator_id = p_user_id)
      )
    ORDER BY c.created_at DESC;
END;
$$ LANGUAGE plpgsql;

COMMIT;
```

`create_conflict.sql` and `reveal_conflicts.sql` need no changes — the table
constraint removal is enough for create, and reveal is only ever called for
paired users (couple is checked before calling it).

---

## 3. `features/conflicts/services/create.rb`

Remove the `NoCouple` guard. Keep the couple lookup so paired users' conflicts
still get a `couple_id` stored. Pass `couple&.id` (nil for solo users).

```ruby
# frozen_string_literal: true

module Conflicts
  module Services
    class Create
      extend Patterns::Service

      def call(user_id:, title:, description:, favor:)
        couple = Couples::Services::FindForUser.call(user_id:)

        result = DB.connection.exec_params(
          'SELECT * FROM create_conflict($1, $2, $3, $4, $5)',
          [couple&.id, user_id, title, description, favor]
        )

        Conflict.from_row(result.first)
      end
    end
  end
end
```

---

## 4. `features/conflicts/handlers/home.rb`

Remove the early return that blocks solo users from seeing anything. Always call
`Services::List`, passing `couple&.id` (nil for solo users).

```ruby
# frozen_string_literal: true

module Conflicts
  module Handlers
    class Home
      extend Patterns::Service

      def call(current_user_id:)
        couple = Couples::Services::FindForUser.call(user_id: current_user_id)
        lists = Services::List.call(couple_id: couple&.id, user_id: current_user_id)

        {
          couple:,
          current_user_id:,
          drafts: lists[:drafts],
          pending_mine: lists[:pending_mine],
          pending_partner: lists[:pending_partner],
          active: lists[:active]
        }
      end
    end
  end
end
```

---

## 5. `features/conflicts/views/home.erb`

Remove the `couple.nil?` gate that hides all conflicts. Keep the couple check only
around the reveal section (pending_partner), which genuinely requires a partner.

```erb
<header class="container">
  <hgroup>
    <h1>Porotutu</h1>
    <p>Track and resolve conflicts together.</p>
  </hgroup>
  <nav>
    <a href="/conflicts/new" role="button" class="outline">+ New conflict</a>
  </nav>
</header>

<main class="container">
  <% if drafts.empty? && pending_mine.empty? && pending_partner.empty? && active.empty? %>
    <article>
      <p>No conflicts yet. Start one to get the conversation going.</p>
    </article>
  <% end %>

  <section>
    <h2>Your drafts</h2>
    <div id="conflicts-drafts">
      <% drafts.each do |conflict| %>
        <%= conflicts_erb :show, layout: false, locals: { conflict:, current_user_id: } %>
      <% end %>
    </div>
  </section>

  <% unless pending_mine.empty? %>
    <section>
      <h2>Shared — awaiting partner</h2>
      <div id="conflicts-pending-mine">
        <% pending_mine.each do |conflict| %>
          <%= conflicts_erb :show, layout: false, locals: { conflict:, current_user_id: } %>
        <% end %>
      </div>
    </section>
  <% end %>

  <% if couple && !pending_partner.empty? %>
    <section>
      <turbo-frame id="pending-partner" src="/conflicts/reveal">
        <p>Your partner wants to share <%= pending_partner.size %> conflict(s). <a href="/conflicts/reveal">Show me</a></p>
      </turbo-frame>
    </section>
  <% end %>

  <% unless active.empty? %>
    <section>
      <h2>Active conflicts</h2>
      <div id="conflicts-active">
        <% active.each do |conflict| %>
          <%= conflicts_erb :show, layout: false, locals: { conflict:, current_user_id: } %>
        <% end %>
      </div>
    </section>
  <% end %>
</main>
```

---

## 6. Delete `features/conflicts/errors/no_couple.rb`

The file and class are no longer referenced anywhere once `services/create.rb` is updated.

---

## What does not change

- `create_conflict.sql` — already accepts whatever is passed; the table constraint removal is enough
- `reveal_conflicts.sql` — only ever called when a couple exists; no change needed
- `features/conflicts/services/list.rb` — `couple_id:` param stays; it now receives `couple&.id`
- `features/conflicts/services/reveal.rb` — no change
- `features/conflicts/handlers/reveal.rb` — no change
- `features/conflicts/models/conflict.rb` — `couple_id` stays in the struct; it's still stored and returned for paired users
- `features/couples/` — entire feature unchanged
