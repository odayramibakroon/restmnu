import 'package:equatable/equatable.dart';

class DeliveryLocationEntity extends Equatable {
  final double latitude;
  final double longitude;
  final String formattedAddress;

  const DeliveryLocationEntity({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
  });

  @override
  List<Object?> get props => [latitude, longitude, formattedAddress];
}

class RestaurantConfig extends Equatable {
  final String storeNameAr;
  final String storeNameEn;
  final String storeDescriptionAr;
  final String storeDescriptionEn;
  final String logoUrl;
  final String whatsappNumber;
  final String supportPhone;
  final String supportEmail;
  final String facebookUrl;
  final String instagramUrl;
  final String tiktokUrl;
  final double defaultDeliveryPrice;
  final DeliveryLocationEntity savedDeliveryLocation;
  final String currency;
  final bool enableDarkMode;
  final DateTime updatedAt;

  const RestaurantConfig({
    required this.storeNameAr,
    required this.storeNameEn,
    required this.storeDescriptionAr,
    required this.storeDescriptionEn,
    required this.logoUrl,
    required this.whatsappNumber,
    required this.supportPhone,
    required this.supportEmail,
    required this.facebookUrl,
    required this.instagramUrl,
    required this.tiktokUrl,
    required this.defaultDeliveryPrice,
    required this.savedDeliveryLocation,
    required this.currency,
    required this.enableDarkMode,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    storeNameAr,
    storeNameEn,
    storeDescriptionAr,
    storeDescriptionEn,
    logoUrl,
    whatsappNumber,
    supportPhone,
    supportEmail,
    facebookUrl,
    instagramUrl,
    tiktokUrl,
    defaultDeliveryPrice,
    savedDeliveryLocation,
    currency,
    enableDarkMode,
    updatedAt,
  ];
}
