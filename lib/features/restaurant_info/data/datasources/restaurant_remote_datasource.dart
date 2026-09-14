import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/error_messages.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/restaurant_config_model.dart';
import '../models/branch_model.dart';

abstract class RestaurantRemoteDataSource {
  Future<RestaurantConfigModel> getRestaurantConfig();
  Future<List<BranchModel>> getBranches();
}

class RestaurantRemoteDataSourceImpl implements RestaurantRemoteDataSource {
  final FirebaseFirestore _firestore;

  RestaurantRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<RestaurantConfigModel> getRestaurantConfig() async {
    try {
      final doc = await _firestore
          .collection(AppConstants.collectionAppConfig)
          .doc(AppConstants.documentMainConfig)
          .get();

      if (doc.exists && doc.data() != null) {
        return RestaurantConfigModel.fromMap(doc.data()!);
      }
      throw ServerException(
        ErrorMessages.message(AppErrorKey.restaurantConfigMissing),
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        ErrorMessages.withDetails(AppErrorKey.loadRestaurantFromFirestore, e),
      );
    }
  }

  @override
  Future<List<BranchModel>> getBranches() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.collectionBranches)
          .where('isActive', isEqualTo: true)
          .get();

      final branches = querySnapshot.docs
          .map((doc) => BranchModel.fromSnapshot(doc))
          .toList();
      branches.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return branches;
    } catch (e) {
      throw ServerException(
        ErrorMessages.withDetails(AppErrorKey.loadBranchesFromFirestore, e),
      );
    }
  }
}
