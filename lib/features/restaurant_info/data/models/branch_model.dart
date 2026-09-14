import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/branch.dart';

class BranchModel extends Branch {
  const BranchModel({
    required super.id,
    required super.nameAr,
    required super.nameEn,
    required super.phoneNumbers,
    required super.ordersWhatsappNumber,
    required super.locationUrl,
    required super.locationText,
    required super.sortOrder,
    required super.isActive,
  });

  factory BranchModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return BranchModel.fromMap(doc.id, data);
  }

  factory BranchModel.fromMap(String id, Map<String, dynamic> map) {
    return BranchModel(
      id: id,
      nameAr: map['nameAr'] as String? ?? '',
      nameEn: map['nameEn'] as String? ?? '',
      phoneNumbers:
          (map['phoneNumbers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      ordersWhatsappNumber:
          (map['ordersWhatsappNumber'] ?? map['ordersWhatsAppNumber'])
              ?.toString() ??
          '',
      locationUrl: map['locationUrl'] as String? ?? '',
      locationText: map['locationText'] as String? ?? '',
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nameAr': nameAr,
      'nameEn': nameEn,
      'phoneNumbers': phoneNumbers,
      'ordersWhatsappNumber': ordersWhatsappNumber,
      'locationUrl': locationUrl,
      'locationText': locationText,
      'sortOrder': sortOrder,
      'isActive': isActive,
    };
  }
}
