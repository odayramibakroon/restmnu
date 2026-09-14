import '../../features/checkout/domain/entities/order_entity.dart';
import '../../features/restaurant_info/domain/entities/restaurant_config.dart';
import 'formatters.dart';
import 'localized_values.dart';

class WhatsAppOrderMessageLabels {
  final String languageCode;
  final String newOrderFrom;
  final String referenceNumber;
  final String selectedBranch;
  final String customerInfo;
  final String customerName;
  final String customerPhone;
  final String deliveryLocation;
  final String address;
  final String notSet;
  final String customMapLocation;
  final String currentLocationLink;
  final String sentMapLink;
  final String orderDetails;
  final String kiloUnit;
  final String pieceUnit;
  final String kiloShort;
  final String sizeLabel;
  final String itemType;
  final String quantity;
  final String subtotal;
  final String deliveryPrice;
  final String finalTotal;
  final String thanksForChoosing;

  const WhatsAppOrderMessageLabels({
    required this.languageCode,
    required this.newOrderFrom,
    required this.referenceNumber,
    required this.selectedBranch,
    required this.customerInfo,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryLocation,
    required this.address,
    required this.notSet,
    required this.customMapLocation,
    required this.currentLocationLink,
    required this.sentMapLink,
    required this.orderDetails,
    required this.kiloUnit,
    required this.pieceUnit,
    required this.kiloShort,
    required this.sizeLabel,
    required this.itemType,
    required this.quantity,
    required this.subtotal,
    required this.deliveryPrice,
    required this.finalTotal,
    required this.thanksForChoosing,
  });
}

class WhatsAppMessageBuilder {
  WhatsAppMessageBuilder._();

  static String buildOrderMessage({
    required OrderEntity order,
    required RestaurantConfig config,
    required WhatsAppOrderMessageLabels labels,
  }) {
    final buffer = StringBuffer();
    final storeName = LocalizedValues.select(
      languageCode: labels.languageCode,
      ar: config.storeNameAr,
      en: config.storeNameEn,
    );

    buffer.writeln('🍽️ *${labels.newOrderFrom} $storeName*');
    buffer.writeln(
      '🔖 *${labels.referenceNumber}:* #${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
    );
    if (order.branchName.isNotEmpty) {
      buffer.writeln('🏬 *${labels.selectedBranch}:* ${order.branchName}');
    }
    buffer.writeln('--------------------------------');
    buffer.writeln('👤 *${labels.customerInfo}:*');
    buffer.writeln('• ${labels.customerName}: ${order.customerName}');
    buffer.writeln('• ${labels.customerPhone}: ${order.phone}');
    buffer.writeln('📍 *${labels.deliveryLocation}:*');
    buffer.writeln(
      '• ${labels.address}: ${order.formattedAddress.isNotEmpty ? order.formattedAddress : (order.address.isNotEmpty ? order.address : labels.notSet)}',
    );
    if (order.latitude != 0.0 && order.longitude != 0.0) {
      buffer.writeln(
        '• ${labels.currentLocationLink}: https://maps.google.com/?q=${order.latitude},${order.longitude}',
      );
    }
    if (order.deliveryMapLink.isNotEmpty) {
      buffer.writeln('• ${labels.sentMapLink}: ${order.deliveryMapLink}');
    }
    buffer.writeln('--------------------------------');
    buffer.writeln('📋 *${labels.orderDetails}:*');

    for (int i = 0; i < order.items.length; i++) {
      final item = order.items[i];
      final isWeight = item.unitType == 'weight';
      final unitLabel = isWeight ? labels.kiloUnit : labels.pieceUnit;
      final quantityLabel = Formatters.formatQuantity(
        item.quantity,
        isWeight: isWeight,
      );
      final quantityUnit = isWeight ? ' ${labels.kiloShort}' : '';
      final sizeLabel = item.selectedSize == null || item.selectedSize!.isEmpty
          ? ''
          : ' - ${labels.sizeLabel}: ${item.selectedSize}';
      final itemName = LocalizedValues.select(
        languageCode: labels.languageCode,
        ar: item.itemNameAr,
        en: item.itemNameEn,
      );
      buffer.writeln('${i + 1}. *$itemName*');
      buffer.writeln('   ${labels.itemType}: $unitLabel$sizeLabel');
      buffer.writeln(
        '   ${labels.quantity}: $quantityLabel$quantityUnit × ${item.price.toStringAsFixed(2)} ${config.currency} = *${item.total.toStringAsFixed(2)} ${config.currency}*',
      );
    }

    buffer.writeln('--------------------------------');
    buffer.writeln(
      '💵 *${labels.subtotal}:* ${order.subtotal.toStringAsFixed(2)} ${config.currency}',
    );
    if (order.shipping > 0) {
      buffer.writeln(
        '🚗 *${labels.deliveryPrice}:* ${order.shipping.toStringAsFixed(2)} ${config.currency}',
      );
    }
    buffer.writeln(
      '💰 *${labels.finalTotal}:* *${order.total.toStringAsFixed(2)} ${config.currency}*',
    );
    buffer.writeln('--------------------------------');
    buffer.writeln('${labels.thanksForChoosing} $storeName 🙏');

    return buffer.toString();
  }
}
