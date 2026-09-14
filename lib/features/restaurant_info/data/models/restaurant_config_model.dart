import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/restaurant_config.dart';

class DeliveryLocationModel extends DeliveryLocationEntity {
  const DeliveryLocationModel({
    required super.latitude,
    required super.longitude,
    required super.formattedAddress,
  });

  factory DeliveryLocationModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const DeliveryLocationModel(
        latitude: 0,
        longitude: 0,
        formattedAddress: '',
      );
    }
    return DeliveryLocationModel(
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      formattedAddress: map['formattedAddress'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'formattedAddress': formattedAddress,
    };
  }
}

class RestaurantConfigModel extends RestaurantConfig {
  const RestaurantConfigModel({
    required super.storeNameAr,
    required super.storeNameEn,
    required super.storeDescriptionAr,
    required super.storeDescriptionEn,
    required super.logoUrl,
    required super.whatsappNumber,
    required super.supportPhone,
    required super.supportEmail,
    required super.facebookUrl,
    required super.instagramUrl,
    required super.tiktokUrl,
    required super.defaultDeliveryPrice,
    required super.savedDeliveryLocation,
    required super.currency,
    required super.enableDarkMode,
    required super.updatedAt,
  });

  factory RestaurantConfigModel.fromMap(Map<String, dynamic> map) {
    DateTime updatedAtParsed;
    if (map['updatedAt'] is Timestamp) {
      updatedAtParsed = (map['updatedAt'] as Timestamp).toDate();
    } else if (map['updatedAt'] is String) {
      updatedAtParsed = DateTime.tryParse(map['updatedAt']) ?? DateTime.now();
    } else {
      updatedAtParsed = DateTime.now();
    }

    return RestaurantConfigModel(
      storeNameAr: map['storeNameAr'] as String? ?? '',
      storeNameEn: map['storeNameEn'] as String? ?? '',
      storeDescriptionAr: map['storeDescriptionAr'] as String? ?? '',
      storeDescriptionEn: map['storeDescriptionEn'] as String? ?? '',
      logoUrl: map['logoUrl'] as String? ?? '',
      whatsappNumber: map['whatsappNumber'] as String? ?? '',
      supportPhone: map['supportPhone'] as String? ?? '',
      supportEmail: map['supportEmail'] as String? ?? '',
      facebookUrl: map['facebookUrl'] as String? ?? '',
      instagramUrl: map['instagramUrl'] as String? ?? '',
      tiktokUrl: map['tiktokUrl'] as String? ?? '',
      defaultDeliveryPrice:
          (map['defaultDeliveryPrice'] as num?)?.toDouble() ?? 0.0,
      savedDeliveryLocation: DeliveryLocationModel.fromMap(
        map['savedDeliveryLocation'] as Map<String, dynamic>?,
      ),
      currency: map['currency'] as String? ?? '',
      enableDarkMode: map['enableDarkMode'] as bool? ?? false,
      updatedAt: updatedAtParsed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'storeNameAr': storeNameAr,
      'storeNameEn': storeNameEn,
      'storeDescriptionAr': storeDescriptionAr,
      'storeDescriptionEn': storeDescriptionEn,
      'logoUrl': logoUrl,
      'whatsappNumber': whatsappNumber,
      'supportPhone': supportPhone,
      'supportEmail': supportEmail,
      'facebookUrl': facebookUrl,
      'instagramUrl': instagramUrl,
      'tiktokUrl': tiktokUrl,
      'defaultDeliveryPrice': defaultDeliveryPrice,
      'savedDeliveryLocation': {
        'latitude': savedDeliveryLocation.latitude,
        'longitude': savedDeliveryLocation.longitude,
        'formattedAddress': savedDeliveryLocation.formattedAddress,
      },
      'currency': currency,
      'enableDarkMode': enableDarkMode,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
