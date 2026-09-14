# Restaurant Menu — API / Service Specification

## 1. Architecture

The project does not require a custom Node.js/Express API.

Flutter communicates directly with:

```text
Flutter
  │
  ├── Firebase Firestore
  ├── Firebase Authentication (optional/when enabled)
  ├── Supabase Storage
  ├── Geolocation Services
  └── External URL Services
       ├── WhatsApp
       ├── Maps
       ├── Phone
       ├── Email
       └── Social Media
```

## 2. Firestore

Firestore is used for:
- Restaurant configuration
- Categories
- Menu items
- Branches

Firestore is not used to store customer invoices/orders in the current customer flow.

No local `SeedData` seeding or local fallback restaurant/menu content is used. Customer-facing
configuration, categories, menu items, and branches must come from Firestore. Images are stored in
Supabase Storage, while Firestore stores only their URL/path.

## 2.1 Supabase

Supabase is used only for application image storage.

Project configuration:

```text
Project URL: https://fnzwtsizrtekpztwyzpn.supabase.co
Publishable key: sb_publishable_6GsBIqEpkCnfuCe6qn_36w_wci4Pc75
Storage bucket: restaurant-images
```

Firestore must store only the resulting Supabase image URL/path.

## 3. Customer Location Service

Expected service interface:

```dart
abstract class LocationService {
  Future<LocationResult> getCurrentLocation();
}
```

`LocationResult` should contain:

```dart
class LocationResult {
  final double latitude;
  final double longitude;
  final String formattedAddress;
}
```

Flow:

```text
Tap "Use My Location"
        ↓
Check permission
        ↓
Request permission if required
        ↓
Read GPS coordinates
        ↓
Reverse geocode
        ↓
Return LocationResult
        ↓
Show location to customer
```

## 4. WhatsApp Service

Expected service:

```dart
abstract class WhatsAppService {
  Future<bool> sendOrder({
    required String phoneNumber,
    required String message,
  });
}
```

URL format:

```text
https://wa.me/{whatsappNumber}?text={encodedMessage}
```

The phone number must be normalized before building the URL.

## 5. Maps Service

Expected behavior:

```dart
Future<bool> openMap({
  required double latitude,
  required double longitude,
});
```

For a branch with an admin-provided URL:

```dart
Future<bool> openMapUrl(String url);
```

## 6. Contact Services

Use `url_launcher` for:

```text
tel:{phone}
mailto:{email}
https://wa.me/{number}
https://www.facebook.com/...
https://www.instagram.com/...
https://www.tiktok.com/...
```

## 7. Order Creation

Order creation flow:

```text
Cart
 ↓
Checkout validation
 ↓
Customer data validation
 ↓
Location validation
 ↓
Calculate subtotal
 ↓
Apply default delivery price
 ↓
Generate WhatsApp message
 ↓
Open WhatsApp
```

The order/invoice is sent through WhatsApp only. It must not be persisted in Firestore.
The customer's current GPS location is used only in the WhatsApp message and must not be stored.

## 8. Validation

### Name
- Required
- Trim whitespace
- Minimum reasonable length

### Phone
- Required
- Validate basic phone structure
- Normalize if necessary

### Location
- Required
- Latitude and longitude must be valid numbers
- Formatted address should be shown when available
- Current device location is required for checkout.
- Do not persist customer location data.

### Cart
- Must not be empty
- Quantities must be positive
- Weight item quantities are entered in kilograms and may be decimal values such as `1.25` or `0.100`.
- Only available menu items can be ordered

## 9. Error Messages

Examples:

```text
تعذر الحصول على موقعك الحالي.
يرجى تفعيل صلاحية الموقع أو اختيار الموقع المحفوظ.

يرجى إدخال الاسم.

يرجى إدخال رقم هاتف صحيح.

السلة فارغة.

تعذر إنشاء الطلب. حاول مرة أخرى.

تعذر فتح واتساب على هذا الجهاز.
```

## 10. No Custom Backend

Do not introduce:
- Express.js
- Node.js API
- Cloudflare R2
- Custom image API
- Firebase Admin SDK credentials in Flutter

Unless a future task explicitly changes the architecture.


## Supabase Storage Image Service

Expected service:

```dart
abstract class ImageStorageService {
  Future<String> uploadImage({
    required String filePath,
    required String folder,
  });
}
```

Upload flow:

```text
Select image
   ↓
Resize/compress
   ↓
Ensure final size <= 500 KB
   ↓
Upload to Supabase Storage
   ↓
Get public/signed URL
   ↓
Save URL/path in Firebase Firestore
```

Firebase Storage must not be used for application images in this architecture.

When an admin replaces or removes an image:
- Upload the new compressed image to Supabase Storage.
- Update Firestore with the new URL/path.
- Delete the old Supabase image when the old URL belongs to the configured Supabase bucket.

## Admin Authentication

Admin access is available from the Settings destination.

Rules:
- Login only with an existing Firebase Auth user.
- Do not expose sign-up/create-account UI.
- Do not expose forgot-password UI.
- After successful login, show the admin dashboard.

The dashboard manages:
- Restaurant settings and logo.
- WhatsApp/phone/email/social links.
- Categories.
- Menu items.
- Branches.
- Menu item unit type: piece or weight.
- Menu item manual sizes list with a required price for each size.
- Empty categories can be deleted. Categories with linked menu items cannot be deleted.
