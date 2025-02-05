class UserModel {
  final String uid;
  final String email;
  final String name;
  final String userType;
  final DateTime createdAt;
  final List<String> bookings;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.userType,
    required this.createdAt,
    this.bookings = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'userType': userType,
      'createdAt': createdAt,
      'bookings': bookings,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      userType: map['userType'] ?? 'camper',
      createdAt: (map['createdAt'] as DateTime?) ?? DateTime.now(),
      bookings: List<String>.from(map['bookings'] ?? []),
    );
  }
}