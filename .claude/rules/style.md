# General Coding Style

## No whitespace alignment

Never pad with extra spaces to align `=`, `=>`, hash values, or method bodies. One space before and after operators, always.

```ruby
# GOOD
DATABASE_URL = ENV.fetch('DATABASE_URL')
ROOT_DIR = File.expand_path('..', __dir__)
DB_DIR = File.join(ROOT_DIR, 'db')

def production? = ENV['APP_ENV'] == 'production'
def testing? = ENV['APP_ENV'] == 'testing'
def development? = ENV['APP_ENV'] == 'development'

# BAD
DATABASE_URL = ENV.fetch('DATABASE_URL')
ROOT_DIR     = File.expand_path('..', __dir__)
DB_DIR       = File.join(ROOT_DIR, 'db')

def production?  = ENV['APP_ENV'] == 'production'
def testing?     = ENV['APP_ENV'] == 'testing'
def development? = ENV['APP_ENV'] == 'development'
```

Same rule for hash literals, keyword arguments, and case/when bodies. Let the code flow on its own; do not reformat neighbors when renaming one of them.
