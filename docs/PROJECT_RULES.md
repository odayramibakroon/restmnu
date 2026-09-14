# Restaurant Menu Flutter — Project Rules

## Project Goal
Build a production-ready responsive restaurant menu website and Flutter application.

The customer experience is focused on:
- Browsing restaurant categories and menu items.
- Adding items to a cart.
- Entering customer name and phone before checkout.
- Selecting the current delivery location automatically.
- Sending the final order to the restaurant through WhatsApp.
- Sending customer invoices/orders through WhatsApp only without Firestore persistence.
- Accessing restaurant social media, branches, phone numbers, WhatsApp, and map locations.

## Main Stack
- Flutter / Dart
- Clean Architecture
- BLoC / Cubit
- Repository Pattern
- Dependency Injection with `get_it`
- Firebase Authentication when authentication is required
- Firebase Firestore
- Supabase Storage for all application images
- Responsive UI for Mobile, Tablet, and Web
- Arabic RTL first, with optional English LTR
- Light and Dark themes
- `geolocator` / `geocoding` for customer location
- `url_launcher` for WhatsApp, phone, email, social media, and maps
- Image compression before upload: every stored image must be <= 500 KB

## Architecture
Use feature-first Clean Architecture:

```text
lib/
├── core/
│   ├── config/
│   ├── constants/
│   ├── theme/
│   ├── services/
│   ├── utils/
│   ├── errors/
│   └── di/
│
├── features/
│   ├── menu/
│   ├── categories/
│   ├── cart/
│   ├── checkout/
│   ├── restaurant_info/
│   ├── branches/
│   └── settings/
│
└── admin/
    ├── dashboard/
    ├── categories/
    ├── menu_items/
    ├── branches/
    └── settings/
```

Each feature should contain:
- `data/`
- `domain/`
- `presentation/`

Business logic must not be placed inside UI widgets.

## Navigation
Customer navigation contains four primary destinations:

1. **Menu**
   - Categories
   - Menu items
   - Search
   - Item details

2. **Cart**
   - Selected items
   - Quantity controls
   - Order summary
   - Checkout

3. **Restaurant**
   - Social media
   - Branches
   - Phone numbers
   - WhatsApp
   - Open location in maps

4. **Settings**
   - Admin login
   - Admin dashboard after successful login

On narrow mobile screens use a bottom navigation bar.
On tablet/web use a responsive navigation rail or top navigation when appropriate.

## Responsive Rules
- Mobile: 1–2 menu item columns depending on width.
- Tablet: 2–4 columns.
- Desktop/Web: 4+ columns when space permits.
- Never hard-code a single screen width.
- Use `LayoutBuilder` or responsive breakpoints.
- Preserve readable maximum content width on large screens.
- Navigation must remain accessible without excessive horizontal scrolling.

## Firebase Rules
Firestore is the source of truth for restaurant configuration, categories, menu items, branches, and admin-managed content.
Customer invoices/orders are not stored in Firestore in the current flow.

Admin-only operations must be protected using Firebase Authentication and an admin role.

## Location Rules
The customer may:
- Press **Use My Location** to request the current GPS location.
- Review the selected location before sending the order.

The customer location must not be stored.
Latitude, longitude, and formatted address are used only inside the WhatsApp message.

Location permission denial must produce a clear message asking the customer to enable location access.

## WhatsApp Rules
After successful checkout validation:
1. Build the order message.
2. Read the restaurant WhatsApp number from Firestore.
3. Encode the message.
4. Open WhatsApp using `https://wa.me/{number}?text={encodedMessage}`.

The message must contain:
- Restaurant name
- Customer name
- Phone
- Location/address
- Ordered items
- Quantity
- Item price
- Subtotal
- Delivery price if applicable
- Total
- Temporary order reference

## Async Safety
Every async Cubit operation must check `isClosed` after awaited operations before emitting another state.

## Error Handling
All Firebase operations in data sources must use `try/catch` and convert Firebase errors to readable application exceptions.

## UI Quality
Every customer screen must support:
- Loading state
- Empty state where applicable
- Error state
- Retry action where applicable
- Smooth micro-animations
- RTL Arabic
- Responsive layout
- Accessible tap targets


## Image Storage
- Images are stored in **Supabase Storage**, not Firebase Storage.
- Images must be compressed before upload.
- Maximum final image size: **500 KB per image**.
- Firebase Firestore stores image URLs/paths only.
- Do not store image binary data inside Firestore.
