enum AppErrorKey {
  server,
  location,
  whatsappOpen,
  whatsappSend,
  storageUpload,
  storage,
  loadLocalStorage,
  saveLocalStorage,
  clearLocalStorage,
  loadCartFromLocalStorage,
  saveCartToLocalStorage,
  loadCustomerInfoFromLocalStorage,
  saveCustomerInfoToLocalStorage,
  loadUserPreferencesFromLocalStorage,
  saveUserPreferencesToLocalStorage,
  firebaseInitNotice,
  supabaseInitNotice,
  restaurantConfigMissing,
  loadRestaurantInfo,
  loadRestaurantFromFirestore,
  loadBranchesFromFirestore,
  loadMenu,
  loadCategoriesFromFirestore,
  loadMenuItemsFromFirestore,
  loadDashboard,
  saveRestaurantConfig,
  saveCategory,
  deleteCategory,
  cannotDeleteCategoryWithItems,
  saveMenuItem,
  deleteMenuItem,
  saveBranch,
  deleteBranch,
  authUserMissingAfterSignIn,
  adminAccountInactive,
  verifyAdminAccess,
  signIn,
  signOut,
  createAdminAccount,
  createAdmin,
  saveAdmin,
  deleteAdmin,
  cannotDisableCurrentAdmin,
  cannotDeleteCurrentAdmin,
  keepOneActiveAdmin,
  invalidEmail,
  userDisabled,
  invalidCredentials,
  tooManyRequests,
  firebaseLogin,
  firebaseAppNotAuthorized,
  firebaseNetwork,
  platformLogin,
  emailPasswordRequired,
  dashboardLoadFailed,
  validCustomerNameRequired,
  validPhoneRequired,
  selectBranch,
  branchOrdersWhatsappMissing,
  branchOrdersWhatsappInvalid,
  validLocationLinkRequired,
  deliveryLocationRequired,
  cartEmpty,
  cartContainsInvalidItem,
  whatsappOpenOnDeviceFailed,
  submitOrder,
  locationServiceDisabled,
  locationPermissionDenied,
  locationPermissionDeniedForever,
  getCurrentLocation,
  imageReadUnsupported,
  imageCompressChooseSmaller,
  imageCompressBelowLimitFailed,
  uploadImageToSupabase,
  deleteImageFromSupabase,
  validWeightRequired,
  sizeNameAndPriceRequired,
  duplicateSizeName,
  validSizePriceRequired,
  branchOrdersWhatsappRequired,
  branchOrdersWhatsappInvalidInput,
  confirmDeleteIrreversible,
  validAdminEmailRequired,
  adminPasswordMinLength,
  adminNameRequired,
}

class ErrorMessages {
  ErrorMessages._();

