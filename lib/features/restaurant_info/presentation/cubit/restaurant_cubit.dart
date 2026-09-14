import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/error_messages.dart';
import '../../domain/repositories/restaurant_repository.dart';
import 'restaurant_state.dart';

class RestaurantCubit extends Cubit<RestaurantState> {
  final RestaurantRepository repository;

  RestaurantCubit({required this.repository}) : super(RestaurantInitial());

  Future<void> loadRestaurantInfo() async {
    if (isClosed) return;
    emit(RestaurantLoading());

    try {
      final configFuture = repository.getRestaurantConfig();
      final branchesFuture = repository.getBranches();

      final results = await Future.wait([configFuture, branchesFuture]);

      if (isClosed) return;

      emit(
        RestaurantLoaded(
          config: results[0] as dynamic,
          branches: results[1] as dynamic,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        RestaurantError(
          ErrorMessages.withDetails(AppErrorKey.loadRestaurantInfo, e),
        ),
      );
    }
  }
}
