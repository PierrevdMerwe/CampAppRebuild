import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

class RatingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _logDebug(String message, {bool isError = false}) {
    final emoji = isError ? '❌' : '✅';
    developer.log('$emoji $message', name: 'RatingService');
  }

  /// Check if the current user has already rated this campsite
  Future<bool> hasUserRatedCampsite(String campsiteId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      // Find the user document
      final userDoc = await _firestore
          .collection('users')
          .where('firebase_uid', isEqualTo: currentUser.uid)
          .get();

      if (userDoc.docs.isEmpty) return false;

      // Check if the user has comments for this campsite
      final userData = userDoc.docs.first.data();
      if (!userData.containsKey('comments')) return false;

      final comments = userData['comments'] as Map<String, dynamic>?;
      if (comments == null) return false;

      return comments.containsKey(campsiteId);
    } catch (e) {
      _logDebug('Error checking if user rated campsite: $e', isError: true);
      return false;
    }
  }

  /// Add a rating and comment for a campsite
  Future<bool> rateCampsite(String campsiteId, int rating, String comment) async {
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

      // Prepare the comments field if it doesn't exist
      Map<String, dynamic> comments = {};
      if (userData.containsKey('comments') && userData['comments'] != null) {
        comments = Map<String, dynamic>.from(userData['comments']);
      }

      // Add the new comment for this campsite
      comments[campsiteId] = {
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Update the user document with the new comment
      await userRef.update({
        'comments': comments,
      });

      // Update the campsite document to add this user's ID to its comments array
      final campsiteRef = _firestore.collection('sites').doc(campsiteId);

      // Atomically add the user ID to the campsite's comments array if it doesn't exist already
      await _firestore.runTransaction((transaction) async {
        final campsiteDoc = await transaction.get(campsiteRef);

        if (!campsiteDoc.exists) {
          throw Exception('Campsite does not exist');
        }

        List<String> commentUserIds = [];
        if (campsiteDoc.data()!.containsKey('comments') && campsiteDoc.data()!['comments'] != null) {
          commentUserIds = List<String>.from(campsiteDoc.data()!['comments']);
        }

        if (!commentUserIds.contains(currentUser.uid)) {
          commentUserIds.add(currentUser.uid);
          transaction.update(campsiteRef, {
            'comments': commentUserIds,
          });
        }
      });

      _logDebug('✅ Successfully added rating for campsite: $campsiteId');
      return true;
    } catch (e) {
      _logDebug('Error rating campsite: $e', isError: true);
      return false;
    }
  }

  /// Get all comments for a campsite
  Future<List<Map<String, dynamic>>> getCampsiteComments(String campsiteId) async {
    try {
      // Get the campsite document to get the list of user IDs who commented
      final campsiteDoc = await _firestore.collection('sites').doc(campsiteId).get();

      if (!campsiteDoc.exists || !campsiteDoc.data()!.containsKey('comments')) {
        return [];
      }

      final List<String> commentUserIds = List<String>.from(campsiteDoc.data()!['comments']);

      if (commentUserIds.isEmpty) {
        return [];
      }

      // For each user ID, get their comment data
      List<Map<String, dynamic>> comments = [];

      // Process in batches to avoid hitting Firestore limits
      List<List<String>> batches = [];
      for (var i = 0; i < commentUserIds.length; i += 10) {
        batches.add(
            commentUserIds.sublist(
                i, i + 10 > commentUserIds.length ? commentUserIds.length : i + 10
            )
        );
      }

      for (var batch in batches) {
        // Query for users in this batch
        final usersSnapshot = await _firestore
            .collection('users')
            .where('firebase_uid', whereIn: batch)
            .get();

        for (var userDoc in usersSnapshot.docs) {
          final userData = userDoc.data();
          final userId = userData['firebase_uid'];

          if (userData.containsKey('comments') &&
              userData['comments'] != null &&
              userData['comments'][campsiteId] != null) {

            final commentData = userData['comments'][campsiteId];

            comments.add({
              'userId': userId,
              'username': userData['username'] ?? 'Anonymous',
              'userNumber': userData['user_number'] ?? '',
              'profile': userData['profile'],
              'rating': commentData['rating'] ?? 0,
              'comment': commentData['comment'] ?? '',
              'createdAt': commentData['createdAt'] ?? Timestamp.now(),
            });
          }
        }
      }

      // Sort comments by creation date (newest first)
      comments.sort((a, b) {
        final aTime = a['createdAt'] as Timestamp;
        final bTime = b['createdAt'] as Timestamp;
        return bTime.compareTo(aTime);
      });

      return comments;
    } catch (e) {
      _logDebug('Error getting campsite comments: $e', isError: true);
      return [];
    }
  }

  /// Get the current user's rating for a campsite
  Future<Map<String, dynamic>?> getUserRating(String campsiteId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      // Find the user document
      final userDoc = await _firestore
          .collection('users')
          .where('firebase_uid', isEqualTo: currentUser.uid)
          .get();

      if (userDoc.docs.isEmpty) return null;

      // Check if the user has comments for this campsite
      final userData = userDoc.docs.first.data();
      if (!userData.containsKey('comments')) return null;

      final comments = userData['comments'] as Map<String, dynamic>?;
      if (comments == null || !comments.containsKey(campsiteId)) return null;

      return {
        'rating': comments[campsiteId]['rating'] ?? 0,
        'comment': comments[campsiteId]['comment'] ?? '',
      };
    } catch (e) {
      _logDebug('Error getting user rating: $e', isError: true);
      return null;
    }
  }

  /// Calculate average rating for a campsite
  Future<double> getCampsiteAverageRating(String campsiteId) async {
    try {
      final comments = await getCampsiteComments(campsiteId);

      if (comments.isEmpty) return 0.0;

      final totalRating = comments.fold(0, (sum, comment) => sum + (comment['rating'] as int));
      return totalRating / comments.length;
    } catch (e) {
      _logDebug('Error calculating average rating: $e', isError: true);
      return 0.0;
    }
  }
}