import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/error_messages.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/repositories/menu_repository.dart';
import 'menu_state.dart';

class MenuCubit extends Cubit<MenuState> {
  final MenuRepository repository;

  MenuCubit({required this.repository}) : super(MenuInitial());

  Future<void> loadMenuData() async {
    if (isClosed) return;
    emit(MenuLoading());

    try {
      final categoriesFuture = repository.getCategories();
      final itemsFuture = repository.getMenuItems();

      final results = await Future.wait([categoriesFuture, itemsFuture]);

      if (isClosed) return;

      final categories = results[0] as List<dynamic>;
      final allItems = results[1] as List<MenuItemEntity>;

      emit(
        MenuLoaded(
          categories: categories.cast(),
          allItems: allItems,
          filteredItems: allItems,
          selectedCategoryId: AppConstants.menuAllCategoryId,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(MenuError(ErrorMessages.withDetails(AppErrorKey.loadMenu, e)));
    }
  }

  void selectCategory(String categoryId) {
    if (isClosed) return;
    if (state is! MenuLoaded) return;

    final currentState = state as MenuLoaded;
    final filtered = _filterItems(
      allItems: currentState.allItems,
      categoryId: categoryId,
      query: currentState.searchQuery,
    );

    emit(
      currentState.copyWith(
        selectedCategoryId: categoryId,
        filteredItems: filtered,
      ),
    );
  }

  void searchItems(String query) {
    if (isClosed) return;
    if (state is! MenuLoaded) return;

    final currentState = state as MenuLoaded;
    final filtered = _filterItems(
      allItems: currentState.allItems,
      categoryId: currentState.selectedCategoryId,
      query: query,
    );

    emit(currentState.copyWith(searchQuery: query, filteredItems: filtered));
  }

  List<MenuItemEntity> _filterItems({
    required List<MenuItemEntity> allItems,
    required String categoryId,
    required String query,
  }) {
    return allItems.where((item) {
      final matchesCategory =
          categoryId == AppConstants.menuAllCategoryId ||
          item.categoryId == categoryId;

      final matchesQuery =
          query.trim().isEmpty ||
          item.nameAr.toLowerCase().contains(query.toLowerCase()) ||
          item.nameEn.toLowerCase().contains(query.toLowerCase()) ||
          item.descriptionAr.toLowerCase().contains(query.toLowerCase()) ||
          item.descriptionEn.toLowerCase().contains(query.toLowerCase());

      return matchesCategory && matchesQuery;
    }).toList();
  }
}
