# Restaurant Menu — Current Task

## Current Task

Create the initial customer-facing responsive restaurant menu experience.

## Objective

Build the customer flow around three main navigation destinations:

1. Menu
2. Cart
3. Restaurant

## Required Scope

### Menu

* Display restaurant identity.
* Display categories.
* Display menu items dynamically.
* Provide attractive responsive cards.
* Allow adding items to cart.
* Support category filtering.
* Support search.

### Cart

* Display selected items.
* Allow quantity changes.
* Allow removing items.
* Show subtotal.
* Show delivery price.
* Show total.
* Provide checkout action.

### Checkout

Before the order is sent, require:

* Customer name.
* Phone number.
* Delivery location.

Location options:

* **Use My Location** using device GPS.
* Use the restaurant/admin configured saved location or manual location flow.

The selected location must be visible before confirmation.

### WhatsApp

The confirmation action must:

1. Validate customer information.
2. Validate location.
3. Create the order in Firestore.
4. Build the order message.
5. Read the restaurant WhatsApp number from `app\\\\\\\_config/main`.
6. Open WhatsApp with the encoded order message.

### Restaurant

Provide icons/actions for:

* Facebook
* Instagram
* TikTok
* WhatsApp
* Phone
* Email when configured

Provide a Branches section:

* Branch name
* Phone numbers
* Address/location
* Open in Maps button

## Responsive Requirements

### Mobile

Use bottom navigation.

### Tablet

Use responsive navigation with more content visible.

### Web/Desktop

Use a wider layout with a centered max-width and a responsive grid.

## Do Not Implement Yet

Do not add unrelated modules such as:

* Payment gateway
* Online payment
* Complex loyalty system
* Delivery distance pricing
* Driver application
* Restaurant POS integration
* Custom Node.js backend
* Cloudflare R2
* Advanced analytics

## Acceptance Criteria

* Customer can browse categories and menu items.
* Customer can add/remove/update cart items.
* Checkout requires name, phone, and location.
* Current location can be requested from the device.
* Saved/manual location fallback is available.
* Order is stored in Firestore.
* WhatsApp opens with a complete order message.
* Restaurant social/contact links work.
* Branch map links work.
* Layout works on mobile, tablet, and web.
* Loading, empty, and error states exist.



## Image Upload Requirement

Any admin/customer image upload flow must:

1. Select the image.
2. Compress it.
3. Ensure the final file is no larger than 500 KB.
4. Upload it to Supabase Storage.
5. Save only its URL/path in Firebase Firestore.

