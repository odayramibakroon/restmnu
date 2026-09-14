import '../../domain/entities/restaurant_config.dart';
import '../../domain/entities/branch.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../datasources/restaurant_remote_datasource.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  final RestaurantRemoteDataSource remoteDataSource;

  RestaurantRepositoryImpl({required this.remoteDataSource});

  @override
  Future<RestaurantConfig> getRestaurantConfig() async {
    return await remoteDataSource.getRestaurantConfig();
  }

  @override
  Future<List<Branch>> getBranches() async {
    return await remoteDataSource.getBranches();
  }
}
