# White Bluff Presbyterian Church — CMS & Web Presence

A full-stack content management system built for a local Presbyterian church, giving staff the tools to manage their congregation's digital presence without technical knowledge — and giving the public a clean, accessible window into church life.

## The Challenge

The church needed a web presence that could do two things well: serve the public with current events, photo galleries, and contact information, and give non-technical staff a straightforward admin interface to keep it all up to date. Third-party CMS platforms were either too expensive, too complex to customize, or locked behind proprietary constraints. A purpose-built solution made more sense.

## What I Built

A dual-audience Rails 8 application with a public-facing website and a full admin backend — designed from the ground up to be lightweight, maintainable, and easy for non-developers to operate.

**Public-facing features:**
- Upcoming events with category filtering (Education, Fellowship, Meetings, Community Service)
- Monthly calendar view with color-coded event categories
- Photo gallery with a fully accessible, keyboard-navigable lightbox
- Contact form with email delivery via background job processing
- About and accessibility statement pages

**Admin backend features:**
- Event CRUD with image attachment and category tagging
- Gallery management with drag-and-drop image reordering
- Image library synced with Cloudinary — staff upload once, images are available everywhere
- Private member directory with birthday tracking (surfaced on the home page each month)
- Admin guide and system specifications rendered as living HTML documents

## Technical Decisions Worth Noting

**No Node.js, no build step.** Tailwind CSS runs via the standalone CLI through the `tailwindcss-rails` gem. Importmap handles JavaScript module loading. This eliminated an entire layer of tooling complexity — there's nothing to maintain, no `node_modules`, no webpack config, no version drift.

**Custom authentication, no Devise.** A hand-rolled session-based auth system fits the simple use case — one or two admin users, cookie-backed sessions stored in the database, and a straightforward password reset flow. Less magic, easier to reason about.

**Cloudinary for all image storage.** No Active Storage, no local file handling, no S3 configuration. Images go to Cloudinary, come back via CDN with on-the-fly transformations (face-crop thumbnails, limit-crop display sizes, automatic format negotiation). Staff never think about image optimization.

**Hotwire (Turbo + Stimulus) over React.** The interactive requirements — flash dismissal, image previews, drag-and-drop reordering, lightbox navigation — are all modest enough that Stimulus controllers handle them cleanly. The result is a snappy, SPA-like experience with no JavaScript framework overhead.

**SolidQueue, SolidCache, and SolidCable all run in-process.** Background jobs, caching, and WebSocket support are handled by Rails' native Solid adapters, all sharing the same PostgreSQL database. No Redis, no separate worker dyno, no additional infrastructure cost.

**Railway + Docker + Kamal for deployment.** The application ships as a Docker container, deployed to Railway via Kamal. A non-root container user, Thruster as the HTTP proxy, and Puma as the app server keep the production setup straightforward and secure.

## Accessibility

Accessibility was treated as a requirement, not an afterthought. The gallery lightbox implements a full focus trap, ARIA dialog semantics, keyboard navigation (arrow keys, Escape), and backdrop-click dismissal. The drag-and-drop image reordering fallback supports keyboard navigation with arrow keys and announces position changes to screen readers via a live region.

## Stack

| Layer | Technology |
|---|---|
| Framework | Rails 8.1.1, Ruby 3.2.2 |
| Database | PostgreSQL |
| Asset Pipeline | Propshaft |
| CSS | Tailwind CSS (standalone, no Node) |
| JavaScript | Importmap, Stimulus, Turbo, Alpine.js |
| Images | Cloudinary |
| Background Jobs | SolidQueue (in-process) |
| Caching | SolidCache |
| Auth | Custom session-based (no Devise) |
| Deployment | Docker, Kamal, Railway |

## Outcome

The church now has a production web presence they fully own — no monthly SaaS fees, no platform lock-in, no vendor dependency. Staff manage content through a clean admin interface. The public gets a fast, accessible site. And the codebase is small enough that a single developer can maintain and extend it indefinitely.

---

*This project demonstrates what modern Rails can do when you lean into the framework's conventions rather than fighting them — a full-featured CMS shipped without a JavaScript bundler, without a third-party auth library, and without a separate background job service.*
