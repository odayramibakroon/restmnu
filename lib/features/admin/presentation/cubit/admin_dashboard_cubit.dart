import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/admin_repository.dart';
import '../../data/admin_user_model.dart';
import '../../../menu/data/models/category_model.dart';
import '../../../menu/data/models/menu_item_model.dart';
import '../../../restaurant_info/data/models/branch_model.dart';
import '../../../restaurant_info/data/models/restaurant_config_model.dart';
import 'admin_dashboard_state.dart';

class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  final AdminRepository repository;

  AdminDashboardCubit({required this.repository})
    : super(const AdminDashboardState());

  Future<void> load() async {
    if (isClosed) return;
    emit(state.copyWith(status: AdminDashboardStatus.loading));

    try {
      final snapshot = await repository.loadDashboardData();
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AdminDashboardStatus.loaded,
          config: snapshot.config,
          categories: snapshot.categories,
          menuItems: snapshot.menuItems,
          branches: snapshot.branches,
          adminUsers: snapshot.adminUsers,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AdminDashboardStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> saveRestaurantConfig(
    RestaurantConfigModel config, {
    dynamic logoFile,
    required String oldLogoUrl,
  }) async {
    await _save(
      success: AdminDashboardSuccess.restaurantSaved,
      action: () => repository.saveRestaurantConfig(
        config,
        logoFile: logoFile,
        oldLogoUrl: oldLogoUrl,
      ),
    );
  }

  Future<void> saveCategory(
    CategoryModel category, {
    dynamic imageFile,
    required String oldImageUrl,
  }) async {
    await _save(
      success: AdminDashboardSuccess.categorySaved,
      action: () => repository.saveCategory(
        category,
        imageFile: imageFile,
        oldImageUrl: oldImageUrl,
      ),
    );
  }

  Future<void> deleteCategory(CategoryModel category) async {
    await _save(
      success: AdminDashboardSuccess.categoryDeleted,
      action: () => repository.deleteCategory(category),
    );
  }

  Future<void> saveMenuItem(
    MenuItemModel item, {
    dynamic imageFile,
    required String oldImageUrl,
    required List<String> oldImages,
  }) async {
    await _save(
      success: AdminDashboardSuccess.itemSaved,
      action: () => repository.saveMenuItem(
        item,
        imageFile: imageFile,
        oldImageUrl: oldImageUrl,
        oldImages: oldImages,
      ),
    );
  }

  Future<void> deleteMenuItem(MenuItemModel item) async {
    await _save(
      success: AdminDashboardSuccess.itemDeleted,
      action: () => repository.deleteMenuItem(item),
    );
  }

  Future<void> saveBranch(BranchModel branch) async {
    await _save(
      success: AdminDashboardSuccess.branchSaved,
      action: () => repository.saveBranch(branch),
    );
  }

  Future<void> deleteBranch(BranchModel branch) async {
    await _save(
      success: AdminDashboardSuccess.branchDeleted,
      action: () => repository.deleteBranch(branch),
    );
  }

  Future<void> createAdminUser({
    required String email,
    required String password,
    required String displayName,
    required String phone,
    required bool isActive,
  }) async {
    await _save(
      success: AdminDashboardSuccess.adminCreated,
      action: () => repository.createAdminUser(
        email: email,
        password: password,
        displayName: displayName,
        phone: phone,
        isActive: isActive,
      ),
    );
  }

  Future<void> saveAdminUser(AdminUserModel adminUser) async {
    await _save(
      success: AdminDashboardSuccess.adminSaved,
      action: () => repository.saveAdminUser(adminUser),
    );
  }

  Future<void> deleteAdminUser(AdminUserModel adminUser) async {
    await _save(
      success: AdminDashboardSuccess.adminDeleted,
      action: () => repository.deleteAdminUser(adminUser),
    );
  }

  Future<void> _save({
    required AdminDashboardSuccess success,
    required Future<void> Function() action,
  }) async {
    if (isClosed) return;
    emit(state.copyWith(status: AdminDashboardStatus.saving));

    try {
      await action();
      if (isClosed) return;
      final snapshot = await repository.loadDashboardData();
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AdminDashboardStatus.loaded,
          config: snapshot.config,
          categories: snapshot.categories,
          menuItems: snapshot.menuItems,
          branches: snapshot.branches,
          adminUsers: snapshot.adminUsers,
          success: success,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AdminDashboardStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
