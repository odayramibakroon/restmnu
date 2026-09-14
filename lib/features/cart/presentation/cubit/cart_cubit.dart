import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/error_messages.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/local_storage_keys.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../menu/domain/entities/menu_item.dart';
import '../../domain/entities/cart_item.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final LocalStorageService localStorage;

  CartCubit({required this.localStorage}) : super(const CartState());

  Future<void> restoreCart() async {
    if (isClosed) return;

    try {
      final rawCart = await localStorage.readString(
        LocalStorageKeys.cartItems,
        errorKey: AppErrorKey.loadCartFromLocalStorage,
      );
      if (rawCart == null || rawCart.trim().isEmpty) return;

      final decoded = jsonDecode(rawCart);
      if (decoded is! List) return;

      final restoredItems = decoded
          .map(_cartItemFromMap)
          .whereType<CartItem>()
          .toList();
      if (!isClosed) emit(state.copyWith(items: restoredItems));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void setDeliveryPrice(double price) {
    if (isClosed) return;
    if (state.deliveryPrice == price) return;
    emit(state.copyWith(deliveryPrice: price));
  }

  void addItem(
    MenuItemEntity item, {
    double quantity = 1,
    String? selectedSize,
  }) {
    if (isClosed) return;
    final normalizedQuantity = _normalizeQuantity(item, quantity);
    if (normalizedQuantity <= 0) return;

    final newItemKey = '${item.id}|${selectedSize ?? ''}';
    final existingIndex = state.items.indexWhere((ci) => ci.key == newItemKey);

    List<CartItem> updatedList = List.from(state.items);
    if (existingIndex >= 0) {
      final currentItem = updatedList[existingIndex];
      updatedList[existingIndex] = currentItem.copyWith(
        quantity: _normalizeQuantity(
          item,
          currentItem.quantity + normalizedQuantity,
        ),
      );
    } else {
      updatedList.add(
        CartItem(
          item: item,
          quantity: normalizedQuantity,
          selectedSize: selectedSize,
        ),
      );
    }

    _setItems(updatedList);
  }

  void increaseQuantity(String cartItemKey) {
    if (isClosed) return;
    final updatedList = state.items.map((ci) {
      if (ci.key == cartItemKey) {
        final step = ci.item.isSoldByWeight ? 0.1 : 1.0;
        return ci.copyWith(
          quantity: _normalizeQuantity(ci.item, ci.quantity + step),
        );
      }
      return ci;
    }).toList();

    _setItems(updatedList);
  }

  void decreaseQuantity(String cartItemKey) {
    if (isClosed) return;
    final updatedList = <CartItem>[];

    for (final ci in state.items) {
      if (ci.key == cartItemKey) {
        final step = ci.item.isSoldByWeight ? 0.1 : 1.0;
        if (ci.quantity > step) {
          updatedList.add(
            ci.copyWith(
              quantity: _normalizeQuantity(ci.item, ci.quantity - step),
            ),
          );
        }
        // If quantity reaches the minimum, decreasing it removes the item.
      } else {
        updatedList.add(ci);
      }
    }

    _setItems(updatedList);
  }

  void removeItem(String cartItemKey) {
    if (isClosed) return;
    final updatedList = state.items
        .where((ci) => ci.key != cartItemKey)
        .toList();
    _setItems(updatedList);
  }

  void updateQuantity(String cartItemKey, double quantity) {
    if (isClosed) return;

    final updatedList = <CartItem>[];
    for (final ci in state.items) {
      if (ci.key == cartItemKey) {
        final normalizedQuantity = _normalizeQuantity(ci.item, quantity);
        if (normalizedQuantity > 0) {
          updatedList.add(ci.copyWith(quantity: normalizedQuantity));
        }
      } else {
        updatedList.add(ci);
      }
    }

    _setItems(updatedList);
  }

  void clearCart() {
    if (isClosed) return;
    _setItems(const []);
  }

  double _normalizeQuantity(MenuItemEntity item, double quantity) {
    if (item.isSoldByWeight) {
      return (quantity * 1000).round() / 1000;
    }

    return quantity.roundToDouble();
  }

  void _setItems(List<CartItem> items) {
    emit(state.copyWith(items: items));
    unawaited(_persistItems(items));
  }

  Future<void> _persistItems(List<CartItem> items) async {
    try {
      final rawCart = jsonEncode(items.map(_cartItemToMap).toList());
      await localStorage.writeString(
        LocalStorageKeys.cartItems,
        rawCart,
        errorKey: AppErrorKey.saveCartToLocalStorage,
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Map<String, dynamic> _cartItemToMap(CartItem cartItem) {
    return {
      'quantity': cartItem.quantity,
      'selectedSize': cartItem.selectedSize,
      'item': _menuItemToMap(cartItem.item),
    };
  }

  Map<String, dynamic> _menuItemToMap(MenuItemEntity item) {
    return {
      'id': item.id,
      'categoryId': item.categoryId,
      'nameAr': item.nameAr,
      'nameEn': item.nameEn,
      'descriptionAr': item.descriptionAr,
      'descriptionEn': item.descriptionEn,
      'price': item.price,
      'oldPrice': item.oldPrice,
      'imageUrl': item.imageUrl,
      'images': item.images,
      'isPopular': item.isPopular,
      'isNew': item.isNew,
      'isAvailable': item.isAvailable,
      'isActive': item.isActive,
      'sortOrder': item.sortOrder,
      'unitType': item.unitType,
      'sizes': item.sizes,
      'sizePrices': item.sizePrices,
    };
  }

  CartItem? _cartItemFromMap(dynamic value) {
    try {
      if (value is! Map) return null;
      final item = _menuItemFromMap(value['item']);
      if (item == null) return null;

      final quantity = _asDouble(value['quantity']);
      if (quantity <= 0) return null;

      final selectedSize = value['selectedSize']?.toString().trim();
      return CartItem(
        item: item,
        quantity: _normalizeQuantity(item, quantity),
        selectedSize: selectedSize == null || selectedSize.isEmpty
            ? null
            : selectedSize,
      );
    } catch (e) {
      throw StorageException(
        ErrorMessages.withDetails(AppErrorKey.loadCartFromLocalStorage, e),
      );
    }
  }

  MenuItemEntity? _menuItemFromMap(dynamic value) {
    if (value is! Map) return null;

    final id = value['id']?.toString() ?? '';
    if (id.trim().isEmpty) return null;

    final rawImages = value['images'];
    final rawSizes = value['sizes'];

    return MenuItemEntity(
      id: id,
      categoryId: value['categoryId']?.toString() ?? '',
      nameAr: value['nameAr']?.toString() ?? '',
      nameEn: value['nameEn']?.toString() ?? '',
      descriptionAr: value['descriptionAr']?.toString() ?? '',
      descriptionEn: value['descriptionEn']?.toString() ?? '',
      price: _asDouble(value['price']),
      oldPrice: value['oldPrice'] == null ? null : _asDouble(value['oldPrice']),
      imageUrl: value['imageUrl']?.toString() ?? '',
      images: rawImages is List
          ? rawImages.map((item) => item.toString()).toList()
          : const [],
      isPopular: value['isPopular'] == true,
      isNew: value['isNew'] == true,
      isAvailable: value['isAvailable'] != false,
      isActive: value['isActive'] != false,
      sortOrder: _asInt(value['sortOrder']),
      unitType: value['unitType']?.toString() ?? 'piece',
      sizes: rawSizes is List
          ? rawSizes
                .map((item) => item.toString().trim())
                .where((item) => item.isNotEmpty)
                .toList()
          : const [],
      sizePrices: _asDoubleMap(value['sizePrices']),
    );
  }

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString().trim() ?? '') ?? 0.0;
  }

  int _asInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString().trim() ?? '') ?? 0;
  }

  Map<String, double> _asDoubleMap(dynamic value) {
    if (value is! Map) return const {};

    final parsed = <String, double>{};
    for (final entry in value.entries) {
      final key = entry.key.toString().trim();
      if (key.isEmpty) continue;
      parsed[key] = _asDouble(entry.value);
    }
    return parsed;
  }
}
