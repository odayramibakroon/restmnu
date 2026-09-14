import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/menu_item.dart';

class MenuItemModel extends MenuItemEntity {
  const MenuItemModel({
    required super.id,
    required super.categoryId,
    required super.nameAr,
    required super.nameEn,
    required super.descriptionAr,
    required super.descriptionEn,
    required super.price,
    super.oldPrice,
    required super.imageUrl,
    required super.images,
    required super.isPopular,
    required super.isNew,
    required super.isAvailable,
    required super.isActive,
    required super.sortOrder,
    super.unitType,
    super.sizes,
    super.sizePrices,
  });

  factory MenuItemModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MenuItemModel.fromMap(doc.id, data);
  }

  factory MenuItemModel.fromMap(String id, Map<String, dynamic> map) {
    final sizes =
        (map['sizes'] as List<dynamic>?)
            ?.map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList() ??
        [];

    return MenuItemModel(
      id: id,
      categoryId: map['categoryId'] as String? ?? '',
      nameAr: map['nameAr'] as String? ?? '',
      nameEn: map['nameEn'] as String? ?? '',
      descriptionAr: map['descriptionAr'] as String? ?? '',
      descriptionEn: map['descriptionEn'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      oldPrice: (map['oldPrice'] as num?)?.toDouble(),
      imageUrl: map['imageUrl'] as String? ?? '',
      images:
          (map['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (map['imageUrl'] != null && (map['imageUrl'] as String).isNotEmpty
              ? [map['imageUrl'] as String]
              : []),
      isPopular: map['isPopular'] as bool? ?? false,
      isNew: map['isNew'] as bool? ?? false,
      isAvailable: map['isAvailable'] as bool? ?? true,
      isActive: map['isActive'] as bool? ?? true,
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
      unitType: map['unitType'] as String? ?? 'piece',
      sizes: sizes,
      sizePrices: _parseSizePrices(map['sizePrices']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'descriptionAr': descriptionAr,
      'descriptionEn': descriptionEn,
      'price': price,
      'oldPrice': oldPrice,
      'imageUrl': imageUrl,
      'images': images,
      'isPopular': isPopular,
      'isNew': isNew,
      'isAvailable': isAvailable,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'unitType': unitType,
      'sizes': sizes,
      'sizePrices': sizePrices,
    };
  }

  static Map<String, double> _parseSizePrices(dynamic value) {
    if (value is! Map) return const {};

    final parsed = <String, double>{};
    for (final entry in value.entries) {
      final size = entry.key.toString().trim();
      if (size.isEmpty) continue;

      final rawPrice = entry.value;
      final price = rawPrice is num
          ? rawPrice.toDouble()
          : double.tryParse(rawPrice.toString().trim().replaceAll(',', '.'));
      if (price != null) parsed[size] = price;
    }

    return parsed;
  }
}
