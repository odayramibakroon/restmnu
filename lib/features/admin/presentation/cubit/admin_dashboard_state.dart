import 'package:equatable/equatable.dart';

import '../../../menu/data/models/category_model.dart';
import '../../../menu/data/models/menu_item_model.dart';
import '../../data/admin_user_model.dart';
import '../../../restaurant_info/data/models/branch_model.dart';
import '../../../restaurant_info/data/models/restaurant_config_model.dart';

enum AdminDashboardStatus { initial, loading, loaded, saving, error }

enum AdminDashboardSuccess {
  restaurantSaved,
  categorySaved,
  categoryDeleted,
  itemSaved,
  itemDeleted,
  branchSaved,
  branchDeleted,
  adminCreated,
  adminSaved,
  adminDeleted,
}

class AdminDashboardState extends Equatable {
  final AdminDashboardStatus status;
  final RestaurantConfigModel? config;
  final List<CategoryModel> categories;
  final List<MenuItemModel> menuItems;
  final List<BranchModel> branches;
  final List<AdminUserModel> adminUsers;
  final String? errorMessage;
  final AdminDashboardSuccess? success;

  const AdminDashboardState({
    this.status = AdminDashboardStatus.initial,
    this.config,
    this.categories = const [],
    this.menuItems = const [],
    this.branches = const [],
    this.adminUsers = const [],
    this.errorMessage,
    this.success,
  });

  AdminDashboardState copyWith({
    AdminDashboardStatus? status,
    RestaurantConfigModel? config,
    List<CategoryModel>? categories,
    List<MenuItemModel>? menuItems,
    List<BranchModel>? branches,
    List<AdminUserModel>? adminUsers,
    String? errorMessage,
    AdminDashboardSuccess? success,
  }) {
    return AdminDashboardState(
      status: status ?? this.status,
      config: config ?? this.config,
      categories: categories ?? this.categories,
      menuItems: menuItems ?? this.menuItems,
      branches: branches ?? this.branches,
      adminUsers: adminUsers ?? this.adminUsers,
      errorMessage: errorMessage,
      success: success,
    );
  }

  @override
  List<Object?> get props => [
    status,
    config,
    categories,
    menuItems,
    branches,
    adminUsers,
    errorMessage,
    success,
  ];
}
