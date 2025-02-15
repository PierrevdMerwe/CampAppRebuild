// lib/src/auth/providers/user_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? get user => _user;

  // lib/src/auth/providers/user_provider.dart
  Future<void> loadUserData() async {
    final currentUser = _auth.currentUser;
    print('🔍 Current Firebase user: ${currentUser?.uid}');
    if (currentUser == null) {
      print('❌ No Firebase user logged in');
      return;
    }

    // Try to load from SharedPreferences first
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');

    if (userData != null) {
      print('📱 Found cached user data in SharedPreferences');
      _user = UserModel.fromJson(userData);
      print('📱 Cached user: ${_user?.username}, ${_user?.userNumber}');
      notifyListeners();
    }

    // Fetch fresh data from Firestore
    try {
      print('🔄 Fetching fresh data from Firestore for uid: ${currentUser.uid}');
      final userDoc = await _firestore
          .collection('users')
          .where('firebase_uid', isEqualTo: currentUser.uid)
          .get();

      print('📊 Found ${userDoc.docs.length} matching documents');

      if (userDoc.docs.isNotEmpty) {
        final data = userDoc.docs.first.data();
        print('📄 Firestore data: $data');

        _user = UserModel(
          uid: currentUser.uid,
          email: data['email'] ?? '',
          name: data['full_name'] ?? '',
          username: data['username'] ?? '',
          userType: data['user_type'] ?? 'camper',
          createdAt: (data['created_at'] as Timestamp).toDate(),
          userNumber: data['user_number'] ?? '',
        );

        print('👤 Created UserModel: username=${_user?.username}, userNumber=${_user?.userNumber}');

        // Save to SharedPreferences
        await prefs.setString('user_data', _user!.toJson());
        notifyListeners();
      } else {
        print('❌ No matching user document found in Firestore');
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
    }
  }

  Future<void> updateUserProfile({
    required String name,
    required String username,
  }) async {
    try {
      if (_user == null || _auth.currentUser == null) {
        throw 'No user logged in';
      }

      // Check if username is taken by another user
      if (username != _user!.username) {
        final isUnique = await _firestore
            .collection('users')
            .where('username', isEqualTo: username)
            .where('firebase_uid', isNotEqualTo: _auth.currentUser!.uid)
            .get()
            .then((snapshot) => snapshot.docs.isEmpty);

        if (!isUnique) {
          throw 'Username is already taken';
        }
      }

      // Update Firestore
      await _firestore
          .collection('users')
          .where('firebase_uid', isEqualTo: _auth.currentUser!.uid)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.first.reference.update({
            'full_name': name,
            'username': username,
          });
        }
      });

      // Update local user model
      _user = _user!.copyWith(
        name: name,
        username: username,
      );

      // Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', _user!.toJson());

      notifyListeners();
    } catch (e) {
      print('Error updating profile: $e');
      throw e.toString();
    }
  }

  void checkCurrentUser() {
    final currentUser = _auth.currentUser;
    print('🔍 Checking current Firebase user on start: ${currentUser?.uid}');
    if (currentUser != null) {
      print('🔄 Found existing Firebase user, loading data...');
      loadUserData();
    } else {
      print('❌ No Firebase user found on start');
    }
  }

  Future<void> clearUserData() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    notifyListeners();
  }
}