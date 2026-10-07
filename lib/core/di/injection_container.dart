import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
 import 'package:shared_preferences/shared_preferences.dart';
import '../services/location_service.dart';
import '../services/whatsapp_service.dart';
import '../services/url_launcher_service.dart';
import '../services/image_storage_service.dart';
import '../storage/local_storage_service.dart';
import '../theme/theme_cubit.dart';

import '../../features/restaurant_info/data/datasources/restaurant_remote_datasource.dart';
import '../../features/restaurant_info/data/repositories/restaurant_repository_impl.dart';
import '../../features/restaurant_info/domain/repositories/restaurant_repository.dart';
import '../../features/restaurant_info/presentation/cubit/restaurant_cubit.dart';

import '../../features/menu/data/datasources/menu_remote_datasource.dart';
import '../../features/menu/data/repositories/menu_repository_impl.dart';
import '../../features/menu/domain/repositories/menu_repository.dart';
import '../../features/menu/presentation/cubit/menu_cubit.dart';

import '../../features/cart/presentation/cubit/cart_cubit.dart';

import '../../features/checkout/presentation/cubit/checkout_cubit.dart';
 
final sl = GetIt.instance;

Future<void> initDependencies() async {
  final sharedPreferences = sl.isRegistered<SharedPreferences>()
      ? sl<SharedPreferences>()
      : await SharedPreferences.getInstance();

  // External
  _registerLazySingletonIfAbsent<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  _registerLazySingletonIfAbsent<SharedPreferences>(() => sharedPreferences);

  // Core Services
  _registerLazySingletonIfAbsent<LocationService>(() => LocationServiceImpl());
  _registerLazySingletonIfAbsent<WhatsAppService>(() => WhatsAppServiceImpl());
  _registerLazySingletonIfAbsent<UrlLauncherService>(
    () => UrlLauncherServiceImpl(),
  );
  _registerLazySingletonIfAbsent<LocalStorageService>(
    () => SharedPreferencesLocalStorageService(sl()),
  );
  _registerLazySingletonIfAbsent<ImageStorageService>(
    () => SupabaseImageStorageServiceImpl(),
  );

  // Restaurant Feature
  _registerLazySingletonIfAbsent<RestaurantRemoteDataSource>(
    () => RestaurantRemoteDataSourceImpl(firestore: sl()),
  );
  _registerLazySingletonIfAbsent<RestaurantRepository>(
    () => RestaurantRepositoryImpl(remoteDataSource: sl()),
  );
  _registerFactoryIfAbsent<RestaurantCubit>(
    () => RestaurantCubit(repository: sl()),
  );

  // Menu Feature
  _registerLazySingletonIfAbsent<MenuRemoteDataSource>(
    () => MenuRemoteDataSourceImpl(firestore: sl()),
  );
  _registerLazySingletonIfAbsent<MenuRepository>(
    () => MenuRepositoryImpl(remoteDataSource: sl()),
  );
  _registerFactoryIfAbsent<MenuCubit>(() => MenuCubit(repository: sl()));

  // Cart Feature
  _registerLazySingletonIfAbsent<CartCubit>(
    () => CartCubit(localStorage: sl()),
  );

  // Checkout Feature
  _registerFactoryIfAbsent<CheckoutCubit>(
    () => CheckoutCubit(
      locationService: sl(),
      whatsAppService: sl(),
      localStorage: sl(),
    ),
  );

  // Theme Cubit
  _registerLazySingletonIfAbsent<ThemeCubit>(
    () => ThemeCubit(localStorage: sl()),
  );

 
}

void _registerLazySingletonIfAbsent<T extends Object>(T Function() factory) {
  if (!sl.isRegistered<T>()) {
    sl.registerLazySingleton<T>(factory);
  }
}

void _registerFactoryIfAbsent<T extends Object>(T Function() factory) {
  if (!sl.isRegistered<T>()) {
    sl.registerFactory<T>(factory);
  }
}
