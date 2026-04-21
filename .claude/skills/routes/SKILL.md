---
name: routes
description: Use when writing or editing `features/*/routes.rb` — the per-feature `Sinatra::Base` subclasses mounted by `app.rb`. Covers "routes stay thin" (only HTTP concerns — params, session, redirect, render), rescuing `ValidationError` at the route layer, and the modular-app Sinatra::Reloader placement inside `configure :development`. Trigger when adding a new route, converting a fat route into a handler call, or touching the top-level `App < Sinatra::Base`.
---

# Routes

Each feature has a `routes.rb` defining a `Sinatra::Base` subclass mounted by `Porotutu::App` in `app.rb`. Routes deal **only** with HTTP concerns: extracting `params` / `session`, calling a single handler, and responding (redirect, render, status).

## Routes stay thin

Routes extract session/params, call a single handler, and respond. No business logic, no DB access, no validation beyond what the handler does.

```ruby
# GOOD
post '/conflicts' do
  locals = CreateHandler.call(params:, current_user_id: session['user_id'])

  redirect "/conflicts/#{locals[:conflict].id}", 303
rescue ValidationError => e
  view :new, locals: { errors: e.errors, params: }
end
```

```ruby
# BAD — validation + service call in the route
post '/conflicts' do
  ConflictValidator.call(params:)
  conflict = CreateService.call(...)
  redirect "/conflicts/#{conflict.id}", 303
end
```

The route rescues the feature's `ValidationError` and re-renders the form with `errors:` and the raw `params` so fields repopulate. Handlers never rescue their own validation.

## Reloader (modular app)

Use `register Sinatra::Reloader` inside `configure :development` within the class — top-level `also_reload` only applies to classic (non-modular) Sinatra apps.

```ruby
class App < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    also_reload File.join(__dir__, 'patterns/**/*.rb')
    also_reload File.join(__dir__, 'features/**/*.rb')
  end
end
```

## Turbo-aware redirects

After a form POST, redirect with `303` (See Other), not `302` — Turbo expects See Other. See the `turbo` skill for the rest of the Turbo contract (auth forms, frames, streams).
