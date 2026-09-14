# Restaurant Menu — UI/UX Design Document

## 1\. Product Concept

A modern responsive restaurant menu website/app built with Flutter.

The first customer experience is intentionally simple:

* Browse categories.
* Browse menu items.
* Add items to cart.
* Confirm customer information and location.
* Send the order to the restaurant through WhatsApp.

The interface should feel premium, clean, fast, appetizing, and easy to use.

## 2\. Main Customer Navigation

```text
┌───────────────────────────────────────────────┐
│                 Restaurant Header             │
├───────────────────────────────────────────────┤
│                                               │
│                  Current Page                 │
│                                               │
├───────────────────────────────────────────────┤
│   Menu              Cart             Restaurant│
└───────────────────────────────────────────────┘
```

### Menu

Contains:

* Restaurant logo/name
* Optional short description
* Category navigation
* Search
* Menu item cards
* Cart badge

### Cart

Contains:

* Selected items
* Quantity controls
* Remove item
* Subtotal
* Delivery price if configured
* Total
* Checkout button

### Restaurant

Contains:

* Social media icons
* WhatsApp
* Phone/contact actions
* Branches
* Branch phone numbers
* Branch address
* Open branch location in maps

## 3\. Menu Home Screen

### Layout

```text
\[Logo] \[Restaurant Name]                 \[Cart 🛒]

\[ Search menu items... ]

\[ Category 1 ] \[ Category 2 ] \[ Category 3 ] ...

\[ Featured / Popular Items ]

┌───────────────┐  ┌───────────────┐
│     Image     │  │     Image     │
│ Item Name     │  │ Item Name     │
│ Description   │  │ Description   │
│ Price      +  │  │ Price      +  │
└───────────────┘  └───────────────┘
```

Categories should remain easy to access while scrolling.
On larger screens, categories may become a sticky horizontal category bar or a side category rail.

## 4\. Category Navigation

Categories are loaded from Firestore.

Each category can contain:

* Arabic name
* English name
* Image/icon
* Sort order
* Active state

The selected category should be visually highlighted.

## 5\. Menu Item Card

Each card should show:

* Product/item image
* Item name
* Short description
* Price
* Optional old price
* Optional badge such as Popular/New
* Add button

The card must use a consistent reusable component throughout the customer app.

## 6\. Item Details

When an item is selected:

```text
\[Large Item Image]

Item Name
★★★★★ optional rating

Description

Price

\[ - ]  1  \[ + ]

\[ Add to Cart ]
```

If the item has options/add-ons, display them before adding to cart.

## 7\. Cart Screen

```text
\[Cart]

Item A       \[-] 2 \[+]     40
Item B       \[-] 1 \[+]     25

-----------------------------
Subtotal                  65
Delivery                   10
-----------------------------
Total                     75

\[ Continue to Checkout ]
```

Cart total must update immediately after quantity changes.

Empty cart:

```text
        🛒
Your cart is empty

\[ Browse Menu ]
```

## 8\. Checkout / Customer Information

Before sending the order, show a dedicated form.

Required fields:

* Customer name
* Phone number
* Location

Location section:

```text
Delivery Location

\[ 📍 Use My Current Location ]

or

\[ Select / Use Saved Restaurant Location ]

\[ Selected Address Preview ]
```

The user must not be able to send the order without a valid name, phone, and location.

## 9\. Location UX

When **Use My Location** is pressed:

1. Request location permission.
2. Read latitude/longitude.
3. Reverse-geocode the coordinates when possible.
4. Display the formatted address.
5. Allow the customer to review the location.

If permission is denied:

* Explain why current location is required.
* Ask the customer to enable location access before sending the order.

The final review must display the selected location before sending.

## 10\. Order Review

```text
Customer
Name: Ahmed
Phone: 07xxxxxxxx

Location
\[ Map/location preview ]
Address: ...

Order
Burger x2
Pizza x1
Fries x1

Subtotal
Delivery
Total

\[ Send Order via WhatsApp ]
```

## 11\. WhatsApp Confirmation

The primary CTA should clearly say:

**إرسال الطلب عبر واتساب**

After tapping:

* Create/save the order.
* Generate the WhatsApp message.
* Open WhatsApp.
* Show a success state if the external app opens successfully.

## 12\. Restaurant Page

The Restaurant destination contains:

### Social Media

Large icon buttons for:

* Facebook
* Instagram
* TikTok
* Other configured social platforms

Tapping opens the configured external URL.

### Contact

* Call restaurant
* WhatsApp
* Email if configured

### Branches

Each branch card contains:

* Branch name
* Phone number(s)
* Address/location text
* Open in Maps button

## 13\. Responsive Design

### Mobile

* Bottom navigation.
* Menu cards: 1–2 columns.
* Full-width checkout CTA.
* Compact branch cards.

### Tablet

* Navigation can use NavigationRail.
* Menu cards: 2–4 columns.
* Wider checkout layout.

### Desktop/Web

* Top navigation or NavigationRail.
* Centered max-width content.
* Menu grid: 4+ columns.
* Checkout can use two columns:

  * Customer/location form
  * Order summary

## 14\. Visual Style

Style:

* Modern Minimal
* Restaurant/premium feel
* Large food photography
* Rounded cards
* Clear price hierarchy
* Strong primary CTA
* Subtle shadows
* Smooth micro-animations

Arabic is RTL by default.

## 15\. Required States

Every relevant screen must include:

* Loading
* Empty
* Error
* Retry
* Disabled CTA during submission
* Success feedback

## 16\. Accessibility

* Minimum comfortable tap targets.
* Strong text contrast.
* Do not rely only on color to indicate state.
* Buttons must have readable labels.
* Support keyboard navigation on Web where practical.



## Design Source of Truth

`UI\_UX\_DESIGN\_GUIDELINES.md` is the authoritative source for the visual design.

If any visual rule in this document conflicts with `UI\_UX\_DESIGN\_GUIDELINES.md`,
the UI/UX guidelines file takes precedence.

Do not introduce a new visual system independently of the guidelines.

