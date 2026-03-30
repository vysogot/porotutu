# Turbo Conventions

## Auth forms

Always add `data-turbo="false"` to login and registration forms. Turbo's fetch-based
submission prevents session cookies from being committed before the redirect is
followed, breaking the auth flow.

```erb
<form action="/session" method="post" data-turbo="false">
```

## Redirects after form submission

Use `303` (not `302`) when redirecting after a Turbo form submission — Turbo
expects See Other for POST responses.

```ruby
redirect '/', 303
```
