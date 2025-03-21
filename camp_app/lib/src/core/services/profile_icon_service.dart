// Enhanced ProfileIconService with SharedPreferences caching

import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProfileIconService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // SharedPreferences key
  static const String _profileIconKey = 'profile_icon_data';

  // List of pastel colors for profile icon backgrounds
  final List<Color> _pastelColors = [
    const Color(0xFFC7CEEA), // Soft Blue
    const Color(0xFFFEDAD6), // Soft Pink
    const Color(0xFFB5EAD7), // Soft Green
    const Color(0xFFFFDFD3), // Soft Peach
    const Color(0xFFFFE7D6), // Soft Orange
    const Color(0xFFE2F0CB), // Soft Lime
    const Color(0xFFD5C2EF), // Soft Purple
    const Color(0xFFF0DBDB), // Soft Mauve
    const Color(0xFFD1E3DD), // Soft Aqua
    const Color(0xFFFDF5C9), // Soft Yellow
  ];

  // List of outdoors/camping related Font Awesome icons
  final List<Map<String, dynamic>> _campingIcons = [
    {'name': 'tent', 'icon': FontAwesomeIcons.tent},
    {'name': 'tree', 'icon': FontAwesomeIcons.tree},
    {'name': 'campground', 'icon': FontAwesomeIcons.campground},
    {'name': 'fire', 'icon': FontAwesomeIcons.fire},
    {'name': 'mountain', 'icon': FontAwesomeIcons.mountain},
    {'name': 'compass', 'icon': FontAwesomeIcons.compass},
    {'name': 'shuttle-van', 'icon': FontAwesomeIcons.shuttleVan},
    {'name': 'hiking', 'icon': FontAwesomeIcons.personHiking},
    {'name': 'water', 'icon': FontAwesomeIcons.water},
    {'name': 'fish', 'icon': FontAwesomeIcons.fish},
    {'name': 'caravan', 'icon': FontAwesomeIcons.caravan},
    {'name': 'binoculars', 'icon': FontAwesomeIcons.binoculars},
  ];

  // Generate a random profile icon
  Map<String, dynamic> generateRandomProfileIcon() {
    final random = Random();

    // Select a random color and icon
    final Color backgroundColor = _pastelColors[random.nextInt(_pastelColors.length)];
    final Map<String, dynamic> iconData = _campingIcons[random.nextInt(_campingIcons.length)];

    // Convert color to hex string for storage
    final String backgroundHex = backgroundColor.value.toRadixString(16).padLeft(8, '0');

    return {
      'background': backgroundHex,
      'icon': iconData['name'],
    };
  }

  // Save profile icon data to SharedPreferences
  Future<void> _saveProfileIconToCache(String userId, Map<String, dynamic> profileIcon) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonData = json.encode({
        'userId': userId,
        'profileIcon': profileIcon,
      });

      await prefs.setString(_profileIconKey, jsonData);
      print('✅ Saved profile icon to SharedPreferences cache');
    } catch (e) {
      print('❌ Error saving profile icon to cache: $e');
    }
  }

  // Get profile icon data from SharedPreferences
  Future<Map<String, dynamic>?> _getProfileIconFromCache(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonData = prefs.getString(_profileIconKey);

      if (jsonData != null) {
        final Map<String, dynamic> data = json.decode(jsonData);

        // Only return if the cached data is for the current user
        if (data['userId'] == userId) {
          print('✅ Retrieved profile icon from SharedPreferences cache');
          return data['profileIcon'];
        }
      }

      return null;
    } catch (e) {
      print('❌ Error getting profile icon from cache: $e');
      return null;
    }
  }

  // Assign a random profile icon to a user
  Future<void> assignRandomProfileIcon(String userId, {String? userType}) async {
    try {
      // Generate a random profile icon
      final profileIcon = generateRandomProfileIcon();

      // Determine the collection based on user type
      final collection = userType == 'site_owner' ? 'site_owners' : 'users';

      // Find the user's document
      final userDocs = await _firestore
          .collection(collection)
          .where('firebase_uid', isEqualTo: userId)
          .get();

      if (userDocs.docs.isNotEmpty) {
        // Update the user's document with the profile icon
        await userDocs.docs.first.reference.update({
          'profile': profileIcon,
        });

        // Save to SharedPreferences cache
        await _saveProfileIconToCache(userId, profileIcon);

        print('✅ Assigned random profile icon to user: $userId');
      } else {
        print('❌ User document not found for ID: $userId');
      }
    } catch (e) {
      print('❌ Error assigning random profile icon: $e');
    }
  }

  // Get the user's profile icon (with caching)
  Future<Map<String, dynamic>?> getUserProfileIcon() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // First try to get from SharedPreferences cache
      final cachedIcon = await _getProfileIconFromCache(user.uid);
      if (cachedIcon != null) {
        return cachedIcon;
      }

      print('🔍 No cache found, fetching from Firestore...');

      // Check in users collection
      var userDoc = await _firestore
          .collection('users')
          .where('firebase_uid', isEqualTo: user.uid)
          .get();

      if (userDoc.docs.isNotEmpty && userDoc.docs.first.data().containsKey('profile')) {
        final profileIcon = userDoc.docs.first.data()['profile'] as Map<String, dynamic>;
        // Save to cache for future use
        await _saveProfileIconToCache(user.uid, profileIcon);
        return profileIcon;
      }

      // Check in site_owners collection
      userDoc = await _firestore
          .collection('site_owners')
          .where('firebase_uid', isEqualTo: user.uid)
          .get();

      if (userDoc.docs.isNotEmpty && userDoc.docs.first.data().containsKey('profile')) {
        final profileIcon = userDoc.docs.first.data()['profile'] as Map<String, dynamic>;
        // Save to cache for future use
        await _saveProfileIconToCache(user.uid, profileIcon);
        return profileIcon;
      }

      // If no profile icon is found, generate and assign a new one
      final profileIcon = generateRandomProfileIcon();

      // Try to determine user type
      String? userType;
      if (await _firestore
          .collection('site_owners')
          .where('firebase_uid', isEqualTo: user.uid)
          .get()
          .then((value) => value.docs.isNotEmpty)) {
        userType = 'site_owner';
      }

      // Assign the new icon
      await assignRandomProfileIcon(user.uid, userType: userType);

      // Also cache it
      await _saveProfileIconToCache(user.uid, profileIcon);

      return profileIcon;
    } catch (e) {
      print('❌ Error getting user profile icon: $e');
      return null;
    }
  }

  // Clear the cached profile icon (useful when logging out)
  Future<void> clearProfileIconCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileIconKey);
      print('✅ Cleared profile icon cache');
    } catch (e) {
      print('❌ Error clearing profile icon cache: $e');
    }
  }

  // Get the FontAwesomeIcon based on icon name
  IconData getIconData(String iconName) {
    for (var icon in _campingIcons) {
      if (icon['name'] == iconName) {
        return icon['icon'];
      }
    }

    // Default to tent if icon name not found
    return FontAwesomeIcons.tent;
  }
}