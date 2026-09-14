import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item.dart';

class CartState extends Equatable {
  final List<CartItem> items;
  final double deliveryPrice;

  const CartState({this.items = const [], this.deliveryPrice = 10.0});

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  int get totalItemCount => items.fold(
    0,
    (count, item) =>
        count + (item.item.isSoldByWeight ? 1 : item.quantity.round()),
  );

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get total => isEmpty ? 0.0 : (subtotal + deliveryPrice);

  CartState copyWith({List<CartItem>? items, double? deliveryPrice}) {
    return CartState(
      items: items ?? this.items,
      deliveryPrice: deliveryPrice ?? this.deliveryPrice,
    );
  }

  @override
  List<Object?> get props => [items, deliveryPrice];
}
