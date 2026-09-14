import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String nameAr;
  final String nameEn;
  final String imageUrl;
  final int sortOrder;
  final bool isActive;

  const Category({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.imageUrl,
    required this.sortOrder,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
    id,
    nameAr,
    nameEn,
    imageUrl,
    sortOrder,
    isActive,
  ];
}
