// lib/src/auth/services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/auth_utils.dart';
import 'dart:developer' as developer;

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _logDebug(String message, {bool isError = false}) {
    final emoji = isError ? '❌' : '✅';
    developer.log('$emoji $message', name: 'UserService');
  }

  Future<bool> isUsernameUnique(String username) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return querySnapshot.docs.isEmpty;
  }

  Future<void> createUser({
    required String uid,
    required String email,
    required String displayName,
    required String username,
  }) async {
    try {
      _logDebug('📝 Creating new camper in users collection');

      // Format the display name for document ID
      final formattedName = AuthUtils.formatNameForFirestore(displayName);

      // Check if username is unique
      if (!await isUsernameUnique(username)) {
        throw 'Username is already taken';
      }

      // Generate unique user number
      final userNumber = await generateUniqueUserNumber();

      // Create user document with formatted name as ID
      await _firestore.collection('users').doc(formattedName).set({
        'firebase_uid': uid,
        'email': email,
        'full_name': displayName,  // Original name with proper capitalization
        'username': username,
        'user_number': userNumber,
        'created_at': FieldValue.serverTimestamp(),
        'bookings': [],
      });

      _logDebug('✅ Successfully created camper profile');
    } catch (e) {
      _logDebug('Failed to create camper profile: $e', isError: true);
      throw 'Failed to create camper profile: ${e.toString()}';
    }
  }

  Future<String> generateUniqueUserNumber() async {
    String userNumber;
    bool isUnique = false;

    do {
      userNumber = '#${DateTime.now().millisecondsSinceEpoch.toString().substring(7, 13)}';
      final querySnapshot = await _firestore
          .collection('users')
          .where('user_number', isEqualTo: userNumber)
          .get();
      isUnique = querySnapshot.docs.isEmpty;
    } while (!isUnique);

    return userNumber;
  }

  Future<bool> isCamper(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('firebase_uid', isEqualTo: uid)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      _logDebug('Failed to check if user is camper: $e', isError: true);
      return false;
    }
  }
}