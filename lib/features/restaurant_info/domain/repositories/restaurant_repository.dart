import '../entities/restaurant_config.dart';
import '../entities/branch.dart';

abstract class RestaurantRepository {
  Future<RestaurantConfig> getRestaurantConfig();
  Future<List<Branch>> getBranches();
}
