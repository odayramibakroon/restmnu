import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import '../../../firebase_options.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/services/image_storage_service.dart';
import 'admin_user_model.dart';
import '../../menu/data/models/category_model.dart';
import '../../menu/data/models/menu_item_model.dart';
import '../../restaurant_info/data/models/branch_model.dart';
import '../../restaurant_info/data/models/restaurant_config_model.dart';

class AdminSnapshot {
  final RestaurantConfigModel config;
  final List<CategoryModel> categories;
  final List<MenuItemModel> menuItems;
  final List<BranchModel> branches;
  final List<AdminUserModel> adminUsers;

  const AdminSnapshot({
    required this.config,
    required this.categories,
    required this.menuItems,
    required this.branches,
    required this.adminUsers,
  });
}

class AdminRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final ImageStorageService imageStorageService;

  AdminRepository({
    required this.auth,
    required this.firestore,
    required this.imageStorageService,
  });

  Stream<User?> get authStateChanges => auth.authStateChanges();

  User? get currentUser => auth.currentUser;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw ServerException(
          ErrorMessages.message(AppErrorKey.authUserMissingAfterSignIn),
        );
      }
      await ensureAdminAccess(user);
      return credential;
    } on FirebaseAuthException catch (e) {
      throw ServerException(_mapAuthError(e));
    } on FirebaseException catch (e) {
      throw ServerException(_mapFirebaseError(e));
    } on PlatformException catch (e) {
      throw ServerException(_mapPlatformError(e));
    } catch (e) {
      throw ServerException(ErrorMessages.withDetails(AppErrorKey.signIn, e));
    }
  }

  Future<void> ensureAdminAccess(User user) async {
    try {
      final adminsRef = firestore.collection(AppConstants.collectionAdminUsers);
      final existingAdmins = await adminsRef.limit(1).get();

      if (existingAdmins.docs.isEmpty) {
        final now = DateTime.now();
        final firstAdmin = AdminUserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? user.email ?? 'Admin',
          phone: user.phoneNumber ?? '',
          isActive: true,
          createdAt: now,
          updatedAt: now,
          createdBy: user.uid,
        );
        await adminsRef.doc(user.uid).set(firstAdmin.toMap());
        return;
      }

      final adminDoc = await adminsRef.doc(user.uid).get();
      final adminData = adminDoc.data();
      final isActive = adminData?['isActive'] as bool? ?? false;
      if (!adminDoc.exists || !isActive) {
        await auth.signOut();
        throw ServerException(
          ErrorMessages.message(AppErrorKey.adminAccountInactive),
        );
      }
    } on ServerException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(_mapFirebaseError(e));
    } catch (e) {
      throw ServerException(
        ErrorMessages.withDetails(AppErrorKey.verifyAdminAccess, e),
      );
    }
  }

  Future<void> signOut() async {
    try {
      await auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw ServerException(_mapAuthError(e));
    } on FirebaseException catch (e) {
      throw ServerException(_mapFirebaseError(e));
    } catch (e) {
      throw ServerException(ErrorMessages.withDetails(AppErrorKey.signOut, e));
    }
  }

  Future<AdminSnapshot> loadDashboardData() async {
    try {
      final configFuture = firestore
          .collection(AppConstants.collectionAppConfig)
          .doc(AppConstants.documentMainConfig)
          .get();
      final categoriesFuture = firestore
          .collection(AppConstants.collectionCategories)
          .get();
      final itemsFuture = firestore
          .collection(AppConstants.collectionMenuItems)
          .get();
      final branchesFuture = firestore
          .collection(AppConstants.collectionBranches)
          .get();
      final adminUsersFuture = firestore
          .collection(AppConstants.collectionAdminUsers)
          .get();

      final results = await Future.wait([
        configFuture,
        categoriesFuture,
        itemsFuture,
        branchesFuture,
        adminUsersFuture,
      ]);

      final configDoc = results[0] as DocumentSnapshot<Map<String, dynamic>>;
      final categoriesSnapshot =
          results[1] as QuerySnapshot<Map<String, dynamic>>;
      final itemsSnapshot = results[2] as QuerySnapshot<Map<String, dynamic>>;
      final branchesSnapshot =
          results[3] as QuerySnapshot<Map<String, dynamic>>;
      final adminUsersSnapshot =
          results[4] as QuerySnapshot<Map<String, dynamic>>;

      final categories =
          categoriesSnapshot.docs
              .map((doc) => CategoryModel.fromMap(doc.id, doc.data()))
              .toList()
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      final menuItems =
          itemsSnapshot.docs
              .map((doc) => MenuItemModel.fromMap(doc.id, doc.data()))
              .toList()
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      final branches =
          branchesSnapshot.docs
              .map((doc) => BranchModel.fromMap(doc.id, doc.data()))
              .toList()
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      final adminUsers =
          adminUsersSnapshot.docs
              .map((doc) => AdminUserModel.fromMap(doc.id, doc.data()))
              .toList()
            ..sort((a, b) => a.email.compareTo(b.email));

      return AdminSnapshot(
        config: configDoc.exists && configDoc.data() != null
            ? RestaurantConfigModel.fromMap(configDoc.data()!)
            : _emptyRestaurantConfig(),
        categories: categories,
        menuItems: menuItems,
        branches: branches,
        adminUsers: adminUsers,
      );
    } catch (e) {
      throw ServerException(
        ErrorMessages.withDetails(AppErrorKey.loadDashboard, e),
      );
    }
  }

  Future<void> saveRestaurantConfig(
    RestaurantConfigModel config, {
    dynamic logoFile,
    required String oldLogoUrl,
  }) async {
    var nextLogoUrl = config.logoUrl;

    if (logoFile != null) {
      nextLogoUrl = await imageStorageService.uploadImage(
        imageFile: logoFile,
        folder: 'restaurant',
        customFileName: 'logo_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
    }

    final nextConfig = RestaurantConfigModel(
      storeNameAr: config.storeNameAr,
      storeNameEn: config.storeNameEn,
      storeDescriptionAr: config.storeDescriptionAr,
      storeDescriptionEn: config.storeDescriptionEn,
      logoUrl: nextLogoUrl,
      whatsappNumber: config.whatsappNumber,
      supportPhone: config.supportPhone,
      supportEmail: config.supportEmail,
      facebookUrl: config.facebookUrl,
      instagramUrl: config.instagramUrl,
      tiktokUrl: config.tiktokUrl,
      defaultDeliveryPrice: config.defaultDeliveryPrice,
      savedDeliveryLocation: config.savedDeliveryLocation,
      currency: config.currency,
      enableDarkMode: config.enableDarkMode,
      updatedAt: DateTime.now(),
    );

    try {
      await firestore
          .collection(AppConstants.collectionAppConfig)
          .doc(AppConstants.documentMainConfig)
          .set(nextConfig.toMap());
      await _deleteReplacedImage(oldLogoUrl, nextLogoUrl);
    } catch (e) {
      throw ServerException(
        ErrorMessages.withDetails(AppErrorKey.saveRestaurantConfig, e),
      );
    }
  }

  Future<void> saveCategory(
    CategoryModel category, {
    dynamic imageFile,
    required String oldImageUrl,
  }) async {
    var nextImageUrl = category.imageUrl;

    if (imageFile != null) {
      nextImageUrl = await imageStorageService.uploadImage(
        imageFile: imageFile,
        folder: 'categories',
        customFileName:
            '${category.id}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
    }

    final nextCategory = CategoryModel(
      id: category.id,
      nameAr: category.nameAr,
      nameEn: category.nameEn,
      imageUrl: nextImageUrl,
      sortOrder: category.sortOrder,
      isActive: category.isActive,
    );

    try {
      await firestore
          .collection(AppConstants.collectionCategories)
          .doc(nextCategory.id)
          .set({
            ...nextCategory.toMap(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      await _deleteReplacedImage(oldImageUrl, nextImageUrl);
    } catch (e) {
      throw ServerException(
        ErrorMessages.withDetails(AppErrorKey.saveCategory, e),
      );
    }
  }

  Future<void> deleteCategory(CategoryModel category) async {
    try {
      final linkedItems = await firestore
          .collection(AppConstants.collectionMenuItems)
          .where('categoryId', isEqualTo: category.id)
          .limit(1)
          .get();

      if (linkedItems.docs.isNotEmpty) {
        throw ServerException(
          ErrorMessages.message(AppErrorKey.cannotDeleteCategoryWithItems),
        );
      }

      await firestore
          .collection(AppConstants.collectionCategories)
          .doc(category.id)
          .delete();
      await imageStorageService.deleteImageByUrl(category.imageUrl);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        ErrorMessages.withDetails(AppErrorKey.deleteCategory, e),
      );
    }
  }

  Future<void> saveMenuItem(
    MenuItemModel item, {
    dynamic imageFile,
    required String oldImageUrl,
    required List<String> oldImages,
  }) async {
    var nextImageUrl = item.imageUrl;

    if (imageFile != null) {
      nextImageUrl = await imageStorageService.uploadImage(
        imageFile: imageFile,
        folder: 'products',
        customFileName:
            '${item.id}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
    }

    final nextItem = MenuItemModel(
      id: item.id,
      categoryId: item.categoryId,
      nameAr: item.nameAr,
      nameEn: item.nameEn,
      descriptionAr: item.descriptionAr,
      descriptionEn: item.descriptionEn,
      price: item.price,
      oldPrice: item.oldPrice,
      imageUrl: nextImageUrl,
      images: nextImageUrl.isEmpty ? const [] : [nextImageUrl],
      isPopular: item.isPopular,
      isNew: item.isNew,
      isAvailable: item.isAvailable,
      isActive: item.isActive,
      sortOrder: item.sortOrder,
      unitType: item.unitType,
      sizes: item.sizes,
      sizePrices: item.sizePrices,
    );

    try {
      await firestore
          .collection(AppConstants.collectionMenuItems)
          .doc(nextItem.id)
          .set({
            ...nextItem.toMap(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      final replacedUrls = {oldImageUrl, ...oldImages}
        ..removeWhere((url) => url.trim().isEmpty || url == nextImageUrl);

      for (final url in replacedUrls) {
        await imageStorageService.deleteImageByUrl(url);
      }
    } catch (e) {
      throw ServerException(
        ErrorMessages.withDetails(AppErrorKey.saveMenuItem, e),
      );
    }
  }

  Future<void> deleteMenuItem(MenuItemModel item) async {
    try {
      await firestore
          .collection(AppConstants.collectionMenuItems)
          .doc(item.id)
          .delete();
      final imageUrls = {item.imageUrl, ...item.images}
        ..removeWhere((url) => url.trim().isEmpty);

      for (final url in imageUrls) {
        await imageStorageService.deleteImageByUrl(url);
      }
    } catch (e) {
      throw ServerException(
        ErrorMessages.withDetails(AppErrorKey.deleteMenuItem, e),
      );
    }
  }

  Future<void> saveBranch(BranchModel branch) async {
    try {
      await firestore
          .collection(AppConstants.collectionBranches)
          .doc(branch.id)
          .set({
            ...branch.toMap(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (e) {
      throw ServerException(
        ErrorMessages.withDetails(AppErrorKey.saveBranch, e),
      );
    }
  }

  Future<void> deleteBranch(BranchModel branch) async {
    try {
      await firestore
          .collection(AppConstants.collectionBranches)
          .doc(branch.id)
          .delete();
    } catch (e) {
      throw ServerException(
        ErrorMessages.withDetails(AppErrorKey.deleteBranch, e),
      );
    }
  }

  Future<void> createAdminUser({
    required String email,
    required String password,
    required String displayName,
    required String phone,
    required bool isActive,
  }) async {
    FirebaseApp? secondaryApp;

    try {
      final appName = 'admin_create_${DateTime.now().microsecondsSinceEpoch}';
      secondaryApp = await Firebase.initializeApp(
        name: appName,
        options: DefaultFirebaseOptions.currentPlatform,
      );
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final createdUser = credential.user;
      if (createdUser == null) {
        throw ServerException(
          ErrorMessages.message(AppErrorKey.createAdminAccount),
        );
      }

      final normalizedDisplayName = displayName.trim();
      if (normalizedDisplayName.isNotEmpty) {
        await createdUser.updateDisplayName(normalizedDisplayName);
      }

      final now = DateTime.now();
      final adminUser = AdminUserModel(
        uid: createdUser.uid,
        email: createdUser.email ?? email.trim(),
        displayName: normalizedDisplayName,
        phone: phone.trim(),
        isActive: isActive,
        createdAt: now,
        updatedAt: now,
        createdBy: currentUser?.uid ?? '',
      );

      await firestore
          .collection(AppConstants.collectionAdminUsers)
          .doc(createdUser.uid)
          .set(adminUser.toMap());
      await secondaryAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw ServerException(_mapAuthError(e));
    } on FirebaseException catch (e) {
      throw ServerException(_mapFirebaseError(e));
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        ErrorMessages.withDetails(AppErrorKey.createAdmin, e),
      );
    } finally {
      try {
        await secondaryApp?.delete();
      } catch (_) {}
    }
  }

  Future<void> saveAdminUser(AdminUserModel adminUser) async {
    try {
      if (adminUser.uid == currentUser?.uid && !adminUser.isActive) {
        throw ServerException(
          ErrorMessages.message(AppErrorKey.cannotDisableCurrentAdmin),
        );
      }

      await _ensureActiveAdminWillRemain(
        excludedUid: adminUser.uid,
        includeEditedUserAsActive: adminUser.isActive,
      );

      await firestore
          .collection(AppConstants.collectionAdminUsers)
          .doc(adminUser.uid)
          .set({
            ...adminUser.copyWith(updatedAt: DateTime.now()).toMap(),
            'createdAt': Timestamp.fromDate(adminUser.createdAt),
          }, SetOptions(merge: true));
    } on ServerException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(_mapFirebaseError(e));
    } catch (e) {
      throw ServerException(
        ErrorMessages.withDetails(AppErrorKey.saveAdmin, e),
      );
    }
  }

  Future<void> deleteAdminUser(AdminUserModel adminUser) async {
    try {
      if (adminUser.uid == currentUser?.uid) {
        throw ServerException(
          ErrorMessages.message(AppErrorKey.cannotDeleteCurrentAdmin),
        );
      }

      await _ensureActiveAdminWillRemain(excludedUid: adminUser.uid);

      await firestore
          .collection(AppConstants.collectionAdminUsers)
          .doc(adminUser.uid)
          .delete();
    } on ServerException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(_mapFirebaseError(e));
    } catch (e) {
      throw ServerException(
        ErrorMessages.withDetails(AppErrorKey.deleteAdmin, e),
      );
    }
  }

  Future<void> _ensureActiveAdminWillRemain({
    required String excludedUid,
    bool includeEditedUserAsActive = false,
  }) async {
    final activeAdmins = await firestore
        .collection(AppConstants.collectionAdminUsers)
        .where('isActive', isEqualTo: true)
        .get();

    final remainingActiveAdmins = activeAdmins.docs
        .where((doc) => doc.id != excludedUid)
        .length;
    final nextActiveCount =
        remainingActiveAdmins + (includeEditedUserAsActive ? 1 : 0);

    if (nextActiveCount < 1) {
      throw ServerException(
        ErrorMessages.message(AppErrorKey.keepOneActiveAdmin),
      );
    }
  }

  Future<void> _deleteReplacedImage(String oldUrl, String nextUrl) async {
    if (oldUrl.trim().isEmpty || oldUrl == nextUrl) return;
    await imageStorageService.deleteImageByUrl(oldUrl);
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return ErrorMessages.message(AppErrorKey.invalidEmail);
      case 'user-disabled':
        return ErrorMessages.message(AppErrorKey.userDisabled);
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return ErrorMessages.message(AppErrorKey.invalidCredentials);
      case 'too-many-requests':
        return ErrorMessages.message(AppErrorKey.tooManyRequests);
      default:
        return e.message ?? ErrorMessages.message(AppErrorKey.signIn);
    }
  }

  String _mapFirebaseError(FirebaseException e) {
    switch (e.code) {
      case 'app-not-authorized':
        return ErrorMessages.message(AppErrorKey.firebaseAppNotAuthorized);
      case 'network-request-failed':
        return ErrorMessages.message(AppErrorKey.firebaseNetwork);
      default:
        final message = e.message?.trim();
        return message == null || message.isEmpty
            ? ErrorMessages.withCode(AppErrorKey.firebaseLogin, e.code)
            : ErrorMessages.withCode(
                AppErrorKey.firebaseLogin,
                e.code,
                details: message,
              );
    }
  }

  String _mapPlatformError(PlatformException e) {
    final details = [
      if (e.code.trim().isNotEmpty) e.code.trim(),
      if ((e.message ?? '').trim().isNotEmpty) e.message!.trim(),
      if (e.details != null) e.details.toString(),
    ].join(' - ');

    return details.isEmpty
        ? ErrorMessages.message(AppErrorKey.platformLogin)
        : ErrorMessages.withDetails(AppErrorKey.signIn, details);
  }

  RestaurantConfigModel _emptyRestaurantConfig() {
    return RestaurantConfigModel(
      storeNameAr: '',
      storeNameEn: '',
      storeDescriptionAr: '',
      storeDescriptionEn: '',
      logoUrl: '',
      whatsappNumber: '',
      supportPhone: '',
      supportEmail: '',
      facebookUrl: '',
      instagramUrl: '',
      tiktokUrl: '',
      defaultDeliveryPrice: 0,
      savedDeliveryLocation: const DeliveryLocationModel(
        latitude: 0,
        longitude: 0,
        formattedAddress: '',
      ),
      currency: '',
      enableDarkMode: false,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
