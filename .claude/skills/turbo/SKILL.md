---
name: turbo
description: Use when touching any HTML form, turbo-frame/stream, or post-submit redirect in this app. Covers the auth-form exception (`data-turbo="false"` on login/register/logout to let session cookies commit before the redirect), the `303` (See Other) requirement for Turbo POST redirects, and how turbo-frame/turbo-stream fragments are rendered (only the inner component, no Layout wrap). Trigger on "Turbo", "turbo-frame", "turbo-stream", any form markup, or any `redirect ..., 303` decision.
---

# Turbo Conventions

## Auth forms

Always add `data-turbo="false"` to login and registration (and logout) forms. Turbo's fetch-based submission prevents session cookies from being committed before the redirect is followed, breaking the auth flow.

```ruby
form(action: '/session', method: 'post', data: { turbo: 'false' }) do
  ...
end
```

Use the `protected_form` helper (from the `phlex-components` skill) to pass the same `data:` hash:

```ruby
protected_form(action: session_path, method: 'post', data: { turbo: 'false' }, class: 'form') do
  ...
end
```

## Redirects after form submission

Use `303` (not `302`) when redirecting after a Turbo form submission — Turbo expects See Other for POST responses.

```ruby
redirect '/', 303
```

## Turbo streams and frames

Custom elements are rendered with `tag(:'turbo-frame', ...)` / `tag(:'turbo-stream', ...)` inside Phlex views. Partial-replacement responses (e.g. after PATCH) render only the component that goes inside `<template>`, **not** a full page — the response is not wrapped in `Layout`. See `features/conflicts/views/update_view.rb` for the canonical pattern:

```ruby
tag(:'turbo-stream', action: 'replace', target: conflict_frame_id(@conflict)) do
  template do
    render CardView.new(conflict: @conflict, csrf_token: @csrf_token)
  end
end
```

A page that hosts the frame renders the sub-component inside `tag(:'turbo-frame', id: ...)`, so a subsequent turbo-stream with a matching `target:` swaps it in place.
