import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;
import 'package:intl/intl.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _logDebug(String message, {bool isError = false}) {
    final emoji = isError ? '❌' : '✅';
    developer.log('$emoji $message', name: 'FavoriteService');
  }

  /// Get current month and year key (e.g., "march_2025")
  String _getCurrentMonthYearKey() {
    final now = DateTime.now();
    final monthName = DateFormat('MMMM').format(now).toLowerCase();
    final year = now.year;
    return '${monthName}_$year';
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
      final monthYearKey = _getCurrentMonthYearKey();

      // Run as a transaction to ensure atomicity
      await _firestore.runTransaction((transaction) async {
        // First, do all the reads
        final campsiteRef = _firestore.collection('sites').doc(campsiteId);
        final campsiteDoc = await transaction.get(campsiteRef);

        // Now perform all writes
        if (isFavorite) {
          // Remove the campsite from favorites
          savedCampsites.remove(campsiteId);
          transaction.update(userRef, {
            'saved_campsites': savedCampsites,
          });
          _logDebug('Removed campsite $campsiteId from favorites');

          // We don't decrement total_favorites as per requirements
        } else {
          // Add the campsite to favorites
          savedCampsites.add(campsiteId);
          transaction.update(userRef, {
            'saved_campsites': savedCampsites,
          });
          _logDebug('Added campsite $campsiteId to favorites');

          if (campsiteDoc.exists) {
            // Get current favorites data
            Map<String, dynamic> favoritesData = {};
            if (campsiteDoc.data()!.containsKey('favorites') &&
                campsiteDoc.data()!['favorites'] != null) {
              favoritesData = Map<String, dynamic>.from(campsiteDoc.data()!['favorites']);
            }

            // Update the counts
            final currentMonthFavorites = favoritesData[monthYearKey] ?? 0;
            favoritesData[monthYearKey] = currentMonthFavorites + 1;

            // Update the campsite document
            transaction.update(campsiteRef, {
              'favorites': favoritesData,
              'total_favorites': FieldValue.increment(1), // Always increment the total favorites
            });
          }
        }
      });

      // Return the new status
      return !isFavorite;
    } catch (e) {
      _logDebug('Error toggling favorite status: $e', isError: true);
      return false;
    }
  }

  // Get all favorite campsites for the current user
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

  /// Get favorite statistics for a specific campsite
  Future<Map<String, dynamic>> getCampsiteFavoriteStats(String campsiteId) async {
    try {
      final campsiteDoc = await _firestore.collection('sites').doc(campsiteId).get();

      if (!campsiteDoc.exists) {
        throw Exception('Campsite does not exist');
      }

      // Extract favorites data
      Map<String, dynamic> favoritesData = {};
      int totalFavorites = 0;
      List<String> favoritedBy = [];

      if (campsiteDoc.data()!.containsKey('favorites') &&
          campsiteDoc.data()!['favorites'] != null) {
        favoritesData = Map<String, dynamic>.from(campsiteDoc.data()!['favorites']);
      }

      if (campsiteDoc.data()!.containsKey('total_favorites')) {
        totalFavorites = campsiteDoc.data()!['total_favorites'] ?? 0;
      } else {
        // Calculate total if the field doesn't exist
        totalFavorites = favoritesData.values.fold(0, (sum, value) => sum + (value as int));
      }

      if (campsiteDoc.data()!.containsKey('favorited_by') &&
          campsiteDoc.data()!['favorited_by'] != null) {
        favoritedBy = List<String>.from(campsiteDoc.data()!['favorited_by']);
      }

      // Calculate statistics
      final currentMonthFavorites = favoritesData[_getCurrentMonthYearKey()] ?? 0;

      return {
        'monthly_favorites': favoritesData,
        'total_favorites': totalFavorites,
        'current_month_favorites': currentMonthFavorites,
        'favorited_by': favoritedBy,
      };
    } catch (e) {
      _logDebug('Error getting favorite stats: $e', isError: true);
      return {
        'monthly_favorites': {},
        'total_favorites': 0,
        'current_month_favorites': 0,
        'favorited_by': [],
      };
    }
  }
}