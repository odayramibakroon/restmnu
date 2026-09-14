class AppConstants {
  AppConstants._();

  // Firestore Collections
  static const String collectionAppConfig = 'app_config';
  static const String documentMainConfig = 'main';
  static const String collectionCategories = 'categories';
  static const String collectionMenuItems = 'menu_items';
  static const String collectionBranches = 'branches';
  static const String collectionAdminUsers = 'admin_users';

  // UI-only filters
  static const String menuAllCategoryId = 'cat_all';

  // Storage
  static const int maxImageSizeBytes =
      500 * 1024; // 500 KB limit as required in docs

  // Supabase Bucket
  static const String supabaseBucketRestaurantImages = 'restaurant-images';
}
