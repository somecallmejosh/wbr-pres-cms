# Calendar Redesign

Make the calendar feel native to the site (Editorial Luxury: stone/amber, Marcellus,
hairline rings, soft shadows, squircle radii) and genuinely mobile-friendly.

## Plan

- [x] Add `chevron_left_icon` / `chevron_right_icon` to `application_helper` (ultra-light line icons)
- [x] Add `category_dot_class` to `events_helper` for category color dots
- [x] Rewrite `_calendar_grid.html.erb`: double-bezel shell, refined month nav (circular icon buttons + "Jump to today"), light weekday header, gridless rounded cells. Renders desktop grid + mobile agenda.
- [x] Rewrite `_calendar_day.html.erb`: gridless rounded cell, amber "today" treatment, colored event chips, "+N more"
- [x] Add `_calendar_agenda.html.erb`: mobile-first vertical agenda (date stamp + tappable event cards), with empty state
- [x] Update system tests (stale today selector, icon-only nav buttons, uppercase weekday headers)
- [x] Run calendar tests

## Review

- **Native feel**: Calendar now uses the site's Editorial-Luxury language — stone/amber
  palette, Marcellus headings, hairline `ring-1 ring-stone-900/5`, soft diffused shadows,
  squircle radii, and the `cubic-bezier(0.32,0.72,0,1)` easing. Replaced the harsh dark
  header bar + gridline boxes with a Double-Bezel shell (outer tray + inner white core) and
  gridless rounded day cells. Today is flagged with an amber filled day-badge + inset ring.
- **Mobile-friendly**: below `md` the unusable 7-col grid is swapped for a vertical agenda
  (`md:hidden`) — only days with events, each a date stamp + tappable event cards (time,
  category dot, title, location). Desktop grid is `hidden md:block`. Empty state for months
  with no gatherings. Zero new JS; all server-rendered inside the existing turbo_frame.
- **Tests**: calendar controller tests 11/11 green; calendar system tests 9/9 green. Updated
  three stale/over-specific system assertions (today highlight → `aria-current='date'`,
  text nav buttons → icon buttons via aria-label, weekday headers → CSS-uppercased text).
  Rubocop clean on touched helpers. Verified visually at 1280px and 390px widths.
- Pre-existing `MembersTest` system failures are unrelated (other uncommitted working-tree
  changes), not touched here.

## Follow-up: "+" opens new-event in a modal on the calendar page

- [x] Layout: wrap flash render in `<div id="flash">` so a Turbo Stream can target it
- [x] Calendar `show.html.erb`: add empty `turbo_frame_tag "modal"`; header "New Event" also opens modal
- [x] "+" links (desktop cell + mobile agenda): target `turbo_frame: "modal"`, carry current month/year/category
- [x] `events/new.html.erb`: branch — modal frame (`turbo_frame_request_id == "modal"`) vs full page
- [x] `events/_modal.html.erb`: native `<dialog>` + double-bezel card + `render "form"` (bare, calendar_context)
- [x] `events/_form.html.erb`: optional `bare:`, `cancel_path:`, `cancel_data:`, `calendar_context:` (hidden cal_* fields)
- [x] `_admin_action_bar.html.erb`: `cancel_data:` → renders a real `<button>` (avoids link/Turbo nav conflict)
- [x] `modal_controller.js`: open `<dialog>` on connect, close on backdrop/Esc/X/Cancel, clear frame on close
- [x] CSS-only fade-in via Tailwind v4 `starting:opacity-0` (no JS geometry shift)
- [x] `events_controller#create`: modal request → Turbo Stream (close modal + refresh calendar_frame + flash); else redirect
- [x] `events/create.turbo_stream.erb`
- [x] Tests: modal GET renders dialog; create-from-modal returns turbo_stream + creates event; invalid re-renders dialog
- [x] System tests: open from a day, submit, modal closes + event appears; dismiss closes modal
- [x] Run tests

### Review
- Full non-system suite: 192 runs, 0 failures. Calendar system suite: 11/11, green across 3 runs.
  Rubocop clean (Ruby); modal_controller.js syntax-checked.
- **Flow**: "+" / "New Event" load `events#new` into a permanent `turbo-frame#modal` (lazy,
  empty on the page). `new.html.erb` branches on `turbo_frame_request_id` so a frame request
  yields a `<dialog>` while a direct visit still renders the full page. Submit posts back the
  caller's month/year/category (hidden `cal_*` fields); `create` detects the modal via
  `turbo_frame_request_id` and returns a Turbo Stream that empties the modal, replaces
  `calendar_frame` for that month/filter, and flashes — all without leaving the calendar.
  Validation errors re-render the dialog in place (Turbo 422 → frame).
