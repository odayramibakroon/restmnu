# Restaurant Menu — Project Progress

## Overall Goal

Responsive Flutter restaurant menu website/app with:
- Menu browsing
- Categories
- Cart
- Customer checkout
- Automatic current GPS location
- WhatsApp ordering
- Social media
- Branches
- Maps
- Contact actions
- Admin management

## Phase 1 — Foundation

- [x] Flutter project configured
- [x] Firebase initialized
- [x] Clean Architecture folders created
- [x] BLoC/Cubit configured
- [x] `get_it` configured
- [x] Theme system created
- [x] Arabic RTL configured
- [x] Responsive breakpoints created
- [x] Routing configured

## Phase 2 — Restaurant Configuration

- [x] `app_config/main` schema implemented
- [x] Restaurant logo display
- [x] Restaurant name display
- [x] Restaurant description display
- [x] WhatsApp configuration
- [x] Contact information
- [x] Social links
- [x] Default delivery price
- [x] Saved restaurant delivery location

## Phase 3 — Menu

- [x] Categories Firestore integration
- [x] Menu items Firestore integration
- [x] Removed local `SeedData` seeding/fallback content
- [x] Category filtering
- [x] Search
- [x] Menu item cards
- [x] Item details
- [x] Availability handling
- [x] Popular/New badges
- [x] Responsive grid

## Phase 4 — Cart

- [x] Add item
- [x] Increase quantity
- [x] Decrease quantity
- [x] Remove item
- [x] Empty cart state
- [x] Subtotal
- [x] Delivery price
- [x] Total
- [x] Cart badge

## Phase 5 — Checkout

- [x] Customer name field
- [x] Phone field
- [x] Location section
- [x] Use current location
- [x] Current GPS location only
- [x] Address preview
- [x] Order review
- [x] Validation
- [x] Send WhatsApp-only order without Firestore persistence

## Phase 6 — WhatsApp Ordering

- [x] WhatsApp number loaded from Firestore
- [x] Order message generator
- [x] URL encoding
- [x] Open WhatsApp
- [x] Success state
- [x] Error state
- [x] Prevent duplicate submission

## Phase 7 — Restaurant Information

- [x] Social media icons
- [x] Facebook
- [x] Instagram
- [x] TikTok
- [x] WhatsApp
- [x] Phone
- [x] Email
- [x] Branch list
- [x] Branch phone numbers
- [x] Branch location
- [x] Open in maps

## Phase 8 — Admin

- [x] Admin authentication
- [x] Categories management
- [x] Menu items management
- [x] Branches management
- [x] Restaurant settings management
- [x] Orders list not required because invoices are WhatsApp-only
- [x] Order details not required because invoices are WhatsApp-only
- [x] Order status updates not required because invoices are WhatsApp-only

## Phase 9 — Responsive Web

- [x] Mobile layout
- [x] Tablet layout
- [x] Desktop layout
- [x] Responsive navigation
- [x] Responsive menu grid
- [x] Responsive checkout
- [ ] Keyboard accessibility
- [x] Web URL launch testing

## Verification

```text
flutter analyze
flutter test
flutter build web --debug
```

## Status

Initial customer-facing menu experience implemented.


## Confirmed Architecture Decisions

- [x] Supabase Storage is used for application images.
- [x] Firebase Firestore stores application data and image URLs/paths.
- [x] Images must be compressed to <= 500 KB before upload.
- [x] Implement shared image compression service.
- [x] Implement shared Supabase image storage service.
- [x] Apply UI/UX rules from `UI_UX_DESIGN_GUIDELINES.md`.
