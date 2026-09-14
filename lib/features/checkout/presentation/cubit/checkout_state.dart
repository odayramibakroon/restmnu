import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';

enum CheckoutStatus { initial, loadingLocation, submitting, success, error }

class CheckoutState extends Equatable {
  final String customerName;
  final String phone;
  final String address;
  final String deliveryMapLink;
  final String selectedBranchId;
  final double latitude;
  final double longitude;
  final String formattedAddress;
  final CheckoutStatus status;
  final String? errorMessage;
  final OrderEntity? createdOrder;

  const CheckoutState({
    this.customerName = '',
    this.phone = '',
    this.address = '',
    this.deliveryMapLink = '',
    this.selectedBranchId = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.formattedAddress = '',
    this.status = CheckoutStatus.initial,
    this.errorMessage,
    this.createdOrder,
  });

  bool get hasLocation =>
      (latitude != 0.0 && longitude != 0.0) ||
      deliveryMapLink.trim().isNotEmpty;

  CheckoutState copyWith({
    String? customerName,
    String? phone,
    String? address,
    String? deliveryMapLink,
    String? selectedBranchId,
    double? latitude,
    double? longitude,
    String? formattedAddress,
    CheckoutStatus? status,
    String? errorMessage,
    OrderEntity? createdOrder,
  }) {
    return CheckoutState(
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      deliveryMapLink: deliveryMapLink ?? this.deliveryMapLink,
      selectedBranchId: selectedBranchId ?? this.selectedBranchId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      formattedAddress: formattedAddress ?? this.formattedAddress,
      status: status ?? this.status,
      errorMessage: errorMessage,
      createdOrder: createdOrder ?? this.createdOrder,
    );
  }

  @override
  List<Object?> get props => [
    customerName,
    phone,
    address,
    deliveryMapLink,
    selectedBranchId,
    latitude,
    longitude,
    formattedAddress,
    status,
    errorMessage,
    createdOrder,
  ];
}
