import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String name;
  final String email;
  final List<String> preferredSports;
  final DateTime createdAt;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.preferredSports,
    required this.createdAt,
  });

  // Convert Firestore document → UserModel
  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      userId: documentId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      preferredSports:
          List<String>.from(data['preferredSports'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert UserModel → Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'preferredSports': preferredSports,
      'createdAt': createdAt,
    };
  }
}