# Sinatra Conventions

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
