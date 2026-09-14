import '../../domain/entities/category.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasources/menu_remote_datasource.dart';

class MenuRepositoryImpl implements MenuRepository {
  final MenuRemoteDataSource remoteDataSource;

  MenuRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Category>> getCategories() async {
    return await remoteDataSource.getCategories();
  }

  @override
  Future<List<MenuItemEntity>> getMenuItems({String? categoryId}) async {
    return await remoteDataSource.getMenuItems(categoryId: categoryId);
  }
}
