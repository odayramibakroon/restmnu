import 'package:equatable/equatable.dart';
import '../../../menu/domain/entities/menu_item.dart';

class CartItem extends Equatable {
  final MenuItemEntity item;
  final double quantity;
  final String? selectedSize;

  const CartItem({
    required this.item,
    required this.quantity,
    this.selectedSize,
  });

  String get key => '${item.id}|${selectedSize ?? ''}';

  double get unitPrice => item.priceForSize(selectedSize);

  double get totalPrice => unitPrice * quantity;

  CartItem copyWith({
    MenuItemEntity? item,
    double? quantity,
    String? selectedSize,
  }) {
    return CartItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
    );
  }

  @override
  List<Object?> get props => [item, quantity, selectedSize];
}
