# WBR Presbyterian — Church CMS

A Rails 8 content-management system and public website for West Baton Rouge Presbyterian Church. It serves the public-facing site (events, photo galleries, calendar, contact) and provides an admin area for managing events, galleries, church images, and a private member directory.

## Stack

- **Ruby** 3.2.2 / **Rails** 8.1
- **PostgreSQL** — primary database plus SolidCache, SolidQueue, and SolidCable (all backed by `DATABASE_URL`)
- **Propshaft** asset pipeline (not Sprockets)
- **Tailwind CSS** via `tailwindcss-rails` — standalone CLI, no Node/npm
- **Hotwire** (Turbo + Stimulus) with **Importmap**; Alpine.js from CDN for lightweight interactions
- **Cloudinary** for all image storage and transformations (no Active Storage)
- **Puma** + **Thruster**, deployed with **Kamal** / Docker and hosted on **Railway**

## Getting Started

### Prerequisites

- Ruby 3.2.2 (see `.ruby-version`)
- PostgreSQL running locally
- Bundler (`gem install bundler`)

### Setup

```bash
# Install dependencies
bundle install

# Create and migrate the database
bin/rails db:prepare

# Start the app (Rails server + Tailwind watcher via Foreman)
bin/dev
```

The site runs at http://localhost:3000.

### Configuration

Secrets live in `config/credentials.yml.enc` and require `RAILS_MASTER_KEY` (or `config/master.key`) to decrypt. Cloudinary credentials are stored under the `:cloudinary` key.

## Testing & Quality

```bash
bin/rails test              # Run the test suite
bin/rails test:system       # Run system tests (Capybara + Selenium)
bundle exec rubocop         # Lint (Omakase Ruby style)
bundle exec brakeman        # Static security scan
bundle exec bundler-audit   # Dependency vulnerability audit
```

## Architecture

### Authentication & Authorization

Custom session-based auth (no Devise). `ApplicationController` requires authentication by default; controllers opt specific actions into public access with `allow_unauthenticated_access`.

- **Public**: home, about, contact, accessibility; events index/show; galleries index/show; calendar
- **Admin-only**: dashboard, events/galleries CRUD, church image management, and the member directory

Key files: `app/controllers/concerns/authentication.rb`, `app/models/current.rb`, `app/models/session.rb`.

### Core Models

| Model | Purpose |
| --- | --- |
| `Event` | Church events; `category` enum, `upcoming`/`this_week`/`for_month` scopes; optional cover `Image` |
| `Gallery` | Photo galleries; has many `Image`s through `GalleryImage`; `published` flag |
| `GalleryImage` | Position-ordered join table for drag-drop reordering |
| `Image` | Cloudinary metadata with `thumbnail_url` (face crop) and `display_url` (limit crop) |
| `Member` | Private church directory; `birthdays_this_month` scope for the home page |
| `User` / `Session` | `has_secure_password`; DB-backed sessions |

### Stimulus Controllers

- `flash_controller` — auto-dismiss flash messages
- `image_preview_controller` — live preview when selecting an event image
- `lightbox_controller` — full-screen gallery viewer with keyboard nav and focus trap
- `sortable_controller` — drag-drop gallery reordering (SortableJS)

### Admin Document Pages

`specifications` and `admin_guide` are HTML pages rendered from large ERB partials in `app/views/pages/`. `_admin_guide_content.html.erb` is the **source of truth** for the admin user manual (no Markdown source). Both are wrapped in `.specs-content`, styled by `app/assets/stylesheets/technical-documents.css`.

## Deployment

Deployed to **Railway** in production and containerized with **Kamal** / Docker (multi-stage build, non-root `rails` user, Thruster + Puma on port 80). Background jobs run in-process via SolidQueue (`SOLID_QUEUE_IN_PUMA=true`), so no separate worker process is needed. `RAILS_MASTER_KEY` must be set for credentials decryption.

Health check endpoint: `GET /up` returns 200 when the app boots cleanly.
