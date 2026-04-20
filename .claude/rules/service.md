# Service Object Pattern

Every handler, service, and validator is a single-method class invoked as `FooService.call(...)`. The class-level `call` is provided by the `Service` module (`lib/patterns/service.rb`), which just does `new.call(...)`. This keeps each class stateless from the caller's perspective while leaving `#call` free to use instance helpers.

Use `extend Service` — never `include`. Never call `FooService.new.call` directly.

```ruby
# GOOD
class CreateHandler
  extend Service

  def call(params:, current_user_id:)
    ...
  end
end

CreateHandler.call(params:, current_user_id: session['user_id'])
```

```ruby
# BAD — include gives instance methods, not a class-level call
class CreateHandler
  include Service
end

# BAD — bypasses the convention
CreateHandler.new.call(params:, current_user_id: ...)

# BAD — module methods / def self.call
module CreateHandler
  def self.call(params:, ...)
    ...
  end
end
```

Use keyword arguments in `#call`. Never positional hashes.

Mix in other pattern modules alongside `extend Service`:

```ruby
class CreateService
  extend Service
  include DbFunctionCall   # instance method `call_function`

  def call(user_id:, title:, ...)
    result = call_function('...', p_...: ...)
    FooMapper.from_row(result.first)
  end
end

class FooValidator
  extend Service
  include Validations      # instance methods validate_presence / validate_length

  def call(params:)
    ...
  end
end
```
