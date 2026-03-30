# Turbo Conventions

## Auth forms

Always add `data-turbo="false"` to login and registration forms. Turbo's fetch-based
submission prevents session cookies from being committed before the redirect is
followed, breaking the auth flow.

```erb
<form action="/session" method="post" data-turbo="false">
```

## Rendering sub-templates inside ERB

Always pass `layout: false` when calling a `feature_erb` helper from within another
template. Without it, the shared layout (nav, etc.) is rendered again for each call.

```erb
<%# GOOD — called from within a template %>
<%= conflicts_erb :show, layout: false, locals: { id:, name: } %>

<%# BAD — renders the full layout inside the template %>
<%= conflicts_erb :show, locals: { id:, name: } %>
```

Only route handlers should call `feature_erb` helpers without `layout: false`.

## Redirects after form submission

Use `303` (not `302`) when redirecting after a Turbo form submission — Turbo
expects See Other for POST responses.

```ruby
redirect '/', 303
```
