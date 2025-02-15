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

  Future<void> loadUserData() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    // Try to load from SharedPreferences first
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');

    if (userData != null) {
      _user = UserModel.fromJson(userData);
      notifyListeners();
    }

    // Fetch fresh data from Firestore
    try {
      final userDoc = await _firestore
          .collection('users')
          .where('firebase_uid', isEqualTo: currentUser.uid)
          .get();

      if (userDoc.docs.isNotEmpty) {
        final data = userDoc.docs.first.data();
        _user = UserModel(
          uid: currentUser.uid,
          email: data['email'] ?? '',
          name: data['full_name'] ?? '',
          username: data['username'] ?? '',
          userType: data['user_type'] ?? 'camper',
          createdAt: (data['created_at'] as Timestamp).toDate(),
        );

        // Save to SharedPreferences
        await prefs.setString('user_data', _user!.toJson());
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> clearUserData() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    notifyListeners();
  }
}