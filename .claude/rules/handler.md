# Handlers and Routes

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

Handlers never touch `session`, `request`, `response`, or `redirect`. Pass `current_user_id:` in as a keyword arg — don't reach into Sinatra from the handler.
