import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import '../../features/admin/data/admin_repository.dart';
import '../../features/admin/presentation/cubit/admin_auth_cubit.dart';
import '../../features/admin/presentation/cubit/admin_dashboard_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  // External
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Core Services
  sl.registerLazySingleton<LocationService>(() => LocationServiceImpl());
  sl.registerLazySingleton<WhatsAppService>(() => WhatsAppServiceImpl());
  sl.registerLazySingleton<UrlLauncherService>(() => UrlLauncherServiceImpl());
  sl.registerLazySingleton<LocalStorageService>(
    () => SharedPreferencesLocalStorageService(sl()),
  );
  sl.registerLazySingleton<ImageStorageService>(
    () => SupabaseImageStorageServiceImpl(),
  );

  // Restaurant Feature
  sl.registerLazySingleton<RestaurantRemoteDataSource>(
    () => RestaurantRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<RestaurantRepository>(
    () => RestaurantRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerFactory<RestaurantCubit>(() => RestaurantCubit(repository: sl()));

  // Menu Feature
  sl.registerLazySingleton<MenuRemoteDataSource>(
    () => MenuRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<MenuRepository>(
    () => MenuRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerFactory<MenuCubit>(() => MenuCubit(repository: sl()));

  // Cart Feature
  sl.registerLazySingleton<CartCubit>(() => CartCubit(localStorage: sl()));

  // Checkout Feature
  sl.registerFactory<CheckoutCubit>(
    () => CheckoutCubit(
      locationService: sl(),
      whatsAppService: sl(),
      localStorage: sl(),
    ),
  );

  // Theme Cubit
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit(localStorage: sl()));

  // Admin Feature
  sl.registerLazySingleton<AdminRepository>(
    () =>
        AdminRepository(auth: sl(), firestore: sl(), imageStorageService: sl()),
  );
  sl.registerFactory<AdminAuthCubit>(() => AdminAuthCubit(repository: sl()));
  sl.registerFactory<AdminDashboardCubit>(
    () => AdminDashboardCubit(repository: sl()),
  );
}
