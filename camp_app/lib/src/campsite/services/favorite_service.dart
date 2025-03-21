import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _logDebug(String message, {bool isError = false}) {
    final emoji = isError ? '❌' : '✅';
    developer.log('$emoji $message', name: 'FavoriteService');
  }

  // Check if a campsite is saved as a favorite
  Future<bool> isCampsiteFavorite(String campsiteId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      // Find the user document
      final userDoc = await _firestore
          .collection('users')
          .where('firebase_uid', isEqualTo: currentUser.uid)
          .get();

      if (userDoc.docs.isEmpty) return false;

      // Check if the campsite is in the saved_campsites array
      final userData = userDoc.docs.first.data();
      if (!userData.containsKey('saved_campsites')) return false;

      final savedCampsites = List<String>.from(userData['saved_campsites'] ?? []);
      return savedCampsites.contains(campsiteId);
    } catch (e) {
      _logDebug('Error checking if campsite is favorite: $e', isError: true);
      return false;
    }
  }

  // Toggle favorite status for a campsite
  Future<bool> toggleFavorite(String campsiteId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      // Find the user document
      final userDoc = await _firestore
          .collection('users')
          .where('firebase_uid', isEqualTo: currentUser.uid)
          .get();

      if (userDoc.docs.isEmpty) return false;

      final userRef = userDoc.docs.first.reference;
      final userData = userDoc.docs.first.data();

      // Get the current saved campsites or create an empty array
      final savedCampsites = List<String>.from(userData['saved_campsites'] ?? []);

      bool isFavorite = savedCampsites.contains(campsiteId);

      if (isFavorite) {
        // Remove the campsite from favorites
        savedCampsites.remove(campsiteId);
        _logDebug('Removed campsite $campsiteId from favorites');
      } else {
        // Add the campsite to favorites
        savedCampsites.add(campsiteId);
        _logDebug('Added campsite $campsiteId to favorites');
      }

      // Update the user document
      await userRef.update({
        'saved_campsites': savedCampsites,
      });

      // Return the new status
      return !isFavorite;
    } catch (e) {
      _logDebug('Error toggling favorite status: $e', isError: true);
      return false;
    }
  }

  // Get all favorite campsites
  Future<List<String>> getFavoriteCampsites() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      // Find the user document
      final userDoc = await _firestore
          .collection('users')
          .where('firebase_uid', isEqualTo: currentUser.uid)
          .get();

      if (userDoc.docs.isEmpty) return [];

      // Get the saved campsites
      final userData = userDoc.docs.first.data();
      if (!userData.containsKey('saved_campsites')) return [];

      return List<String>.from(userData['saved_campsites'] ?? []);
    } catch (e) {
      _logDebug('Error getting favorite campsites: $e', isError: true);
      return [];
    }
  }
}