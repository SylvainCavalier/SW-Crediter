# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SW-Crediter is a Star Wars-themed Rails 7.1 web app (Ruby 3.1.2) serving as an in-universe "comlink" for a GN (Grandeur Nature / LARP) event. Players use it on their smartphones as their personal comlink to exchange credits, communicate via Holonews, and access class-specific features (e.g. repairs for technicians, hacking for hackers). The UI is in French.

## Common Commands

- **Dev server:** `bin/rails server` (no Procfile.dev — uses importmap, no JS build step)
- **Console:** `bin/rails console`
- **Database setup:** `bin/rails db:create db:migrate db:seed`
- **Run migrations:** `bin/rails db:migrate`
- **Run all tests:** `bin/rails test`
- **Run single test file:** `bin/rails test test/models/user_contacts_test.rb`
- **Run single test by name:** `bin/rails test test/models/user_contacts_test.rb -n test_name`
- **Routes:** `bin/rails routes`

Database: PostgreSQL (`sw_gn_development` / `sw_gn_test`).

## Architecture

### Authentication & Users

Devise with **username** as the authentication key (not email). Users belong to a `Group` and have `credits` (integer), a `pazaak_deck` (jsonb), and `contacts` (jsonb array of user IDs).

### Core Domains

- **Credits/Transactions** — Users transfer credits to each other. Real-time balance updates via Turbo Streams / ActionCable (`broadcast_credits_update` on User model).
- **Holonews** — In-universe messaging system. Messages (`Holonew`) can target a user or group. Read tracking via `HolonewRead` join model. Sender can use an alias.
- **Contacts** — Stored as a jsonb array of user IDs directly on the `users` table. Methods on User model (`add_contact`, `remove_contact`, `get_contacts`).
- **Inventory** — `InventoryObject` with rarity/category/price, linked to users through `UserInventoryObject` (with quantity).
- **Pazaak** — Full card game with its own namespace (`Pazaak::*` controllers, `pazaak_*` models). Uses ActionCable (`PazaakLobbyChannel`) for real-time lobby presence and invitations with credit stakes. Game state stored as serialized text fields on `PazaakGame`.
- **PWA** — Service worker and manifest for installable web app. Push notifications via `webpush` gem through `Subscription` model.

### Frontend

- **Hotwire stack**: Turbo (Turbo Frames, Turbo Streams) + Stimulus controllers
- **importmap-rails** — no Node.js/yarn/webpack needed. JS pins in `config/importmap.rb`
- **Bootstrap 5.2** with SASS (`sassc-rails`), Font Awesome icons
- Stimulus controllers in `app/javascript/controllers/` (credits, holonews, contacts, pazaak deck/lobby, push notifications, modals, toggles)

### Real-time Features

ActionCable with PostgreSQL adapter (`actioncable-enhanced-postgresql-adapter`). Used for:
- Credit balance live updates
- Pazaak lobby presence and game state

### Key Patterns

- Pazaak game logic lives in the models (`PazaakGame`) with state serialized as JSON text fields (`host_state`, `guest_state`)
- Turbo Stream broadcasts from models for real-time updates
- Kramdown gem used for Markdown rendering
- Kaminari for pagination
- Cloudinary for image storage (avatars)
