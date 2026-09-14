import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/error_messages.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/whatsapp_service.dart';
import '../../../../core/storage/local_storage_keys.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/utils/localized_values.dart';
import '../../../../core/utils/whatsapp_message_builder.dart';
import '../../../restaurant_info/domain/entities/restaurant_config.dart';
import '../../../restaurant_info/domain/entities/branch.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../domain/entities/order_entity.dart';
import 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final LocationService locationService;
  final WhatsAppService whatsAppService;
  final LocalStorageService localStorage;

  CheckoutCubit({
    required this.locationService,
    required this.whatsAppService,
    required this.localStorage,
  }) : super(const CheckoutState());

  Future<void> restoreSavedCustomerInfo() async {
    if (isClosed) return;

    try {
      final rawInfo = await localStorage.readString(
        LocalStorageKeys.checkoutInfo,
        errorKey: AppErrorKey.loadCustomerInfoFromLocalStorage,
      );
      if (rawInfo == null || rawInfo.trim().isEmpty) return;

      final decoded = jsonDecode(rawInfo);
      if (decoded is! Map) return;

      emit(
        state.copyWith(
          customerName: decoded['customerName']?.toString() ?? '',
          phone: decoded['phone']?.toString() ?? '',
          address: decoded['address']?.toString() ?? '',
          deliveryMapLink: decoded['deliveryMapLink']?.toString() ?? '',
          latitude: _asDouble(decoded['latitude']),
          longitude: _asDouble(decoded['longitude']),
          formattedAddress: decoded['formattedAddress']?.toString() ?? '',
          status: CheckoutStatus.initial,
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> clearSavedCustomerInfo() async {
    if (isClosed) return;

    try {
      await localStorage.remove(
        LocalStorageKeys.checkoutInfo,
        errorKey: AppErrorKey.clearLocalStorage,
      );
      if (!isClosed) {
        emit(
          state.copyWith(
            customerName: '',
            phone: '',
            address: '',
            deliveryMapLink: '',
            latitude: 0,
            longitude: 0,
            formattedAddress: '',
            status: CheckoutStatus.initial,
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void setCustomerName(String name) {
    if (isClosed) return;
    emit(state.copyWith(customerName: name, status: CheckoutStatus.initial));
  }

  void setPhone(String phone) {
    if (isClosed) return;
    emit(state.copyWith(phone: phone, status: CheckoutStatus.initial));
  }

  void setSelectedBranchId(String branchId) {
    if (isClosed) return;
    emit(
      state.copyWith(
        selectedBranchId: branchId,
        status: CheckoutStatus.initial,
      ),
    );
  }

  void setDeliveryMapLink(String deliveryMapLink) {
    if (isClosed) return;
    emit(
      state.copyWith(
        deliveryMapLink: deliveryMapLink,
        status: CheckoutStatus.initial,
      ),
    );
  }

  Future<void> fetchCurrentLocation() async {
    if (isClosed) return;
    emit(state.copyWith(status: CheckoutStatus.loadingLocation));

    try {
      final loc = await locationService.getCurrentLocation();
      if (isClosed) return;
      emit(
        state.copyWith(
          latitude: loc.latitude,
          longitude: loc.longitude,
          formattedAddress: loc.formattedAddress,
          address: loc.formattedAddress,
          status: CheckoutStatus.initial,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: CheckoutStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> submitOrderAndOpenWhatsApp({
    required List<CartItem> cartItems,
    required double subtotal,
    required double deliveryPrice,
    required double total,
    required RestaurantConfig config,
    required List<Branch> branches,
    required WhatsAppOrderMessageLabels whatsAppLabels,
  }) async {
    if (isClosed) return;
    if (state.status == CheckoutStatus.submitting) return;

    // Validation
    final customerName = state.customerName.trim();
    final phone = state.phone.trim();
    final selectedBranchId = state.selectedBranchId.trim();
    final deliveryMapLink = _normalizeUrl(state.deliveryMapLink);

    final selectedBranch = selectedBranchId.isEmpty
        ? null
        : _findBranchById(branches, selectedBranchId);

    if (customerName.length < 2) {
      emit(
        state.copyWith(
          status: CheckoutStatus.error,
          errorMessage: ErrorMessages.message(
            AppErrorKey.validCustomerNameRequired,
          ),
        ),
      );
      return;
    }

    if (!_isValidPhone(phone)) {
      emit(
        state.copyWith(
          status: CheckoutStatus.error,
          errorMessage: ErrorMessages.message(AppErrorKey.validPhoneRequired),
        ),
      );
      return;
    }

    if (selectedBranch == null) {
      emit(
        state.copyWith(
          status: CheckoutStatus.error,
          errorMessage: ErrorMessages.message(AppErrorKey.selectBranch),
        ),
      );
      return;
    }

    final targetWhatsAppNumber = selectedBranch.ordersWhatsappNumber.trim();
    if (targetWhatsAppNumber.isEmpty) {
      emit(
        state.copyWith(
          status: CheckoutStatus.error,
          errorMessage: ErrorMessages.message(
            AppErrorKey.branchOrdersWhatsappMissing,
          ),
        ),
      );
      return;
    }
    if (!_isValidPhone(targetWhatsAppNumber)) {
      emit(
        state.copyWith(
          status: CheckoutStatus.error,
          errorMessage: ErrorMessages.message(
            AppErrorKey.branchOrdersWhatsappInvalid,
          ),
        ),
      );
      return;
    }

    if (deliveryMapLink.isNotEmpty && !_isValidUrl(deliveryMapLink)) {
      emit(
        state.copyWith(
          status: CheckoutStatus.error,
          errorMessage: ErrorMessages.message(
            AppErrorKey.validLocationLinkRequired,
          ),
        ),
      );
      return;
    }

    if (!state.hasLocation) {
      emit(
        state.copyWith(
          status: CheckoutStatus.error,
          errorMessage: ErrorMessages.message(
            AppErrorKey.deliveryLocationRequired,
          ),
        ),
      );
      return;
    }

    if (cartItems.isEmpty) {
      emit(
        state.copyWith(
          status: CheckoutStatus.error,
          errorMessage: ErrorMessages.message(AppErrorKey.cartEmpty),
        ),
      );
      return;
    }

    final hasInvalidCartItem = cartItems.any(
      (item) =>
          item.quantity <= 0 || !item.item.isActive || !item.item.isAvailable,
    );
    if (hasInvalidCartItem) {
      emit(
        state.copyWith(
          status: CheckoutStatus.error,
          errorMessage: ErrorMessages.message(
            AppErrorKey.cartContainsInvalidItem,
          ),
        ),
      );
      return;
    }

    emit(state.copyWith(status: CheckoutStatus.submitting));

    try {
      final orderId = const Uuid().v4();
      final now = DateTime.now();

      final orderItems = cartItems.map((ci) {
        return OrderItemEntity(
          menuItemId: ci.item.id,
          itemNameAr: ci.item.nameAr,
          itemNameEn: ci.item.nameEn,
          quantity: ci.quantity,
          price: ci.unitPrice,
          total: ci.totalPrice,
          unitType: ci.item.unitType,
          selectedSize: ci.selectedSize,
        );
      }).toList();

      final order = OrderEntity(
        id: orderId,
        customerName: customerName,
        phone: phone,
        address: state.address.trim().isNotEmpty
            ? state.address.trim()
            : (state.formattedAddress.isNotEmpty
                  ? state.formattedAddress
                  : whatsAppLabels.customMapLocation),
        deliveryMapLink: deliveryMapLink,
        branchId: selectedBranch.id,
        branchName: LocalizedValues.select(
          languageCode: whatsAppLabels.languageCode,
          ar: selectedBranch.nameAr,
          en: selectedBranch.nameEn,
        ),
        branchOrdersWhatsappNumber: targetWhatsAppNumber,
        latitude: state.latitude,
        longitude: state.longitude,
        formattedAddress: state.formattedAddress.isNotEmpty
            ? state.formattedAddress
            : (state.address.isNotEmpty
                  ? state.address
                  : whatsAppLabels.customMapLocation),
        items: orderItems,
        subtotal: subtotal,
        shipping: deliveryPrice,
        total: total,
        status: 'pending',
        createdAt: now,
        updatedAt: now,
      );

      // The customer request is sent through WhatsApp only.
      // Orders and customer locations are not persisted in Firestore.
      final whatsappMessage = WhatsAppMessageBuilder.buildOrderMessage(
        order: order,
        config: config,
        labels: whatsAppLabels,
      );

      final didOpenWhatsApp = await whatsAppService.sendOrder(
        phoneNumber: targetWhatsAppNumber,
        message: whatsappMessage,
      );

      if (!didOpenWhatsApp) {
        throw WhatsAppException(
          ErrorMessages.message(AppErrorKey.whatsappOpenOnDeviceFailed),
        );
      }

      if (isClosed) return;
      await _persistCustomerInfo(order);
      emit(state.copyWith(status: CheckoutStatus.success, createdOrder: order));
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: CheckoutStatus.error,
          errorMessage: ErrorMessages.withDetails(AppErrorKey.submitOrder, e),
        ),
      );
    }
  }

  bool _isValidPhone(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    return digitsOnly.length >= 8 && digitsOnly.length <= 15;
  }

  Branch? _findBranchById(List<Branch> branches, String id) {
    for (final branch in branches) {
      if (branch.id == id) return branch;
    }
    return null;
  }

  Future<void> _persistCustomerInfo(OrderEntity order) async {
    try {
      await localStorage.writeString(
        LocalStorageKeys.checkoutInfo,
        jsonEncode({
          'customerName': order.customerName,
          'phone': order.phone,
          'address': order.address,
          'deliveryMapLink': order.deliveryMapLink,
          'latitude': order.latitude,
          'longitude': order.longitude,
          'formattedAddress': order.formattedAddress,
        }),
        errorKey: AppErrorKey.saveCustomerInfoToLocalStorage,
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString().trim() ?? '') ?? 0.0;
  }

  String _normalizeUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return 'https://$trimmed';
  }

  bool _isValidUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  void reset() {
    if (isClosed) return;
    emit(const CheckoutState());
  }
}
