import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final String menuItemId;
  final String itemNameAr;
  final String itemNameEn;
  final double quantity;
  final double price;
  final double total;
  final String unitType;
  final String? selectedSize;

  const OrderItemEntity({
    required this.menuItemId,
    required this.itemNameAr,
    required this.itemNameEn,
    required this.quantity,
    required this.price,
    required this.total,
    this.unitType = 'piece',
    this.selectedSize,
  });

  @override
  List<Object?> get props => [
    menuItemId,
    itemNameAr,
    itemNameEn,
    quantity,
    price,
    total,
    unitType,
    selectedSize,
  ];
}

class OrderEntity extends Equatable {
  final String id;
  final String customerName;
  final String phone;
  final String address;
  final String deliveryMapLink;
  final String branchId;
  final String branchName;
  final String branchOrdersWhatsappNumber;
  final double latitude;
  final double longitude;
  final String formattedAddress;
  final List<OrderItemEntity> items;
  final double subtotal;
  final double shipping;
  final double total;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderEntity({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.deliveryMapLink,
    required this.branchId,
    required this.branchName,
    required this.branchOrdersWhatsappNumber,
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    customerName,
    phone,
    address,
    deliveryMapLink,
    branchId,
    branchName,
    branchOrdersWhatsappNumber,
    latitude,
    longitude,
    formattedAddress,
    items,
    subtotal,
    shipping,
    total,
    status,
    createdAt,
    updatedAt,
  ];
}
