# Restaurant Menu — Firestore Database Schema

## 1. app_config/main

Single restaurant configuration document.

```js
{
  storeNameAr: string,
  storeNameEn: string,

  storeDescriptionAr: string,
  storeDescriptionEn: string,

  logoUrl: string,

  whatsappNumber: string,
  supportPhone: string,
  supportEmail: string,

  facebookUrl: string,
  instagramUrl: string,
  tiktokUrl: string,

  defaultDeliveryPrice: number,

  savedDeliveryLocation: {
    latitude: number,
    longitude: number,
    formattedAddress: string
  },

  currency: string,
  enableDarkMode: boolean,

  updatedAt: timestamp
}
```

`defaultDeliveryPrice` is only the initial/default value. If the business later needs per-order delivery editing, that should be handled separately.

## 2. categories

There is no stored `cat_all`/all category document. The "All" option is UI-only.

```js
{
  id: string,

  nameAr: string,
  nameEn: string,

  imageUrl: string,

  sortOrder: number,
  isActive: boolean,

  createdAt: timestamp,
  updatedAt: timestamp
}
```

Customer visibility requires:

```text
isActive == true
```

## 3. menu_items

```js
{
  id: string,

  categoryId: string,

  nameAr: string,
  nameEn: string,

  descriptionAr: string,
  descriptionEn: string,

  price: number,
  oldPrice: number,

  imageUrl: string,
  images: string[],

  isPopular: boolean,
  isNew: boolean,
  isAvailable: boolean,
  isActive: boolean,

  unitType: "piece" | "weight",
  sizes: string[],
  sizePrices: {
    [sizeName]: number
  },

  sortOrder: number,

  createdAt: timestamp,
  updatedAt: timestamp
}
```

When `sizes` is not empty, each size must have a matching price in `sizePrices`.
For weight-based items, quantity is entered and sent in kilograms, and decimal
values are allowed, for example `1.25` kg or `0.100` kg.

Customer must not show an item when:
- `isActive == false`
- `isAvailable == false`

## 4. branches

```js
{
  id: string,

  nameAr: string,
  nameEn: string,

  phoneNumbers: string[],

  locationUrl: string,
  locationText: string,

  sortOrder: number,
  isActive: boolean,

  createdAt: timestamp,
  updatedAt: timestamp
}
```

Customers see active branches only.

## 5. orders

The current application flow does **not** persist invoices/orders in Firestore.

Orders are assembled in memory and sent through WhatsApp only.
Customer GPS location is also used only inside the WhatsApp message and must not be stored.

## 6. users

If authentication is enabled:

```js
{
  uid: string,
  name: string,
  email: string,
  phone: string,

  role: "customer" | "admin",

  isActive: boolean,

  createdAt: timestamp,
  updatedAt: timestamp
}
```

Guest checkout can be supported if the project chooses not to require customer accounts.

## 7. Admin Permissions

Admin can manage:
- categories
- menu_items
- branches
- app_config/main

Admin can delete a category only when no menu item references its `categoryId`.

Customers can:
- read active menu data
- send their order through WhatsApp without storing an order document

## 8. Restaurant Configuration Usage

`app_config/main` supplies:
- Restaurant name
- Logo
- Description
- WhatsApp number
- Support phone
- Email
- Social links
- Default delivery price
- Saved delivery location
- Currency

## 9. Order Message Data

The WhatsApp order message is generated from the in-memory checkout snapshot.

Message includes:
- Restaurant name
- Temporary order reference
- Customer name
- Phone
- Address
- Latitude/longitude or map link
- Items
- Quantities
- Prices
- Subtotal
- Delivery
- Total


## Image Storage Architecture

All image files are stored in Supabase Storage.

Recommended buckets/folders:

```text
restaurant-images/
├── products/
├── categories/
├── branches/
├── banners/
└── restaurant/
```

Firestore stores only the resulting Supabase public/signed URL or storage path.

Example:

```js
{
  imageUrl: "https://<supabase-project>/storage/v1/object/public/restaurant-images/products/burger.webp"
}
```

### Image Size Requirement

Before uploading:
- Compress/resize the image.
- Final file size must be **<= 500 KB**.
- Prefer WebP when supported by the project.
- Preserve acceptable visual quality while enforcing the hard size limit.
- When an admin replaces/removes a Supabase image, delete the old Supabase object after Firestore is updated.