  static const _ar = <AppErrorKey, String>{
    AppErrorKey.server: 'حدث خطأ في الخادم',
    AppErrorKey.location: 'تعذر تحديد الموقع الحالي',
    AppErrorKey.whatsappOpen: 'تعذر فتح تطبيق واتساب',
    AppErrorKey.whatsappSend: 'تعذر إرسال الطلب عبر واتساب',
    AppErrorKey.storageUpload: 'تعذر رفع الصورة',
    AppErrorKey.storage: 'حدث خطأ أثناء رفع الصورة',
    AppErrorKey.loadLocalStorage: 'تعذر قراءة البيانات المحلية',
    AppErrorKey.saveLocalStorage: 'تعذر حفظ البيانات المحلية',
    AppErrorKey.clearLocalStorage: 'تعذر مسح البيانات المحلية',
    AppErrorKey.loadCartFromLocalStorage: 'تعذر تحميل السلة المحفوظة محلياً',
    AppErrorKey.saveCartToLocalStorage: 'تعذر حفظ السلة محلياً',
    AppErrorKey.loadCustomerInfoFromLocalStorage:
        'تعذر تحميل بيانات العميل المحفوظة محلياً',
    AppErrorKey.saveCustomerInfoToLocalStorage: 'تعذر حفظ بيانات العميل محلياً',
    AppErrorKey.loadUserPreferencesFromLocalStorage:
        'تعذر تحميل إعدادات المستخدم المحلية',
    AppErrorKey.saveUserPreferencesToLocalStorage:
        'تعذر حفظ إعدادات المستخدم محلياً',
    AppErrorKey.firebaseInitNotice: 'تنبيه تهيئة Firebase',
    AppErrorKey.supabaseInitNotice: 'تنبيه تهيئة Supabase',
    AppErrorKey.restaurantConfigMissing:
        'لم يتم إعداد بيانات المطعم في Firestore بعد',
    AppErrorKey.loadRestaurantInfo: 'تعذر تحميل بيانات المطعم',
    AppErrorKey.loadRestaurantFromFirestore:
        'تعذر تحميل بيانات المطعم من Firestore',
    AppErrorKey.loadBranchesFromFirestore: 'تعذر تحميل الفروع من Firestore',
    AppErrorKey.loadMenu: 'تعذر تحميل قائمة الطعام',
    AppErrorKey.loadCategoriesFromFirestore: 'تعذر تحميل الفئات من Firestore',
    AppErrorKey.loadMenuItemsFromFirestore: 'تعذر تحميل الأصناف من Firestore',
    AppErrorKey.loadDashboard: 'تعذر تحميل بيانات لوحة التحكم',
    AppErrorKey.saveRestaurantConfig: 'تعذر حفظ بيانات المطعم',
    AppErrorKey.saveCategory: 'تعذر حفظ الفئة',
    AppErrorKey.deleteCategory: 'تعذر حذف الفئة',
    AppErrorKey.cannotDeleteCategoryWithItems:
        'لا يمكن حذف فئة داخلها أصناف. احذف الأصناف أو انقلها أولاً',
    AppErrorKey.saveMenuItem: 'تعذر حفظ الصنف',
    AppErrorKey.deleteMenuItem: 'تعذر حذف الصنف',
    AppErrorKey.saveBranch: 'تعذر حفظ الفرع',
    AppErrorKey.deleteBranch: 'تعذر حذف الفرع',
    AppErrorKey.authUserMissingAfterSignIn:
        'تعذر قراءة بيانات المستخدم بعد الدخول',
    AppErrorKey.adminAccountInactive:
        'هذا الحساب غير مفعل كأدمن. تواصل مع مدير النظام',
    AppErrorKey.verifyAdminAccess: 'تعذر التحقق من صلاحيات الأدمن',
    AppErrorKey.signIn: 'تعذر تسجيل الدخول',
    AppErrorKey.signOut: 'تعذر تسجيل الخروج',
    AppErrorKey.createAdminAccount: 'تعذر إنشاء حساب الأدمن',
    AppErrorKey.createAdmin: 'تعذر إنشاء الأدمن',
    AppErrorKey.saveAdmin: 'تعذر حفظ بيانات الأدمن',
    AppErrorKey.deleteAdmin: 'تعذر حذف الأدمن',
    AppErrorKey.cannotDisableCurrentAdmin: 'لا يمكنك تعطيل حسابك الحالي',
    AppErrorKey.cannotDeleteCurrentAdmin: 'لا يمكنك حذف حسابك الحالي',
    AppErrorKey.keepOneActiveAdmin: 'يجب إبقاء أدمن نشط واحد على الأقل',
    AppErrorKey.invalidEmail: 'البريد الإلكتروني غير صحيح',
    AppErrorKey.userDisabled: 'هذا الحساب معطل',
    AppErrorKey.invalidCredentials: 'بيانات الدخول غير صحيحة',
    AppErrorKey.tooManyRequests: 'محاولات كثيرة. حاول لاحقاً',
    AppErrorKey.firebaseLogin: 'تعذر تسجيل الدخول في Firebase',
    AppErrorKey.firebaseAppNotAuthorized:
        'تطبيق Firebase غير مصرح له. تأكد من إعدادات Firebase للمشروع bakroon-oday',
    AppErrorKey.firebaseNetwork:
        'تعذر الاتصال بـ Firebase. تحقق من الإنترنت أو إعدادات المتصفح',
    AppErrorKey.platformLogin:
        'تعذر تسجيل الدخول. تحقق من تفعيل Email/Password في Firebase Authentication',
    AppErrorKey.emailPasswordRequired:
        'يرجى إدخال البريد الإلكتروني وكلمة المرور',
    AppErrorKey.dashboardLoadFailed: 'تعذر تحميل لوحة التحكم',
    AppErrorKey.validCustomerNameRequired: 'يرجى إدخال اسم العميل بشكل صحيح',
    AppErrorKey.validPhoneRequired: 'يرجى إدخال رقم هاتف صحيح',
    AppErrorKey.selectBranch: 'اختر الفرع المناسب',
    AppErrorKey.branchOrdersWhatsappMissing:
        'لم يتم إعداد رقم واتساب الطلبات للفرع المختار',
    AppErrorKey.branchOrdersWhatsappInvalid:
        'رقم واتساب الطلبات للفرع المختار غير صحيح',
    AppErrorKey.validLocationLinkRequired:
        'يرجى إدخال رابط موقع صحيح أو استخدام موقعك الحالي',
    AppErrorKey.deliveryLocationRequired:
        'يرجى تحديد موقع التوصيل أو إدخال رابط الموقع',
    AppErrorKey.cartEmpty: 'السلة فارغة. يرجى إضافة وجبات أولاً',
    AppErrorKey.cartContainsInvalidItem:
        'تحتوي السلة على صنف غير متاح أو كمية غير صحيحة',
    AppErrorKey.whatsappOpenOnDeviceFailed: 'تعذر فتح واتساب على هذا الجهاز',
    AppErrorKey.submitOrder: 'تعذر إتمام الطلب',
    AppErrorKey.locationServiceDisabled:
        'خدمة تحديد الموقع (GPS) غير مفعلة على جهازك',
    AppErrorKey.locationPermissionDenied: 'تم رفض إذن الوصول إلى الموقع',
    AppErrorKey.locationPermissionDeniedForever:
        'تم رفض إذن الموقع نهائياً. يرجى تفعيله من إعدادات الجهاز',
    AppErrorKey.getCurrentLocation: 'تعذر الحصول على موقعك الحالي',
    AppErrorKey.imageReadUnsupported: 'نوع ملف الصورة غير مدعوم',
    AppErrorKey.imageCompressChooseSmaller:
        'تعذر ضغط الصورة. يرجى اختيار صورة أصغر من 500 KB',
    AppErrorKey.imageCompressBelowLimitFailed:
        'تعذر ضغط الصورة إلى أقل من 500 KB',
    AppErrorKey.uploadImageToSupabase: 'تعذر رفع الصورة إلى Supabase',
    AppErrorKey.deleteImageFromSupabase: 'تعذر حذف الصورة القديمة من Supabase',
    AppErrorKey.validWeightRequired: 'يرجى إدخال وزن صحيح بالكيلو',
    AppErrorKey.sizeNameAndPriceRequired: 'يرجى إدخال اسم الحجم وسعره لكل حجم',
    AppErrorKey.duplicateSizeName: 'لا يمكن تكرار نفس الحجم أكثر من مرة',
    AppErrorKey.validSizePriceRequired: 'يرجى إدخال سعر صحيح لكل حجم',
    AppErrorKey.branchOrdersWhatsappRequired:
        'يرجى إدخال رقم واتساب طلبات الفرع',
    AppErrorKey.branchOrdersWhatsappInvalidInput:
        'يرجى إدخال رقم واتساب طلبات الفرع بشكل صحيح',
    AppErrorKey.confirmDeleteIrreversible: 'لا يمكن التراجع عن هذا الإجراء.',
    AppErrorKey.validAdminEmailRequired: 'يرجى إدخال بريد إلكتروني صحيح',
    AppErrorKey.adminPasswordMinLength:
        'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
    AppErrorKey.adminNameRequired: 'يرجى إدخال اسم الأدمن',
  };