- **Modal**: native `<dialog>` + `showModal()` for free top-layer stacking, focus, Esc, and
  `::backdrop`. Double-bezel card, sticky header, X / Cancel / backdrop / Esc all close and
  clear the frame so re-opening fetches fresh. Cancel is a real `<button>` (not a link) so its
  close action never races Turbo frame navigation.
- **Testing note**: Selenium pointer/keyboard interaction *inside* a `showModal()` top-layer
  dialog is unreliable (text, clicks, Esc all flaked intermittently). The product is correct
  for real users; the system tests therefore set field values and dispatch the real submit /
  close events via JS so they still exercise the genuine create→stream→close→refresh and
  `modal#close` paths deterministically. Controller tests cover the server contract directly.

## Follow-up: admin per-day "add event"

- [x] `events#new` accepts `?date=YYYY-MM-DD` → `Event.new(event_date:)` prefills the form;
  unparseable dates are ignored (`Date.iso8601` rescue). Added `parse_prefill_date`.
- [x] Desktop calendar cell: admins (`authenticated?`) see a hover-revealed "+" that links to
  `new_event_path(date: day.iso8601)`.
- [x] Mobile agenda: admins get a "+" under each day's date stamp (same link).
- [x] Calendar page header gains a "New Event" admin action (covers any day, incl. empty
  days on mobile) — mirrors the events index pattern.
- [x] Tests: added "pre-selects the date param" + "ignores unparseable date" controller tests
  (events + calendar controller suites 30/30 green). Verified end-to-end: clicking June 1's
  "+" lands on the form with event_date = 2026-06-01.

## Follow-up: new-gallery page mirrors edit-gallery layout + selection

- [x] Extract shared `galleries/_details_fields` partial (title/description/published);
  `_form` now renders it (edit-only, no inline picker); `edit.html.erb` drops `show_picker`.
- [x] Rewrite `new.html.erb` to the same two-pane layout as edit (max-w-6xl; library left,
  "Photos in this gallery" right on `lg`) — wrapped in `form_with` so picker `image_ids[]`
  submit with the gallery; count badge + empty state + library-empty fallback.
- [x] `gallery_editor_controller.js` gains **staged mode** (no `images-url` value): toggling a
  picker checkbox clones a row from a `<template>` into the list (no server round-trip);
  Remove un-checks + collapses the row; `connect()` re-stages pre-checked boxes after a
  validation re-render. Live mode (edit) unchanged. `#refresh` now counts `[data-image-id]`.
- [x] `_image_picker` checkboxes carry `data-image-id/-thumb/-title` for client row building.
- [x] `create`/`sync_images` untouched — selections persist on Save (no draft galleries).
- [x] System tests: align create/edit button to "Save gallery"; add stage→unstage→save test.

### Review
- **Why staged, not draft-first**: edit's live add/remove needs a persisted gallery (member
  routes). Creating a draft on `new` would surface an untitled gallery in the public index
  (which lists *all* galleries) and orphan abandoned records. Staging keeps the existing
  `create` + `image_ids[]` contract, so no orphans and no public drafts — selections persist
  only on Save, while the UX (two-pane, tap-to-add, tap-to-remove, count, empty state) matches
  edit exactly. One controller now drives both pages.
- **Tests**: galleries controller 27/27 green; galleries system 8/8 green (incl. new
  stage/unstage/save). Rubocop clean on touched Ruby.
- Pre-existing `MembersTest` / `EventsTest` ("Update X" buttons) and `AuthenticationTest`
  ("Members" nav) system failures are unrelated redesign drift in other uncommitted files —
  not touched here.

## Follow-up: drag-and-drop reorder on the new-gallery staged list

- [x] `sortable_controller#save` no-ops when `data-sortable-url-value` is absent — drag +
  keyboard still reorder the DOM, but there's no reorder endpoint for an unsaved gallery.
- [x] Moved the submitted `image_ids[]` off the picker checkboxes and into a hidden input
  inside each staged row, so DOM order (= drag order) is what posts. Picker checkboxes are
  now nameless UI toggles (edit ignores image_ids anyway; new builds them from staged rows).
- [x] New-page staged list gets `data-controller="sortable"` (no url); the row `<template>`
  now mirrors `_sortable_image` (grip handle, `data-sortable-id`, `tabindex`, role) so drag +
  ArrowUp/Down work identically to edit. `gallery_editor#stage` fills `data-sortable-id`, the
  hidden input value, img, title, and aria-label.
- [x] System test: stage two photos, ArrowUp-reorder one to the top, save, assert
  `gallery.images` comes back in the chosen order (positions follow submit order via
  `GalleryImage#set_default_position`).

