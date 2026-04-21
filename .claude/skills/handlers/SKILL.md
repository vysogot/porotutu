---
name: handlers
description: Use when writing or editing files under `features/*/handlers/` in this Sinatra/Porotutu app. Covers the handler contract — `extend Service`, slicing params at the top, calling the feature's validator then service(s), and returning a `locals` hash for the view. Trigger when adding a new feature slice, or when a route is getting too fat and needs to delegate to a handler. Also load when designing the boundary between the thin `Routes < Sinatra::Base` and the orchestration layer.
---

# Handlers

Each feature has a thin `Routes < Sinatra::Base` that only deals with HTTP concerns (params, session, redirect, response type, template rendering). Everything else goes into a handler in `features/<name>/handlers/`.

## Handler contract

A handler:
1. `slice`s the params it actually needs from the raw `params` hash.
2. Calls the validator (which raises `ValidationError` on failure).
3. Calls one or more services.
4. Returns a `locals` hash for the view.

```ruby
# GOOD
class CreateHandler
  extend Service

  def call(params:, current_user_id:)
    params = params.slice(:title, :description, :favor)

    ConflictValidator.call(params:)

    conflict = CreateService.call(
      user_id: current_user_id,
      title: params[:title],
      description: params[:description],
      favor: params[:favor],
      status: 'draft'
    )

    { conflict:, current_user_id: }
  end
end
```

Always `slice` the params at the top of the handler. Never pass the whole `params` hash down into validators or services — it leaks route/query-string keys and defeats the whitelist.

```ruby
# BAD — passes untrusted keys (splat, commit, id from URL, etc.) onward
ConflictValidator.call(params:)
CreateService.call(**params)
```

## Handlers never touch HTTP

Handlers never touch `session`, `request`, `response`, or `redirect`. Pass `current_user_id:` in as a keyword arg — don't reach into Sinatra from the handler. Handlers never rescue their own validation — the route does that and re-renders the form.
