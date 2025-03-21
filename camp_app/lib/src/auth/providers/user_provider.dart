// lib/src/auth/providers/user_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/profile_icon_service.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? get user => _user;

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

    // Check if user is a site owner first
    try {
      print('🔍 Checking if user is a site owner...');
      final siteOwnerDoc = await _firestore
          .collection('site_owners')
          .where('firebase_uid', isEqualTo: currentUser.uid)
          .get();

      print('📊 Found ${siteOwnerDoc.docs.length} site owner documents');

      // In UserProvider class, update the site owner data mapping:
      if (siteOwnerDoc.docs.isNotEmpty) {
        print('🏕️ Loading site owner data...');
        final data = siteOwnerDoc.docs.first.data();
        print('📄 Site owner data: $data');

        _user = UserModel(
          uid: currentUser.uid,
          email: data['email'] ?? '',
          name: data['campsite_name'] ?? '', // Using campsite_name directly
          username: '', // Not using username for site owners
          userType: 'site_owner',
          createdAt: (data['created_at'] as Timestamp).toDate(),
          userNumber: data['phone'] ?? '',
        );

        print('👤 Created Site Owner UserModel: name=${_user?.name}');
        await prefs.setString('user_data', _user!.toJson());
        notifyListeners();
        return;
      }

      // If not a site owner, check regular users collection
      print('👤 Not a site owner, checking users collection...');
      final userDoc = await _firestore
          .collection('users')
          .where('firebase_uid', isEqualTo: currentUser.uid)
          .get();

      print('📊 Found ${userDoc.docs.length} user documents');

      if (userDoc.docs.isNotEmpty) {
        final data = userDoc.docs.first.data();
        print('📄 User data: $data');

        _user = UserModel(
          uid: currentUser.uid,
          email: data['email'] ?? '',
          name: data['full_name'] ?? '',
          username: data['username'] ?? '',
          userType: 'camper',
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
    String? phone,
  }) async {
    try {
      print('🔄 Starting profile update for user: ${_user?.uid}');

      if (_user == null || _auth.currentUser == null) {
        throw 'No user logged in';
      }

      // Determine collection based on user type
      final isOwner = _user!.userType == 'site_owner';
      final collection = isOwner ? 'site_owners' : 'users';
      print('📁 Updating in collection: $collection');

      if (!isOwner) {
        // Check if username is taken by another user (only for regular users)
        if (username != _user!.username) {
          // MODIFIED: Simplified query to avoid index issues
          final usernameQuery = await _firestore
              .collection('users')
              .where('username', isEqualTo: username)
              .get();

          bool isUnique = true;
          for (var doc in usernameQuery.docs) {
            if (doc['firebase_uid'] != _auth.currentUser!.uid) {
              isUnique = false;
              break;
            }
          }

          if (!isUnique) {
            throw 'Username is already taken';
          }
        }
      }

      // Update Firestore
      await _firestore
          .collection(collection)
          .where('firebase_uid', isEqualTo: _auth.currentUser!.uid)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          print('📝 Updating document in Firestore');
          return snapshot.docs.first.reference.update({
            if (isOwner) 'campsite_name': name else 'full_name': name,
            if (!isOwner) 'username': username,
          });
        }
      });

      // Update local user model
      _user = _user!.copyWith(
        name: name,
        username: isOwner ? name : username,
      );

      // Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', _user!.toJson());

      print('✅ Profile update completed successfully');
      notifyListeners();
    } catch (e) {
      print('❌ Error updating profile: $e');
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
    print('🧹 Clearing user data');
    _user = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');

    // Also clear profile icon cache
    final profileIconService = ProfileIconService();
    await profileIconService.clearProfileIconCache();

    notifyListeners();
  }
}