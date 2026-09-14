import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'قائمة المطعم'**
  String get appTitle;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @choose.
  ///
  /// In ar, this message translates to:
  /// **'اختيار'**
  String get choose;

  /// No description provided for @active.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In ar, this message translates to:
  /// **'مخفي'**
  String get inactive;

  /// No description provided for @disabled.
  ///
  /// In ar, this message translates to:
  /// **'معطل'**
  String get disabled;

  /// No description provided for @notSet.
  ///
  /// In ar, this message translates to:
  /// **'غير محدد'**
  String get notSet;

  /// No description provided for @phoneLabel.
  ///
  /// In ar, this message translates to:
  /// **'الهاتف'**
  String get phoneLabel;

  /// No description provided for @emailLabel.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get emailLabel;

  /// No description provided for @nameLabel.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get nameLabel;

  /// No description provided for @addressLabel.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get addressLabel;

  /// No description provided for @sizeLabel.
  ///
  /// In ar, this message translates to:
  /// **'الحجم'**
  String get sizeLabel;

  /// No description provided for @kiloShort.
  ///
  /// In ar, this message translates to:
  /// **'كجم'**
  String get kiloShort;

  /// No description provided for @perKilo.
  ///
  /// In ar, this message translates to:
  /// **'للكيلو'**
  String get perKilo;

  /// No description provided for @pieceUnit.
  ///
  /// In ar, this message translates to:
  /// **'بالقطعة'**
  String get pieceUnit;

  /// No description provided for @kiloUnit.
  ///
  /// In ar, this message translates to:
  /// **'بالكيلو'**
  String get kiloUnit;

  /// No description provided for @navMenu.
  ///
  /// In ar, this message translates to:
  /// **'القائمة'**
  String get navMenu;

  /// No description provided for @navCart.
  ///
  /// In ar, this message translates to:
  /// **'السلة'**
  String get navCart;

  /// No description provided for @navRestaurant.
  ///
  /// In ar, this message translates to:
  /// **'عن المطعم'**
  String get navRestaurant;

  /// No description provided for @navSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات'**
  String get navSettings;

  /// No description provided for @navMainMenu.
  ///
  /// In ar, this message translates to:
  /// **'القائمة الرئيسية'**
  String get navMainMenu;

  /// No description provided for @navShoppingCart.
  ///
  /// In ar, this message translates to:
  /// **'سلة المشتريات'**
  String get navShoppingCart;

  /// No description provided for @navRestaurantInfo.
  ///
  /// In ar, this message translates to:
  /// **'معلومات وفروع المطعم'**
  String get navRestaurantInfo;

  /// No description provided for @navAdminSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الإدارة'**
  String get navAdminSettings;

  /// No description provided for @cartTitle.
  ///
  /// In ar, this message translates to:
  /// **'سلة المشتريات'**
  String get cartTitle;

  /// No description provided for @clearCart.
  ///
  /// In ar, this message translates to:
  /// **'تفريغ السلة'**
  String get clearCart;

  /// No description provided for @clearCartQuestion.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من رغبتك في حذف جميع الأصناف من السلة؟'**
  String get clearCartQuestion;

  /// No description provided for @clear.
  ///
  /// In ar, this message translates to:
  /// **'تفريغ'**
  String get clear;

  /// No description provided for @emptyCartTitle.
  ///
  /// In ar, this message translates to:
  /// **'سلة المشتريات فارغة'**
  String get emptyCartTitle;

  /// No description provided for @emptyCartDescription.
  ///
  /// In ar, this message translates to:
  /// **'لم تقم بإضافة أي وجبة إلى السلة بعد. تصفح قائمتنا اللذيذة واختر ما يعجبك!'**
  String get emptyCartDescription;

  /// No description provided for @browseMenuNow.
  ///
  /// In ar, this message translates to:
  /// **'تصفح قائمة الطعام الآن'**
  String get browseMenuNow;

  /// No description provided for @orderSummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص الطلب'**
  String get orderSummary;

  /// No description provided for @subtotal.
  ///
  /// In ar, this message translates to:
  /// **'المجموع الفرعي'**
  String get subtotal;

  /// No description provided for @deliveryFees.
  ///
  /// In ar, this message translates to:
  /// **'رسوم التوصيل'**
  String get deliveryFees;

  /// No description provided for @grandTotal.
  ///
  /// In ar, this message translates to:
  /// **'المجموع الكلي'**
  String get grandTotal;

  /// No description provided for @continueToCheckout.
  ///
  /// In ar, this message translates to:
  /// **'متابعة لإتمام الطلب'**
  String get continueToCheckout;

  /// No description provided for @foodMenu.
  ///
  /// In ar, this message translates to:
  /// **'قائمة الطعام'**
  String get foodMenu;

  /// No description provided for @availableMeals.
  ///
  /// In ar, this message translates to:
  /// **'الوجبات المتاحة'**
  String get availableMeals;

  /// No description provided for @searchResultsFor.
  ///
  /// In ar, this message translates to:
  /// **'نتائج البحث عن'**
  String get searchResultsFor;

  /// No description provided for @noMealsMatchSearch.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد وجبات تطابق بحثك'**
  String get noMealsMatchSearch;

  /// No description provided for @tryOtherSearch.
  ///
  /// In ar, this message translates to:
  /// **'جرب البحث باسم صنف آخر أو اختر تصنيفاً مختلفاً'**
  String get tryOtherSearch;

  /// No description provided for @viewCart.
  ///
  /// In ar, this message translates to:
  /// **'عرض السلة'**
  String get viewCart;

  /// No description provided for @addedToCartSuffix.
  ///
  /// In ar, this message translates to:
  /// **'تمت الإضافة إلى السلة'**
  String get addedToCartSuffix;

  /// No description provided for @accordingToSize.
  ///
  /// In ar, this message translates to:
  /// **'حسب الحجم'**
  String get accordingToSize;

  /// No description provided for @popularBadge.
  ///
  /// In ar, this message translates to:
  /// **'شائع 🔥'**
  String get popularBadge;

  /// No description provided for @newBadge.
  ///
  /// In ar, this message translates to:
  /// **'جديد ✨'**
  String get newBadge;

  /// No description provided for @discountBadge.
  ///
  /// In ar, this message translates to:
  /// **'خصم 🏷️'**
  String get discountBadge;

  /// No description provided for @insteadOf.
  ///
  /// In ar, this message translates to:
  /// **'بدل'**
  String get insteadOf;

  /// No description provided for @description.
  ///
  /// In ar, this message translates to:
  /// **'الوصف'**
  String get description;

  /// No description provided for @weightInKilo.
  ///
  /// In ar, this message translates to:
  /// **'الوزن بالكيلو'**
  String get weightInKilo;

  /// No description provided for @quantity.
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get quantity;

  /// No description provided for @addToCart.
  ///
  /// In ar, this message translates to:
  /// **'إضافة إلى السلة'**
  String get addToCart;

  /// No description provided for @searchMealHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن وجبتك المفضلة (برجر، بيتزا، مشاوي...)...'**
  String get searchMealHint;

  /// No description provided for @all.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get all;

  /// No description provided for @checkoutTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الطلب والتوصيل'**
  String get checkoutTitle;

  /// No description provided for @customerInfo.
  ///
  /// In ar, this message translates to:
  /// **'بيانات العميل'**
  String get customerInfo;

  /// No description provided for @fullNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل *'**
  String get fullNameRequired;

  /// No description provided for @fullNameHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسمك الكريم (مثال: محمد السليمان)'**
  String get fullNameHint;

  /// No description provided for @phoneRequired.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف (للتواصل والواتساب) *'**
  String get phoneRequired;

  /// No description provided for @phoneHint.
  ///
  /// In ar, this message translates to:
  /// **'05xxxxxxxx أو +9665xxxxxxxx'**
  String get phoneHint;

  /// No description provided for @deliveryLocation.
  ///
  /// In ar, this message translates to:
  /// **'موقع التوصيل'**
  String get deliveryLocation;

  /// No description provided for @locatingAccurately.
  ///
  /// In ar, this message translates to:
  /// **'جاري تحديد موقعك بدقة...'**
  String get locatingAccurately;

  /// No description provided for @useCurrentLocation.
  ///
  /// In ar, this message translates to:
  /// **'استخدام موقعي الحالي (GPS)'**
  String get useCurrentLocation;

  /// No description provided for @mapLinkOption.
  ///
  /// In ar, this message translates to:
  /// **'أو ضع رابط الخريطة'**
  String get mapLinkOption;

  /// No description provided for @selectedLocation.
  ///
  /// In ar, this message translates to:
  /// **'الموقع المختار:'**
  String get selectedLocation;

  /// No description provided for @coordinates.
  ///
  /// In ar, this message translates to:
  /// **'الإحداثيات'**
  String get coordinates;

  /// No description provided for @locationPrivacyNotice.
  ///
  /// In ar, this message translates to:
  /// **'لن يتم تخزين موقعك. سيتم استخدامه فقط داخل رسالة واتساب.'**
  String get locationPrivacyNotice;

  /// No description provided for @branch.
  ///
  /// In ar, this message translates to:
  /// **'الفرع'**
  String get branch;

  /// No description provided for @chooseBranch.
  ///
  /// In ar, this message translates to:
  /// **'اختار الفرع'**
  String get chooseBranch;

  /// No description provided for @reviewOrder.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة الطلب'**
  String get reviewOrder;

  /// No description provided for @finalTotal.
  ///
  /// In ar, this message translates to:
  /// **'المجموع النهائي'**
  String get finalTotal;

  /// No description provided for @preparingOrderWhatsapp.
  ///
  /// In ar, this message translates to:
  /// **'جاري تجهيز الطلب وفتح واتساب...'**
  String get preparingOrderWhatsapp;

  /// No description provided for @sendOrderWhatsapp.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الطلب عبر واتساب'**
  String get sendOrderWhatsapp;

  /// No description provided for @orderReceived.
  ///
  /// In ar, this message translates to:
  /// **'تم استلام الطلب'**
  String get orderReceived;

  /// No description provided for @orderReadyThanks.
  ///
  /// In ar, this message translates to:
  /// **'شكراً لك! تم تجهيز طلبك بنجاح'**
  String get orderReadyThanks;

  /// No description provided for @orderSentToBranchInfo.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال تفاصيل الطلب وموقع التوصيل عبر واتساب إلى الفرع المختار بدون حفظ الفاتورة داخل Firestore.'**
  String get orderSentToBranchInfo;

  /// No description provided for @referenceNumber.
  ///
  /// In ar, this message translates to:
  /// **'الرقم المرجعي:'**
  String get referenceNumber;

  /// No description provided for @orderedItems.
  ///
  /// In ar, this message translates to:
  /// **'الأصناف المطلوبة:'**
  String get orderedItems;

  /// No description provided for @mapLinkLabel.
  ///
  /// In ar, this message translates to:
  /// **'رابط الموقع:'**
  String get mapLinkLabel;

  /// No description provided for @reopenWhatsapp.
  ///
  /// In ar, this message translates to:
  /// **'إعادة فتح محادثة الواتساب'**
  String get reopenWhatsapp;

  /// No description provided for @backToMainMenu.
  ///
  /// In ar, this message translates to:
  /// **'العودة إلى القائمة الرئيسية'**
  String get backToMainMenu;

  /// No description provided for @contactUs.
  ///
  /// In ar, this message translates to:
  /// **'تواصل معنا'**
  String get contactUs;

  /// No description provided for @followUs.
  ///
  /// In ar, this message translates to:
  /// **'تابعنا على منصات التواصل'**
  String get followUs;

  /// No description provided for @branches.
  ///
  /// In ar, this message translates to:
  /// **'فروعنا'**
  String get branches;

  /// No description provided for @whatsapp.
  ///
  /// In ar, this message translates to:
  /// **'واتساب'**
  String get whatsapp;

  /// No description provided for @directCall.
  ///
  /// In ar, this message translates to:
  /// **'اتصال مباشر'**
  String get directCall;

  /// No description provided for @openGoogleMaps.
  ///
  /// In ar, this message translates to:
  /// **'فتح الموقع في خرائط Google'**
  String get openGoogleMaps;

  /// No description provided for @darkAppearance.
  ///
  /// In ar, this message translates to:
  /// **'المظهر الداكن (Dark Mode)'**
  String get darkAppearance;

  /// No description provided for @adminSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الإدارة'**
  String get adminSettings;

  /// No description provided for @adminLogin.
  ///
  /// In ar, this message translates to:
  /// **'دخول الأدمن'**
  String get adminLogin;

  /// No description provided for @adminDashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get adminDashboard;

  /// No description provided for @login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// No description provided for @loggingIn.
  ///
  /// In ar, this message translates to:
  /// **'جاري تسجيل الدخول...'**
  String get loggingIn;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @restaurantTab.
  ///
  /// In ar, this message translates to:
  /// **'المطعم'**
  String get restaurantTab;

  /// No description provided for @categoriesTab.
  ///
  /// In ar, this message translates to:
  /// **'الفئات'**
  String get categoriesTab;

  /// No description provided for @itemsTab.
  ///
  /// In ar, this message translates to:
  /// **'الأصناف'**
  String get itemsTab;

  /// No description provided for @branchesTab.
  ///
  /// In ar, this message translates to:
  /// **'الفروع'**
  String get branchesTab;

  /// No description provided for @usersManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المستخدمين'**
  String get usersManagement;

  /// No description provided for @restaurantData.
  ///
  /// In ar, this message translates to:
  /// **'بيانات المطعم'**
  String get restaurantData;

  /// No description provided for @storeNameArabic.
  ///
  /// In ar, this message translates to:
  /// **'اسم المطعم بالعربي'**
  String get storeNameArabic;

  /// No description provided for @storeNameEnglish.
  ///
  /// In ar, this message translates to:
  /// **'اسم المطعم بالإنجليزي'**
  String get storeNameEnglish;

  /// No description provided for @storeDescriptionArabic.
  ///
  /// In ar, this message translates to:
  /// **'وصف المطعم بالعربي'**
  String get storeDescriptionArabic;

  /// No description provided for @storeDescriptionEnglish.
  ///
  /// In ar, this message translates to:
  /// **'وصف المطعم بالإنجليزي'**
  String get storeDescriptionEnglish;

  /// No description provided for @restaurantImage.
  ///
  /// In ar, this message translates to:
  /// **'صورة المطعم'**
  String get restaurantImage;

  /// No description provided for @contactSocial.
  ///
  /// In ar, this message translates to:
  /// **'التواصل والسوشيال ميديا'**
  String get contactSocial;

  /// No description provided for @supportWhatsapp.
  ///
  /// In ar, this message translates to:
  /// **'رقم واتساب التواصل والدعم'**
  String get supportWhatsapp;

  /// No description provided for @phoneNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phoneNumber;

  /// No description provided for @facebookUrl.
  ///
  /// In ar, this message translates to:
  /// **'رابط Facebook'**
  String get facebookUrl;

  /// No description provided for @instagramUrl.
  ///
  /// In ar, this message translates to:
  /// **'رابط Instagram'**
  String get instagramUrl;

  /// No description provided for @tiktokUrl.
  ///
  /// In ar, this message translates to:
  /// **'رابط TikTok'**
  String get tiktokUrl;

  /// No description provided for @deliverySettings.
  ///
  /// In ar, this message translates to:
  /// **'التوصيل والإعدادات'**
  String get deliverySettings;

  /// No description provided for @defaultDeliveryPrice.
  ///
  /// In ar, this message translates to:
  /// **'سعر التوصيل الافتراضي'**
  String get defaultDeliveryPrice;

  /// No description provided for @currency.
  ///
  /// In ar, this message translates to:
  /// **'العملة'**
  String get currency;

  /// No description provided for @savedRestaurantLatitude.
  ///
  /// In ar, this message translates to:
  /// **'خط عرض موقع المطعم المحفوظ'**
  String get savedRestaurantLatitude;

  /// No description provided for @savedRestaurantLongitude.
  ///
  /// In ar, this message translates to:
  /// **'خط طول موقع المطعم المحفوظ'**
  String get savedRestaurantLongitude;

  /// No description provided for @savedRestaurantAddress.
  ///
  /// In ar, this message translates to:
  /// **'عنوان موقع المطعم المحفوظ'**
  String get savedRestaurantAddress;

  /// No description provided for @enableDarkMode.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الوضع الداكن'**
  String get enableDarkMode;

  /// No description provided for @saveRestaurantData.
  ///
  /// In ar, this message translates to:
  /// **'حفظ بيانات المطعم'**
  String get saveRestaurantData;

  /// No description provided for @categories.
  ///
  /// In ar, this message translates to:
  /// **'الفئات'**
  String get categories;

  /// No description provided for @addCategory.
  ///
  /// In ar, this message translates to:
  /// **'إضافة فئة'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In ar, this message translates to:
  /// **'تعديل فئة'**
  String get editCategory;

  /// No description provided for @categoryNameArabic.
  ///
  /// In ar, this message translates to:
  /// **'اسم الفئة بالعربي'**
  String get categoryNameArabic;

  /// No description provided for @categoryNameEnglish.
  ///
  /// In ar, this message translates to:
  /// **'اسم الفئة بالإنجليزي'**
  String get categoryNameEnglish;

  /// No description provided for @categoryImage.
  ///
  /// In ar, this message translates to:
  /// **'صورة الفئة'**
  String get categoryImage;

  /// No description provided for @categoryActive.
  ///
  /// In ar, this message translates to:
  /// **'الفئة نشطة'**
  String get categoryActive;

  /// No description provided for @searchCategories.
  ///
  /// In ar, this message translates to:
  /// **'بحث في الفئات'**
  String get searchCategories;

  /// No description provided for @searchCategoriesHint.
  ///
  /// In ar, this message translates to:
  /// **'اسم الفئة أو حالة العرض'**
  String get searchCategoriesHint;

  /// No description provided for @noCategoriesYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فئات بعد'**
  String get noCategoriesYet;

  /// No description provided for @noCategoriesMatchSearch.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فئات تطابق البحث'**
  String get noCategoriesMatchSearch;

  /// No description provided for @deleteCategoryQuestion.
  ///
  /// In ar, this message translates to:
  /// **'حذف الفئة؟'**
  String get deleteCategoryQuestion;

  /// No description provided for @items.
  ///
  /// In ar, this message translates to:
  /// **'الأصناف'**
  String get items;

  /// No description provided for @addItem.
  ///
  /// In ar, this message translates to:
  /// **'إضافة صنف'**
  String get addItem;

  /// No description provided for @editItem.
  ///
  /// In ar, this message translates to:
  /// **'تعديل صنف'**
  String get editItem;

  /// No description provided for @itemNameArabic.
  ///
  /// In ar, this message translates to:
  /// **'اسم الصنف بالعربي'**
  String get itemNameArabic;

  /// No description provided for @itemNameEnglish.
  ///
  /// In ar, this message translates to:
  /// **'اسم الصنف بالإنجليزي'**
  String get itemNameEnglish;

  /// No description provided for @itemDescriptionArabic.
  ///
  /// In ar, this message translates to:
  /// **'وصف الصنف بالعربي'**
  String get itemDescriptionArabic;

  /// No description provided for @itemDescriptionEnglish.
  ///
  /// In ar, this message translates to:
  /// **'وصف الصنف بالإنجليزي'**
  String get itemDescriptionEnglish;

  /// No description provided for @itemImage.
  ///
  /// In ar, this message translates to:
  /// **'صورة الصنف'**
  String get itemImage;

  /// No description provided for @category.
  ///
  /// In ar, this message translates to:
  /// **'الفئة'**
  String get category;

  /// No description provided for @searchItems.
  ///
  /// In ar, this message translates to:
  /// **'بحث في الأصناف'**
  String get searchItems;

  /// No description provided for @searchItemsHint.
  ///
  /// In ar, this message translates to:
  /// **'اسم الصنف أو الفئة أو الحجم'**
  String get searchItemsHint;

  /// No description provided for @noItemsYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أصناف بعد'**
  String get noItemsYet;

  /// No description provided for @noItemsMatchSearch.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أصناف تطابق البحث'**
  String get noItemsMatchSearch;

  /// No description provided for @deleteItemQuestion.
  ///
  /// In ar, this message translates to:
  /// **'حذف الصنف؟'**
  String get deleteItemQuestion;

  /// No description provided for @defaultKiloPrice.
  ///
  /// In ar, this message translates to:
  /// **'سعر الكيلو الافتراضي'**
  String get defaultKiloPrice;

  /// No description provided for @basePrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر الأساسي'**
  String get basePrice;

  /// No description provided for @oldPriceOptional.
  ///
  /// In ar, this message translates to:
  /// **'السعر القديم اختياري'**
  String get oldPriceOptional;

  /// No description provided for @sellMethod.
  ///
  /// In ar, this message translates to:
  /// **'طريقة البيع'**
  String get sellMethod;

  /// No description provided for @popular.
  ///
  /// In ar, this message translates to:
  /// **'شائع'**
  String get popular;

  /// No description provided for @newItem.
  ///
  /// In ar, this message translates to:
  /// **'جديد'**
  String get newItem;

  /// No description provided for @available.
  ///
  /// In ar, this message translates to:
  /// **'متاح'**
  String get available;

  /// No description provided for @activeItem.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get activeItem;

  /// No description provided for @sizesAndPrices.
  ///
  /// In ar, this message translates to:
  /// **'الأحجام وتسعيرتها'**
  String get sizesAndPrices;

  /// No description provided for @addSize.
  ///
  /// In ar, this message translates to:
  /// **'إضافة حجم'**
  String get addSize;

  /// No description provided for @noSizesAdded.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أحجام مضافة'**
  String get noSizesAdded;

  /// No description provided for @sizeName.
  ///
  /// In ar, this message translates to:
  /// **'اسم الحجم'**
  String get sizeName;

  /// No description provided for @sizeExample.
  ///
  /// In ar, this message translates to:
  /// **'مثال: صغير'**
  String get sizeExample;

  /// No description provided for @sizePrice.
  ///
  /// In ar, this message translates to:
  /// **'سعر الحجم'**
  String get sizePrice;

  /// No description provided for @deleteSize.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحجم'**
  String get deleteSize;

  /// No description provided for @branchesAdmin.
  ///
  /// In ar, this message translates to:
  /// **'الفروع'**
  String get branchesAdmin;

  /// No description provided for @addBranch.
  ///
  /// In ar, this message translates to:
  /// **'إضافة فرع'**
  String get addBranch;

  /// No description provided for @editBranch.
  ///
  /// In ar, this message translates to:
  /// **'تعديل فرع'**
  String get editBranch;

  /// No description provided for @noBranchesYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فروع بعد'**
  String get noBranchesYet;

  /// No description provided for @deleteBranchQuestion.
  ///
  /// In ar, this message translates to:
  /// **'حذف الفرع؟'**
  String get deleteBranchQuestion;

  /// No description provided for @branchNameArabic.
  ///
  /// In ar, this message translates to:
  /// **'اسم الفرع بالعربي'**
  String get branchNameArabic;

  /// No description provided for @branchNameEnglish.
  ///
  /// In ar, this message translates to:
  /// **'اسم الفرع بالإنجليزي'**
  String get branchNameEnglish;

  /// No description provided for @phoneNumbers.
  ///
  /// In ar, this message translates to:
  /// **'أرقام الهاتف'**
  String get phoneNumbers;

  /// No description provided for @separateWithCommaOrLine.
  ///
  /// In ar, this message translates to:
  /// **'افصل بينها بفاصلة أو سطر جديد'**
  String get separateWithCommaOrLine;

  /// No description provided for @branchOrdersWhatsapp.
  ///
  /// In ar, this message translates to:
  /// **'رقم واتساب طلبات الفرع'**
  String get branchOrdersWhatsapp;

  /// No description provided for @branchAddress.
  ///
  /// In ar, this message translates to:
  /// **'عنوان الفرع'**
  String get branchAddress;

  /// No description provided for @googleMapsUrl.
  ///
  /// In ar, this message translates to:
  /// **'رابط Google Maps'**
  String get googleMapsUrl;

  /// No description provided for @displayOrder.
  ///
  /// In ar, this message translates to:
  /// **'ترتيب العرض'**
  String get displayOrder;

  /// No description provided for @branchActive.
  ///
  /// In ar, this message translates to:
  /// **'الفرع نشط'**
  String get branchActive;

  /// No description provided for @ordersWhatsapp.
  ///
  /// In ar, this message translates to:
  /// **'واتساب الطلبات'**
  String get ordersWhatsapp;

  /// No description provided for @addAdmin.
  ///
  /// In ar, this message translates to:
  /// **'إضافة أدمن'**
  String get addAdmin;

  /// No description provided for @editAdmin.
  ///
  /// In ar, this message translates to:
  /// **'تعديل أدمن'**
  String get editAdmin;

  /// No description provided for @noUsersYet.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد مستخدمون بعد'**
  String get noUsersYet;

  /// No description provided for @adminEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get adminEmail;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// No description provided for @adminName.
  ///
  /// In ar, this message translates to:
  /// **'اسم الأدمن'**
  String get adminName;

  /// No description provided for @accountActive.
  ///
  /// In ar, this message translates to:
  /// **'الحساب نشط'**
  String get accountActive;

  /// No description provided for @currentAccount.
  ///
  /// In ar, this message translates to:
  /// **'حسابك الحالي'**
  String get currentAccount;

  /// No description provided for @deleteAdminQuestion.
  ///
  /// In ar, this message translates to:
  /// **'حذف الأدمن؟'**
  String get deleteAdminQuestion;

  /// No description provided for @noCategory.
  ///
  /// In ar, this message translates to:
  /// **'بدون فئة'**
  String get noCategory;

  /// No description provided for @order.
  ///
  /// In ar, this message translates to:
  /// **'ترتيب'**
  String get order;

  /// No description provided for @sizes.
  ///
  /// In ar, this message translates to:
  /// **'أحجام'**
  String get sizes;

  /// No description provided for @searchClear.
  ///
  /// In ar, this message translates to:
  /// **'مسح البحث'**
  String get searchClear;

  /// No description provided for @deleteImage.
  ///
  /// In ar, this message translates to:
  /// **'حذف الصورة'**
  String get deleteImage;

  /// No description provided for @confirmDeleteIrreversible.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن التراجع عن هذا الإجراء.'**
  String get confirmDeleteIrreversible;

  /// No description provided for @adminSavedRestaurantData.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ بيانات المطعم'**
  String get adminSavedRestaurantData;

  /// No description provided for @adminSavedCategory.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الفئة'**
  String get adminSavedCategory;

  /// No description provided for @adminDeletedCategory.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الفئة'**
  String get adminDeletedCategory;

  /// No description provided for @adminSavedItem.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الصنف'**
  String get adminSavedItem;

  /// No description provided for @adminDeletedItem.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الصنف'**
  String get adminDeletedItem;

  /// No description provided for @adminSavedBranch.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الفرع'**
  String get adminSavedBranch;

  /// No description provided for @adminDeletedBranch.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الفرع'**
  String get adminDeletedBranch;

  /// No description provided for @adminCreatedAdmin.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء الأدمن'**
  String get adminCreatedAdmin;

  /// No description provided for @adminSavedAdmin.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ بيانات الأدمن'**
  String get adminSavedAdmin;

  /// No description provided for @adminDeletedAdmin.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الأدمن'**
  String get adminDeletedAdmin;

  /// No description provided for @customMapLocation.
  ///
  /// In ar, this message translates to:
  /// **'رابط موقع مخصص'**
  String get customMapLocation;

  /// No description provided for @whatsappNewOrderFrom.
  ///
  /// In ar, this message translates to:
  /// **'طلب جديد من'**
  String get whatsappNewOrderFrom;

  /// No description provided for @whatsappReferenceNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم مرجعي'**
  String get whatsappReferenceNumber;

  /// No description provided for @whatsappSelectedBranch.
  ///
  /// In ar, this message translates to:
  /// **'الفرع المختار'**
  String get whatsappSelectedBranch;

  /// No description provided for @whatsappCustomerInfo.
  ///
  /// In ar, this message translates to:
  /// **'بيانات العميل'**
  String get whatsappCustomerInfo;

  /// No description provided for @whatsappCustomerName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get whatsappCustomerName;

  /// No description provided for @whatsappCustomerPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get whatsappCustomerPhone;

  /// No description provided for @whatsappDeliveryLocation.
  ///
  /// In ar, this message translates to:
  /// **'موقع التوصيل'**
  String get whatsappDeliveryLocation;

  /// No description provided for @whatsappAddress.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get whatsappAddress;

  /// No description provided for @whatsappCurrentLocationLink.
  ///
  /// In ar, this message translates to:
  /// **'رابط الموقع الحالي'**
  String get whatsappCurrentLocationLink;

  /// No description provided for @whatsappSentMapLink.
  ///
  /// In ar, this message translates to:
  /// **'رابط الخريطة المرسل'**
  String get whatsappSentMapLink;

  /// No description provided for @whatsappOrderDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الطلب'**
  String get whatsappOrderDetails;

  /// No description provided for @whatsappItemType.
  ///
  /// In ar, this message translates to:
  /// **'النوع'**
  String get whatsappItemType;

  /// No description provided for @whatsappQuantity.
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get whatsappQuantity;

  /// No description provided for @whatsappSubtotal.
  ///
  /// In ar, this message translates to:
  /// **'المجموع الفرعي'**
  String get whatsappSubtotal;

  /// No description provided for @whatsappDeliveryPrice.
  ///
  /// In ar, this message translates to:
  /// **'سعر التوصيل'**
  String get whatsappDeliveryPrice;

  /// No description provided for @whatsappFinalTotal.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي النهائي'**
  String get whatsappFinalTotal;

  /// No description provided for @whatsappThanksForChoosing.
  ///
  /// In ar, this message translates to:
  /// **'شكراً لاختياركم'**
  String get whatsappThanksForChoosing;

  /// No description provided for @increaseWeight.
  ///
  /// In ar, this message translates to:
  /// **'زيادة الوزن'**
  String get increaseWeight;

  /// No description provided for @decreaseWeight.
  ///
  /// In ar, this message translates to:
  /// **'إنقاص الوزن'**
  String get decreaseWeight;

  /// No description provided for @userSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات المستخدم'**
  String get userSettings;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @arabicLanguage.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabicLanguage;

  /// No description provided for @englishLanguage.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// No description provided for @appearance.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get appearance;

  /// No description provided for @lightMode.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get darkMode;

  /// No description provided for @savedCheckoutInfo.
  ///
  /// In ar, this message translates to:
  /// **'بيانات الطلب المحفوظة'**
  String get savedCheckoutInfo;

  /// No description provided for @noSavedCheckoutInfo.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات طلب محفوظة'**
  String get noSavedCheckoutInfo;

  /// No description provided for @clearSavedCheckoutInfo.
  ///
  /// In ar, this message translates to:
  /// **'مسح بيانات الطلب'**
  String get clearSavedCheckoutInfo;

  /// No description provided for @clearSavedCheckoutInfoQuestion.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد مسح الاسم ورقم الهاتف وموقع التوصيل المحفوظ؟'**
  String get clearSavedCheckoutInfoQuestion;

  /// No description provided for @savedDataCleared.
  ///
  /// In ar, this message translates to:
  /// **'تم مسح البيانات المحفوظة'**
  String get savedDataCleared;

  /// No description provided for @startupFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تشغيل التطبيق'**
  String get startupFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
