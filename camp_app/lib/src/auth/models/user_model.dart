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
  final String userNumber;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.username,
    required this.userType,
    required this.createdAt,
    this.bookings = const [],
    required this.userNumber,
  });

  // In user_model.dart, add this method:
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? username,
    String? userType,
    DateTime? createdAt,
    List<String>? bookings,
    String? userNumber,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      username: username ?? this.username,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
      bookings: bookings ?? this.bookings,
      userNumber: userNumber ?? this.userNumber,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'username': username,
      'userType': userType,
      'createdAt': createdAt.toIso8601String(),
      'bookings': bookings,
      'userNumber': userNumber,
    };
  }

  // Fix in UserModel.fromMap method in user_model.dart
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      userType: map['userType'] ?? 'camper',
      createdAt: DateTime.parse(map['createdAt']),
      bookings: List<String>.from(map['bookings'] ?? []),
      userNumber: map['userNumber'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));
}