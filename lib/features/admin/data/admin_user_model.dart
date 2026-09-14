import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class AdminUserModel extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final String phone;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  const AdminUserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.phone,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  factory AdminUserModel.fromMap(String uid, Map<String, dynamic> map) {
    return AdminUserModel(
      uid: uid,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      isActive: map['isActive'] as bool? ?? true,
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
      createdBy: map['createdBy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'phone': phone,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
    };
  }

  AdminUserModel copyWith({
    String? email,
    String? displayName,
    String? phone,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return AdminUserModel(
      uid: uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  @override
  List<Object?> get props => [
    uid,
    email,
    displayName,
    phone,
    isActive,
    createdAt,
    updatedAt,
    createdBy,
  ];
}