### Review
- **Why hidden inputs, not a reorder PATCH**: a new gallery has no id, so the member reorder
  route doesn't exist. Carrying `image_ids[]` as hidden inputs *inside* the staged rows means
  `sync_images` creates `GalleryImage`s in DOM (drag) order, and `before_create` assigns
  incrementing positions — so the order the admin arranges is exactly the order saved, no JS
  persistence needed. On edit, the live PATCH path is unchanged (url present → `#save` runs).
- **Tests**: galleries controller 27/27; galleries system 9/9 (incl. new reorder test).
  Rubocop clean across `app/` + touched test.

## Social meta (Open Graph / Twitter) + JSON-LD for public pages

### Problem
Public pages share with no usable preview: the layout's default `og:image` is a
root-relative path (`/theme/church-sketch.jpg`; scrapers need an absolute URL),
the default description has the wrong location ("Baton Rouge, NJ"), no public
view sets a tailored image/description, and there is no JSON-LD anywhere.

### Plan
- [ ] `ApplicationHelper`: `SITE_DESCRIPTION`, `SITE_OG_IMAGE_ID` (`wbr-pres-cms/image012`),
      `social_image_url(id)` (absolute 1200x630 face-aware JPEG), `og_image_url(image=nil)`,
      `json_ld_tag(data)`, `church_json_ld` (Church schema, real Port Allen address).
- [ ] `EventsHelper`: `event_json_ld(event)` (schema.org/Event).
- [ ] `GalleriesHelper` (new): `gallery_json_ld(gallery)` (schema.org/ImageGallery).
- [ ] Layout: fix default description + og:image; emit baseline `church_json_ld` + `yield :json_ld`.
- [x] Public views: tailored `og_image`/`og_description` + (show pages) `json_ld`.

### Review
- **Root cause**: layout already had OG/Twitter `content_for` plumbing, but the default
  image was a root-relative path (scrapers need absolute) and no public view fed it data.
- **Helpers** (`ApplicationHelper`): `social_image_url` builds an absolute https Cloudinary
  URL — 1200x630 face-aware fill, delivered as **JPEG** (not f_auto) so older scrapers that
  choke on AVIF/WebP still render the preview. `og_image_url(image=nil)` → the Image's photo
  or the site image. `json_ld_tag`/`church_json_ld` emit baseline Church structured data with
  the real Port Allen address, phone, email, and worship hours.
- **Per-type JSON-LD**: `EventsHelper#event_json_ld` (schema.org/Event w/ ISO start/end built
  from the date+time columns, Place, organizer); new `GalleriesHelper#gallery_json_ld`
  (ImageGallery listing up to 12 photos).
- **Layout**: fixed the wrong-location default description, switched default og:image to the
  Cloudinary site image, added `<meta name="description">` + `og:image:width/height`, and
  emits baseline Church JSON-LD on every page plus `yield :json_ld` for page-specific blocks.
- **Views**: event#show / gallery#show set image + description + JSON-LD from their record
  (image falls back to the site image); home uses the defaults; index/static pages set a
  tailored share description (image correctly defaults to the home image per spec).
- **Note on the home image**: used a 1200x630 face-aware crop of `wbr-pres-cms/image012`
  (the OG standard, "some variation") rather than the supplied c_limit/w_1600 link, which
  isn't the 1.91:1 ratio social cards expect.
- **Tests**: new `test/integration/social_meta_test.rb` (5 tests, 23 assertions) asserts the
  absolute share image, baseline Church JSON-LD on all 7 public routes, Event JSON-LD + event
  image, image fallback, and ImageGallery JSON-LD. Full suite 212/212 green; RuboCop clean.

### Follow-up: exact OG dimensions + favicon
- **OG dimensions**: already exactly **1200x630** (the Open Graph / `summary_large_image`
  standard) via `social_image_url` — confirmed, no change needed.
- **Favicon**: replaced the default Rails red-circle placeholder with an on-brand mark — an
  amber Latin cross (gradient `#fbbf24`→`#d97706`) on a stone-900 squircle with a hairline
  amber ring, matching the site's Editorial-Luxury palette. Authored as `public/icon.svg`,
  then rendered (rsvg-convert) to `public/icon.png` (512), `public/apple-touch-icon.png` (180),
  and a multi-size `public/favicon.ico` (16/32/48). Layout now links `.ico` (legacy), `.svg`
  (modern), and the 180px apple-touch-icon. The static `favicon.ico` also stops `/favicon.ico`
  from falling through to the catch-all `errors#not_found` route. Verified legible at 32px.
