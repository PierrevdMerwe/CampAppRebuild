// lib/src/auth/models/user_model.dart
import 'dart:convert';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String username;
  final String userType;
  final DateTime createdAt;
  final List<String> bookings;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.username,
    required this.userType,
    required this.createdAt,
    this.bookings = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'username': username,
      'userType': userType,
      'createdAt': createdAt.toIso8601String(),
      'bookings': bookings,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      userType: map['userType'] ?? 'camper',
      createdAt: DateTime.parse(map['createdAt']),
      bookings: List<String>.from(map['bookings'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));
}