---
name: validators
description: Use when writing or editing files under `features/*/validators/`, or when adding presence/length/format checks for user input. Covers validator shape (`errors = {}`, `raise ValidationError, errors if errors.any?`), the `Validations` mixin (`validate_presence`, `validate_length`), and where rescue happens (route, not handler). Trigger on "validate", "validator", "errors hash", or when shaping new form input.
---

# Validators

Every feature that accepts user input has a validator in `features/<name>/validators/` plus a feature-local `ValidationError` in `features/<name>/errors/` (see the `errors` skill for the error class itself).

## Validator shape

A validator builds an `errors = {}` hash keyed by field, then raises if it's non-empty. It returns nothing meaningful. Use the `Validations` mixin for `validate_presence` and `validate_length`.

```ruby
# GOOD
class ConflictValidator
  extend Service
  include Validations

  TITLE_MAX = 100
  DESCRIPTION_MAX = 1000
  FAVOR_MAX = 100

  def call(params:)
    errors = {}

    validate_presence(errors, params, :title, :description, :favor)
    validate_length(errors, params[:title], :title, TITLE_MAX)
    validate_length(errors, params[:description], :description, DESCRIPTION_MAX)
    validate_length(errors, params[:favor], :favor, FAVOR_MAX)

    raise ValidationError, errors if errors.any?
  end
end
```

```ruby
# BAD — returning errors instead of raising forces every caller to branch
def call(params:)
  errors = {}
  ...
  errors
end

# BAD — raising with a string loses per-field context needed by the form
raise ValidationError, 'title is required'
```

## Rescue in the route, not the handler

The route rescues `ValidationError` and re-renders the form with `errors:` and the raw `params` so fields repopulate. Handlers never rescue their own validation.

```ruby
# GOOD
post '/conflicts' do
  locals = CreateHandler.call(params:, current_user_id: session['user_id'])
  redirect "/conflicts/#{locals[:conflict].id}", 303
rescue ValidationError => e
  view :new, locals: { errors: e.errors, params: }
end
```

For `PATCH` / `PUT`, the rescue block usually needs to re-run the `Edit` handler to rebuild the full locals (record + associations) and merge `errors:` and `params:` on top — don't try to reconstruct those by hand.
