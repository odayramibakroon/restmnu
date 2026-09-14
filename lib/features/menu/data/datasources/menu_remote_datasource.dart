import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/error_messages.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/category_model.dart';
import '../models/menu_item_model.dart';

abstract class MenuRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<List<MenuItemModel>> getMenuItems({String? categoryId});
}

class MenuRemoteDataSourceImpl implements MenuRemoteDataSource {
  final FirebaseFirestore _firestore;

  MenuRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.collectionCategories)
          .where('isActive', isEqualTo: true)
          .get();

      final list = snapshot.docs
          .map((doc) => CategoryModel.fromSnapshot(doc))
          .toList();
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return list;
    } catch (e) {
      throw ServerException(
        ErrorMessages.withDetails(AppErrorKey.loadCategoriesFromFirestore, e),
      );
    }
  }

  @override
  Future<List<MenuItemModel>> getMenuItems({String? categoryId}) async {
    try {
      Query query = _firestore
          .collection(AppConstants.collectionMenuItems)
          .where('isActive', isEqualTo: true)
          .where('isAvailable', isEqualTo: true);

      if (categoryId != null &&
          categoryId.isNotEmpty &&
          categoryId != AppConstants.menuAllCategoryId) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }

      final snapshot = await query.get();

      final list = snapshot.docs
          .map((doc) => MenuItemModel.fromSnapshot(doc))
          .toList();
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return list;
    } catch (e) {
      throw ServerException(
        ErrorMessages.withDetails(AppErrorKey.loadMenuItemsFromFirestore, e),
      );
    }
  }
}
