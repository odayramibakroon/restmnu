import '../entities/category.dart';
import '../entities/menu_item.dart';

abstract class MenuRepository {
  Future<List<Category>> getCategories();
  Future<List<MenuItemEntity>> getMenuItems({String? categoryId});
}
