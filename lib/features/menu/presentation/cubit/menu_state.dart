import 'package:equatable/equatable.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/menu_item.dart';

abstract class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object?> get props => [];
}

class MenuInitial extends MenuState {}

class MenuLoading extends MenuState {}

class MenuLoaded extends MenuState {
  final List<Category> categories;
  final List<MenuItemEntity> allItems;
  final List<MenuItemEntity> filteredItems;
  final String selectedCategoryId;
  final String searchQuery;

  const MenuLoaded({
    required this.categories,
    required this.allItems,
    required this.filteredItems,
    required this.selectedCategoryId,
    this.searchQuery = '',
  });

  MenuLoaded copyWith({
    List<Category>? categories,
    List<MenuItemEntity>? allItems,
    List<MenuItemEntity>? filteredItems,
    String? selectedCategoryId,
    String? searchQuery,
  }) {
    return MenuLoaded(
      categories: categories ?? this.categories,
      allItems: allItems ?? this.allItems,
      filteredItems: filteredItems ?? this.filteredItems,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    categories,
    allItems,
    filteredItems,
    selectedCategoryId,
    searchQuery,
  ];
}

class MenuError extends MenuState {
  final String message;
  const MenuError(this.message);

  @override
  List<Object?> get props => [message];
}
