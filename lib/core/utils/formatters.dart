import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String formatPrice(double price, {String currency = ''}) {
    final formatter = NumberFormat('#,##0.##', 'ar');
    final formattedPrice = formatter.format(price);
    return currency.trim().isEmpty
        ? formattedPrice
        : '$formattedPrice $currency';
  }

  static String formatQuantity(double quantity, {bool isWeight = false}) {
    if (!isWeight) return quantity.round().toString();

    final normalized = (quantity * 1000).round() / 1000;
    if (normalized > 0 && normalized < 1) {
      return normalized.toStringAsFixed(3);
    }

    return normalized.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  static String formatShortDate(DateTime dateTime) {
    final formatter = DateFormat('yyyy/MM/dd - hh:mm a', 'ar');
    return formatter.format(dateTime);
  }
}
