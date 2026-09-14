import 'package:flutter_test/flutter_test.dart';
import 'package:restmnu/core/errors/error_messages.dart';
import 'package:restmnu/core/storage/local_storage_service.dart';
import 'package:restmnu/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:restmnu/features/menu/domain/entities/menu_item.dart';

void main() {
  group('CartCubit', () {
    test('adds items, merges quantities, and calculates totals', () async {
      final cubit = CartCubit(localStorage: _FakeLocalStorageService());
      addTearDown(cubit.close);

      cubit.setDeliveryPrice(15);
      cubit.addItem(_menuItem(price: 20), quantity: 2);
      cubit.addItem(_menuItem(price: 20));

      expect(cubit.state.totalItemCount, 3);
      expect(cubit.state.subtotal, 60);
      expect(cubit.state.deliveryPrice, 15);
      expect(cubit.state.total, 75);
    });

    test('decreasing the final quantity removes the item', () async {
      final cubit = CartCubit(localStorage: _FakeLocalStorageService());
      addTearDown(cubit.close);

      cubit.addItem(_menuItem(price: 20));
      cubit.decreaseQuantity('item_1|');

      expect(cubit.state.isEmpty, isTrue);
      expect(cubit.state.total, 0);
    });

    test('keeps different selected sizes as separate cart lines', () async {
      final cubit = CartCubit(localStorage: _FakeLocalStorageService());
      addTearDown(cubit.close);

      final item = _menuItem(price: 20);
      cubit.addItem(item, selectedSize: 'صغير');
      cubit.addItem(item, selectedSize: 'كبير');

      expect(cubit.state.items, hasLength(2));
      expect(cubit.state.totalItemCount, 2);
    });
  });
}

MenuItemEntity _menuItem({required double price}) {
  return MenuItemEntity(
    id: 'item_1',
    categoryId: 'cat_burgers',
    nameAr: 'برجر',
    nameEn: 'Burger',
    descriptionAr: 'وصف الصنف',
    descriptionEn: 'Item description',
    price: price,
    oldPrice: null,
    imageUrl: '',
    images: const [],
    isPopular: false,
    isNew: false,
    isAvailable: true,
    isActive: true,
    sortOrder: 1,
  );
}

class _FakeLocalStorageService implements LocalStorageService {
  final Map<String, String> _values = {};

  @override
  Future<String?> readString(
    String key, {
    AppErrorKey errorKey = AppErrorKey.loadLocalStorage,
  }) async {
    return _values[key];
  }

  @override
  Future<void> writeString(
    String key,
    String value, {
    AppErrorKey errorKey = AppErrorKey.saveLocalStorage,
  }) async {
    _values[key] = value;
  }

  @override
  Future<void> remove(
    String key, {
    AppErrorKey errorKey = AppErrorKey.clearLocalStorage,
  }) async {
    _values.remove(key);
  }

  @override
  Future<void> removeMany(
    Iterable<String> keys, {
    AppErrorKey errorKey = AppErrorKey.clearLocalStorage,
  }) async {
    for (final key in keys) {
      _values.remove(key);
    }
  }
}
