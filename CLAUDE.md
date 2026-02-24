# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Development (runs Rails server + Tailwind watcher via Foreman)
bin/dev

# Run all tests
bin/rails test

# Run a single test file
bin/rails test test/models/event_test.rb

# Run a single test by line number
bin/rails test test/models/event_test.rb:42

# Run system tests
bin/rails test:system

# Lint (Omakase Ruby style — no custom overrides)
bundle exec rubocop

# Security scan
bundle exec brakeman

# Dependency audit
bundle exec bundler-audit

# Rails console
bin/rails console

# DB tasks
bin/rails db:migrate
bin/rails db:schema:load

# Tailwind (standalone, no Node)
bin/rails tailwindcss:build
bin/rails tailwindcss:watch
```

## Architecture

### Stack

- **Rails 8.1.1**, Ruby 3.2.2
- **Propshaft** (asset pipeline, not Sprockets)
- **Tailwind CSS** via `tailwindcss-rails` gem — standalone CLI, no Node/npm. No `@tailwindcss/typography` plugin. Custom `.specs-content` CSS class in `app/assets/stylesheets/technical-documents.css` provides prose styling for admin document pages.
- **Importmap + Stimulus** — no webpack/esbuild. Alpine.js loaded from CDN for `x-data` directives (navbar mobile menu).
- **Hotwire** (Turbo + Stimulus) for SPA-like interactions without a full JS framework.
- **PostgreSQL** — primary database plus SolidCache, SolidQueue, SolidCable (all via `DATABASE_URL`).
- **Cloudinary** — all image storage (no Active Storage). Credentials in `config/credentials.yml.enc` under the `:cloudinary` key.

### Authentication

Custom session-based auth (no Devise). Key files:

- `app/controllers/concerns/authentication.rb` — `require_authentication` before-action, `authenticated?` helper, signed `session_id` cookie
- `app/models/current.rb` — `CurrentAttributes` giving thread-safe `Current.session` / `Current.user`
- `app/models/session.rb` — DB-backed session records
- `ApplicationController` includes `Authentication` and requires auth by default. Controllers opt out with `allow_unauthenticated_access only: [...]`.

### Authorization

Implicit via controller-level `allow_unauthenticated_access`:

- **Public**: `home`, `contact`, `about` (PagesController); `events#index`, `events#show`; `galleries#index`, `galleries#show`; `calendar#show`; session/password actions
- **Admin-only**: everything else — `members` CRUD, `admin/images` CRUD + sync, all create/edit/delete for events and galleries, `dashboard`, `specifications`, `admin_guide`

### Key Models

- **Event** — belongs to optional `Image`; enum `category` (education, fellowship, meetings, community_service); scopes: `upcoming`, `this_week`, `for_month`, `by_category`
- **Gallery** — has many `Images` through `GalleryImage` (join table with `position`); `published` boolean; `cover_image` returns first image
- **GalleryImage** — position-ordered join table; `before_create` sets `position` to `max + 1`
- **Image** — stores Cloudinary metadata (`cloudinary_public_id`, `url`, dimensions); `thumbnail_url` (face-crop) and `display_url` (limit crop) use Cloudinary transformation URLs
- **Member** — private church directory; `birthdays_this_month` scope used on home page; `full_name`, `birthday_display` methods
- **User** / **Session** — `has_secure_password`; sessions destroyed on sign-out

### Stimulus Controllers (`app/javascript/controllers/`)

| Controller                 | Purpose                                                                              |
| -------------------------- | ------------------------------------------------------------------------------------ |
| `flash_controller`         | Auto-dismiss flash messages after 5s                                                 |
| `image_preview_controller` | Live preview when selecting an event image                                           |
| `lightbox_controller`      | Full-screen gallery viewer with keyboard nav + focus trap                            |
| `sortable_controller`      | Drag-drop gallery image reordering (SortableJS); sends `PATCH galleries/:id/reorder` |

### Routes of Note

- Hyphenated paths use explicit `as:` aliases: `get "admin-guide", to: "pages#admin_guide", as: :admin_guide`
- Gallery reorder: `patch :reorder, on: :member`
- Admin images namespaced: `namespace :admin { resources :images }`
- Catch-all at bottom: `match "*path", to: "errors#not_found", via: :all`

### Admin Document Pages

`specifications` and `admin_guide` are HTML pages rendered from large ERB partials:

- `app/views/pages/_specifications_content.html.erb`
- `app/views/pages/_admin_guide_content.html.erb`

`_admin_guide_content.html.erb` is the **source of truth** for the admin user manual (no Markdown source). Both partials are wrapped in `<div class="specs-content">` which picks up styles from `technical-documents.css`.

Ensure all updates are accounted for in these ERB files, and that the corresponding routes and controller actions are updated if needed.

### Deployment

- **Railway** (production) — see `MEMORY.md` for `DATABASE_URL` and env var details
- **Docker** via Kamal — multi-stage build, non-root `rails` user, `Thruster` + Puma on port 80
- `SOLID_QUEUE_IN_PUMA=true` runs background jobs in-process (no separate worker dyno)
- `RAILS_MASTER_KEY` must be set for credentials decryption