  static const _en = <AppErrorKey, String>{
    AppErrorKey.server: 'Server error',
    AppErrorKey.location: 'Could not determine current location',
    AppErrorKey.whatsappOpen: 'Could not open WhatsApp',
    AppErrorKey.whatsappSend: 'Could not send the order via WhatsApp',
    AppErrorKey.storageUpload: 'Could not upload image',
    AppErrorKey.storage: 'Image upload failed',
    AppErrorKey.loadLocalStorage: 'Could not read local data',
    AppErrorKey.saveLocalStorage: 'Could not save local data',
    AppErrorKey.clearLocalStorage: 'Could not clear local data',
    AppErrorKey.loadCartFromLocalStorage: 'Could not load the saved cart',
    AppErrorKey.saveCartToLocalStorage: 'Could not save the cart locally',
    AppErrorKey.loadCustomerInfoFromLocalStorage:
        'Could not load saved customer info',
    AppErrorKey.saveCustomerInfoToLocalStorage:
        'Could not save customer info locally',
    AppErrorKey.loadUserPreferencesFromLocalStorage:
        'Could not load local user preferences',
    AppErrorKey.saveUserPreferencesToLocalStorage:
        'Could not save local user preferences',
    AppErrorKey.emailPasswordRequired: 'Please enter email and password',
    AppErrorKey.validAdminEmailRequired: 'Please enter a valid email address',
    AppErrorKey.adminPasswordMinLength:
        'Password must be at least 6 characters',
    AppErrorKey.adminNameRequired: 'Please enter the admin name',
  };

  static String message(AppErrorKey key, {String localeCode = 'ar'}) {
    final source = localeCode == 'en' ? _en : _ar;
    return source[key] ?? _ar[key] ?? key.name;
  }

  static String withDetails(
    AppErrorKey key,
    Object? details, {
    String localeCode = 'ar',
  }) {
    final base = message(key, localeCode: localeCode);
    final text = details?.toString().trim() ?? '';
    return text.isEmpty ? base : '$base: $text';
  }

  static String withCode(
    AppErrorKey key,
    String code, {
    String? details,
    String localeCode = 'ar',
  }) {
    final base = message(key, localeCode: localeCode);
    final cleanDetails = details?.trim();
    if (cleanDetails == null || cleanDetails.isEmpty) {
      return '$base: $code';
    }
    return '$base: $code - $cleanDetails';
  }
}
