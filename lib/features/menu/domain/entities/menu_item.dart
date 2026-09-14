import 'package:equatable/equatable.dart';

class MenuItemEntity extends Equatable {
  final String id;
  final String categoryId;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final double price;
  final double? oldPrice;
  final String imageUrl;
  final List<String> images;
  final bool isPopular;
  final bool isNew;
  final bool isAvailable;
  final bool isActive;
  final int sortOrder;
  final String unitType;
  final List<String> sizes;
  final Map<String, double> sizePrices;

  const MenuItemEntity({
    required this.id,
    required this.categoryId,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.price,
    this.oldPrice,
    required this.imageUrl,
    required this.images,
    required this.isPopular,
    required this.isNew,
    required this.isAvailable,
    required this.isActive,
    required this.sortOrder,
    this.unitType = 'piece',
    this.sizes = const [],
    this.sizePrices = const {},
  });

  bool get hasDiscount => oldPrice != null && oldPrice! > price;
  bool get isSoldByWeight => unitType == 'weight';

  double get displayPrice {
    if (sizes.isEmpty) return price;

    for (final size in sizes) {
      final sizePrice = sizePrices[size];
      if (sizePrice != null) return sizePrice;
    }

    return price;
  }

  double priceForSize(String? selectedSize) {
    final normalizedSize = selectedSize?.trim() ?? '';
    if (normalizedSize.isEmpty) return displayPrice;
    return sizePrices[normalizedSize] ?? price;
  }

  @override
  List<Object?> get props => [
    id,
    categoryId,
    nameAr,
    nameEn,
    descriptionAr,
    descriptionEn,
    price,
    oldPrice,
    imageUrl,
    images,
    isPopular,
    isNew,
    isAvailable,
    isActive,
    sortOrder,
    unitType,
    sizes,
    sizePrices,
  ];
}
