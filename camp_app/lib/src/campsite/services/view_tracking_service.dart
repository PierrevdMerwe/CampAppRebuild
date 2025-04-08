import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import 'package:intl/intl.dart';

class ViewTrackingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _logDebug(String message, {bool isError = false}) {
    final emoji = isError ? '❌' : '✅';
    developer.log('$emoji $message', name: 'ViewTrackingService');
  }

  /// Get current month and year key (e.g., "march_2025")
  String _getCurrentMonthYearKey() {
    final now = DateTime.now();
    final monthName = DateFormat('MMMM').format(now).toLowerCase();
    final year = now.year;
    return '${monthName}_$year';
  }

  /// Increment the view count for a campsite
  Future<void> incrementViewCount(String campsiteId) async {
    try {
      _logDebug('Incrementing view count for campsite: $campsiteId');

      final campsiteRef = _firestore.collection('sites').doc(campsiteId);
      final monthYearKey = _getCurrentMonthYearKey();

      // Use a transaction to ensure atomic update
      await _firestore.runTransaction((transaction) async {
        // Get the current campsite data
        final campsiteDoc = await transaction.get(campsiteRef);

        if (!campsiteDoc.exists) {
          throw Exception('Campsite does not exist');
        }

        // Set up the views field structure if it doesn't exist
        Map<String, dynamic> viewsData = {};
        if (campsiteDoc.data()!.containsKey('views')) {
          // Handle both cases: views as a map or views as an integer (legacy data)
          final existingViews = campsiteDoc.data()!['views'];
          if (existingViews is Map) {
            viewsData = Map<String, dynamic>.from(existingViews);
          } else if (existingViews is int) {
            // If views is an integer (old format), initialize the new format
            viewsData = {
              'total_legacy': existingViews
            };
          }
        }

        // Increment the view count for the current month/year
        final currentMonthViews = viewsData[monthYearKey] ?? 0;
        viewsData[monthYearKey] = currentMonthViews + 1;

        // Update the document
        transaction.update(campsiteRef, {
          'views': viewsData,
          'total_views': FieldValue.increment(1),
        });
      });

      _logDebug('✅ Successfully incremented view count');
    } catch (e) {
      _logDebug('Error incrementing view count: $e', isError: true);
    }
  }

  /// Get view statistics for a specific campsite
  Future<Map<String, dynamic>> getCampsiteViewStats(String campsiteId) async {
    try {
      final campsiteDoc = await _firestore.collection('sites').doc(campsiteId).get();

      if (!campsiteDoc.exists) {
        throw Exception('Campsite does not exist');
      }

      // Extract views data
      Map<String, dynamic> viewsData = {};
      int totalViews = 0;

      if (campsiteDoc.data()!.containsKey('views')) {
        final existingViews = campsiteDoc.data()!['views'];
        if (existingViews is Map) {
          viewsData = Map<String, dynamic>.from(existingViews);
        } else if (existingViews is int) {
          // Legacy format
          viewsData = {
            'total_legacy': existingViews
          };
          totalViews = existingViews;
        }
      }

      if (campsiteDoc.data()!.containsKey('total_views')) {
        totalViews = campsiteDoc.data()!['total_views'] ?? 0;
      } else if (viewsData.isNotEmpty && totalViews == 0) {
        // Calculate total if needed
        totalViews = viewsData.values.fold(0, (sum, value) => sum + (value is int ? value : 0));
      }

      // Calculate statistics
      final currentMonthViews = viewsData[_getCurrentMonthYearKey()] ?? 0;

      return {
        'monthly_views': viewsData,
        'total_views': totalViews,
        'current_month_views': currentMonthViews,
      };
    } catch (e) {
      _logDebug('Error getting view stats: $e', isError: true);
      return {
        'monthly_views': {},
        'total_views': 0,
        'current_month_views': 0,
      };
    }
  }

  /// Increment the booking link click count for a campsite
  Future<void> incrementBookingLinkClicks(String campsiteId) async {
    try {
      _logDebug('Incrementing booking link clicks for campsite: $campsiteId');

      final campsiteRef = _firestore.collection('sites').doc(campsiteId);
      final monthYearKey = _getCurrentMonthYearKey();

      // Use a transaction to ensure atomic update
      await _firestore.runTransaction((transaction) async {
        // Get the current campsite data
        final campsiteDoc = await transaction.get(campsiteRef);

        if (!campsiteDoc.exists) {
          throw Exception('Campsite does not exist');
        }

        // Set up the book_link_clicks field structure if it doesn't exist
        Map<String, dynamic> clicksData = {};
        if (campsiteDoc.data()!.containsKey('book_link_clicks')) {
          // Handle both cases: clicks as a map or clicks as an integer (legacy data)
          final existingClicks = campsiteDoc.data()!['book_link_clicks'];
          if (existingClicks is Map) {
            clicksData = Map<String, dynamic>.from(existingClicks);
          } else if (existingClicks is int) {
            // If clicks is an integer (old format), initialize the new format
            clicksData = {
              'total_legacy': existingClicks
            };
          }
        }

        // Increment the click count for the current month/year
        final currentMonthClicks = clicksData[monthYearKey] ?? 0;
        clicksData[monthYearKey] = currentMonthClicks + 1;

        // Update the document
        transaction.update(campsiteRef, {
          'book_link_clicks': clicksData,
          'total_book_link_clicks': FieldValue.increment(1),
        });
      });

      _logDebug('✅ Successfully incremented booking link click count');
    } catch (e) {
      _logDebug('Error incrementing booking link click count: $e', isError: true);
    }
  }

  /// Get booking link click statistics for a specific campsite
  Future<Map<String, dynamic>> getCampsiteBookingClickStats(String campsiteId) async {
    try {
      final campsiteDoc = await _firestore.collection('sites').doc(campsiteId).get();

      if (!campsiteDoc.exists) {
        throw Exception('Campsite does not exist');
      }

      // Extract clicks data
      Map<String, dynamic> clicksData = {};
      int totalClicks = 0;

      if (campsiteDoc.data()!.containsKey('book_link_clicks')) {
        final existingClicks = campsiteDoc.data()!['book_link_clicks'];
        if (existingClicks is Map) {
          clicksData = Map<String, dynamic>.from(existingClicks);
        } else if (existingClicks is int) {
          // Legacy format
          clicksData = {
            'total_legacy': existingClicks
          };
          totalClicks = existingClicks;
        }
      }

      if (campsiteDoc.data()!.containsKey('total_book_link_clicks')) {
        totalClicks = campsiteDoc.data()!['total_book_link_clicks'] ?? 0;
      } else if (clicksData.isNotEmpty && totalClicks == 0) {
        // Calculate total if needed
        totalClicks = clicksData.values.fold(0, (sum, value) => sum + (value is int ? value : 0));
      }

      // Calculate statistics
      final currentMonthClicks = clicksData[_getCurrentMonthYearKey()] ?? 0;

      return {
        'monthly_clicks': clicksData,
        'total_clicks': totalClicks,
        'current_month_clicks': currentMonthClicks,
      };
    } catch (e) {
      _logDebug('Error getting booking click stats: $e', isError: true);
      return {
        'monthly_clicks': {},
        'total_clicks': 0,
        'current_month_clicks': 0,
      };
    }
  }

  /// Get top viewed campsites
  Future<List<Map<String, dynamic>>> getTopViewedCampsites({int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection('sites')
          .orderBy('total_views', descending: true)
          .limit(limit)
          .get();

      List<Map<String, dynamic>> results = [];

      for (var doc in querySnapshot.docs) {
        results.add({
          'id': doc.id,
          'name': doc['name'] ?? 'Unknown Campsite',
          'total_views': doc['total_views'] ?? 0,
          'monthly_views': doc['views'] ?? {},
        });
      }

      return results;
    } catch (e) {
      _logDebug('Error getting top viewed campsites: $e', isError: true);
      return [];
    }
  }
}