# About

Conflict resolution app built with Sinatra, PostgreSQL, and vanilla SQL. The codebase is organized by feature, with a strict separation between routes, handlers, services, validators, and SQL functions. No ORM or raw SQL queries outside of the `functions/` directory.

# Commands

```bash
bundle                        # install gems
bundle exec rackup            # run dev server (Puma via rackup, reads .env)
bundle exec rake test         # run all tests (tests/**/*_test.rb)
bundle exec rake db:reset     # dev/test only: drop schema, create, migrate, load functions, seed
bundle exec rake db:migrate   # run pending migrations from db/migrations
bundle exec rake db:functions # reload every features/*/functions/**/*.sql
bundle exec rake db:seed      # apply db/seeds
bin/console                   # IRB with the full app loaded
```

`APP_ENV`, `DATABASE_URL`, and `SESSION_SECRET` must be set (see `.env`). `rake db:reset` refuses to run unless `APP_ENV` is `development` or `testing`.

A single test file: `bundle exec rake test TEST=tests/path/to/file_test.rb`.