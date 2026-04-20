# Turbo Conventions

## Auth forms

Always add `data-turbo="false"` to login and registration forms. Turbo's fetch-based
submission prevents session cookies from being committed before the redirect is
followed, breaking the auth flow.

```ruby
form(action: '/session', method: 'post', data: { turbo: 'false' }) do
  ...
end
```

## Views are Phlex components

Views live at `features/<name>/views/*.rb` under the `Porotutu::<Feature>::Views` namespace and inherit `PhlexView`. Routes render them with `.new(csrf_token: session['csrf_token'], **locals).call`. The shared `Porotutu::Layout` wraps page views; sub-components (e.g. `Card`) do not wrap themselves in `Layout`, they only render their own markup so they can be embedded inside an `Index`, a `Show`, or a turbo-stream `Update` without double-layout.

## Turbo streams and frames

Custom elements are rendered with `tag(:'turbo-frame', ...)` / `tag(:'turbo-stream', ...)`. Partial-replacement responses (e.g. after PATCH) render only the component that goes inside `<template>`, not a full page — see `Conflicts::Views::Update`.

## Redirects after form submission

Use `303` (not `302`) when redirecting after a Turbo form submission — Turbo
expects See Other for POST responses.

```ruby
redirect '/', 303
```
