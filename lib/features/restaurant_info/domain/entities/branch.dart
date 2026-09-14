import 'package:equatable/equatable.dart';

class Branch extends Equatable {
  final String id;
  final String nameAr;
  final String nameEn;
  final List<String> phoneNumbers;
  final String ordersWhatsappNumber;
  final String locationUrl;
  final String locationText;
  final int sortOrder;
  final bool isActive;

  const Branch({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.phoneNumbers,
    required this.ordersWhatsappNumber,
    required this.locationUrl,
    required this.locationText,
    required this.sortOrder,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
    id,
    nameAr,
    nameEn,
    phoneNumbers,
    ordersWhatsappNumber,
    locationUrl,
    locationText,
    sortOrder,
    isActive,
  ];
}
