import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore;

  AnalyticsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Gets analytics data for a specific campsite
  Future<Map<String, dynamic>> getCampsiteAnalytics(String campsiteId) async {
    try {
      final campsiteDoc = await _firestore.collection('sites').doc(campsiteId).get();

      if (!campsiteDoc.exists) {
        throw Exception('Campsite not found');
      }

      final data = campsiteDoc.data()!;
      final analytics = await _processAnalyticsData(data, campsiteId);

      return analytics;
    } catch (e) {
      print('Error getting campsite analytics: $e');
      rethrow;
    }
  }

  /// Process raw campsite data into organized analytics
  Future<Map<String, dynamic>> _processAnalyticsData(
      Map<String, dynamic> data,
      String campsiteId
      ) async {
    // Get views data
    int totalViews = data['total_views'] ?? 0;
    Map<String, dynamic> viewsByMonth = {};

    if (data['views'] != null && data['views'] is Map) {
      viewsByMonth = Map<String, dynamic>.from(data['views']);
    }

    // Get current month and calculate recent views
    final now = DateTime.now();
    final currentMonthKey = '${_getMonthName(now.month).toLowerCase()}_${now.year}';
    final lastMonthKey = '${_getMonthName(now.month > 1 ? now.month - 1 : 12).toLowerCase()}_${now.month > 1 ? now.year : now.year - 1}';

    final currentMonthViews = viewsByMonth[currentMonthKey] ?? 0;
    final lastMonthViews = viewsByMonth[lastMonthKey] ?? 0;

    // Calculate views growth percentage
    double viewsGrowth = 0;
    if (lastMonthViews > 0) {
      viewsGrowth = ((currentMonthViews - lastMonthViews) / lastMonthViews) * 100;
    } else if (currentMonthViews > 0) {
      // If last month was 0 but this month has views, that's a 100% increase for each view
      viewsGrowth = currentMonthViews * 100.0;
    }

    // Get favorites data
    int totalFavorites = data['total_favorites'] ?? 0;
    Map<String, dynamic> favoritesByMonth = {};

    if (data['favorites'] != null && data['favorites'] is Map) {
      favoritesByMonth = Map<String, dynamic>.from(data['favorites']);
    }

    final currentMonthFavorites = favoritesByMonth[currentMonthKey] ?? 0;
    final lastMonthFavorites = favoritesByMonth[lastMonthKey] ?? 0;

    // Calculate favorites growth percentage
    double favoritesGrowth = 0;
    if (lastMonthFavorites > 0) {
      favoritesGrowth = ((currentMonthFavorites - lastMonthFavorites) / lastMonthFavorites) * 100;
    }

    // Get reviews data and calculate distribution
    List<dynamic> reviewsUserIds = [];
    if (data['comments'] != null && data['comments'] is List) {
      reviewsUserIds = List<dynamic>.from(data['comments']);
    }

    int totalReviews = reviewsUserIds.length;

    // Get actual review data for rating distribution and average
    final reviewsData = await _getReviewData(campsiteId, reviewsUserIds);

    // Calculate conversion rate (favorites to views)
    double conversionRate = 0;
    if (totalViews > 0) {
      conversionRate = (totalFavorites / totalViews) * 100;
    }

    // Prepare timeline data (last 6 months)
    List<Map<String, dynamic>> viewsTimeline = [];

    for (int i = 5; i >= 0; i--) {
      DateTime month = DateTime(now.year, now.month - i);
      String monthKey = '${_getMonthName(month.month).toLowerCase()}_${month.year}';
      int monthViews = viewsByMonth[monthKey] ?? 0;

      viewsTimeline.add({
        'month': DateFormat('MMM').format(month),
        'views': monthViews,
      });
    }

    // Add this near the other stats calculation
// Get booking click data
    int totalBookingClicks = data['total_book_link_clicks'] ?? 0;
    Map<String, dynamic> clicksByMonth = {};

    if (data['book_link_clicks'] != null && data['book_link_clicks'] is Map) {
      clicksByMonth = Map<String, dynamic>.from(data['book_link_clicks']);
    }

    final currentMonthBookingClicks = clicksByMonth[currentMonthKey] ?? 0;
    final lastMonthBookingClicks = clicksByMonth[lastMonthKey] ?? 0;

// Calculate booking click growth percentage
    double bookingClicksGrowth = 0;
    if (lastMonthBookingClicks > 0) {
      bookingClicksGrowth = ((currentMonthBookingClicks - lastMonthBookingClicks) / lastMonthBookingClicks) * 100;
    }

// Calculate conversion rate (booking clicks to views)
    // Calculate booking conversion rate (booking clicks to views)
    double bookingConversionRate = 0;
    if (totalViews > 0) {
      bookingConversionRate = (totalBookingClicks / totalViews) * 100;
    }

    // Generate insights
    final viewsInsight = _generateViewsInsight(
        currentMonthViews,
        lastMonthViews,
        viewsGrowth,
        totalViews
    );

    final engagementInsight = _generateEngagementInsight(
        totalViews,
        totalFavorites,
        totalReviews,
        reviewsData
    );

    return {
      'totalViews': totalViews,
      'monthlyViews': currentMonthViews,
      'lastMonthViews': lastMonthViews,
      'viewsGrowth': viewsGrowth,
      'viewsTimeline': viewsTimeline,
      'totalFavorites': totalFavorites,
      'monthlyFavorites': currentMonthFavorites,
      'favoritesGrowth': favoritesGrowth,
      'totalReviews': totalReviews,
      'reviewsData': reviewsData,
      'conversionRate': conversionRate,
      'totalBookingClicks': totalBookingClicks,
      'monthlyBookingClicks': currentMonthBookingClicks,
      'lastMonthBookingClicks': lastMonthBookingClicks,
      'bookingClicksGrowth': bookingClicksGrowth,
      'bookingConversionRate': bookingConversionRate,
      'insights': {
        'views': viewsInsight,
        'engagement': engagementInsight,
      }
    };
  }

  /// Get detailed review data for a campsite
  Future<Map<String, dynamic>> _getReviewData(
      String campsiteId,
      List<dynamic> reviewUserIds
      ) async {
    // Default structure for review data
    Map<String, dynamic> reviewsData = {
      'averageRating': 0.0,
      'ratingDistribution': {
        '5': 0,
        '4': 0,
        '3': 0,
        '2': 0,
        '1': 0,
      },
      'recentReviews': [],
    };

    if (reviewUserIds.isEmpty) {
      return reviewsData;
    }

    try {
      int totalRating = 0;
      List<Map<String, dynamic>> allReviews = [];

      // Process reviews in batches to avoid Firestore limits
      for (int i = 0; i < reviewUserIds.length; i += 10) {
        int end = (i + 10 > reviewUserIds.length) ? reviewUserIds.length : i + 10;
        List<dynamic> batch = reviewUserIds.sublist(i, end);

        final usersQuery = await _firestore.collection('users')
            .where('firebase_uid', whereIn: batch)
            .get();

        for (var userDoc in usersQuery.docs) {
          final userData = userDoc.data();
          if (userData.containsKey('comments') &&
              userData['comments'] != null &&
              userData['comments'][campsiteId] != null) {

            final commentData = userData['comments'][campsiteId];
            final int rating = commentData['rating'] ?? 0;

            // Add to total rating
            totalRating += rating;

            // Update rating distribution
            reviewsData['ratingDistribution']['$rating'] =
                (reviewsData['ratingDistribution']['$rating'] as int) + 1;

            // Add to all reviews
            allReviews.add({
              'userId': userData['firebase_uid'],
              'username': userData['username'] ?? 'Anonymous',
              'userNumber': userData['user_number'] ?? '',
              'rating': rating,
              'comment': commentData['comment'] ?? '',
              'createdAt': commentData['createdAt'] ?? Timestamp.now(),
              'profile': userData['profile'],
            });
          }
        }
      }

      // Calculate average rating
      if (allReviews.isNotEmpty) {
        reviewsData['averageRating'] = totalRating / allReviews.length;
      }

      // Sort reviews by creation date (newest first)
      allReviews.sort((a, b) {
        final aTime = a['createdAt'] as Timestamp;
        final bTime = b['createdAt'] as Timestamp;
        return bTime.compareTo(aTime);
      });

      // Get the 3 most recent reviews
      reviewsData['recentReviews'] = allReviews.take(3).toList();

      return reviewsData;
    } catch (e) {
      print('Error getting review data: $e');
      return reviewsData;
    }
  }

  /// Generate insight for views statistics
  Map<String, dynamic> _generateViewsInsight(
      int currentMonthViews,
      int lastMonthViews,
      double viewsGrowth,
      int totalViews
      ) {
    String message = '';
    String status = '';

    // Determine status based on growth percentage
    if (viewsGrowth >= 10.0) {
      status = 'positive';
      message = 'Your site has seen excellent growth of <b>${viewsGrowth.toStringAsFixed(1)}%</b> '
          'increase from last month, bringing it to a monthly total of <b>$currentMonthViews</b> '
          'and an all-time viewership of <b>$totalViews</b>!';
    } else if (viewsGrowth >= 0) {
      status = 'moderate';
      message = 'Your site has seen moderate growth of <b>${viewsGrowth.toStringAsFixed(1)}%</b> '
          'increase from last month, bringing it to a monthly total of <b>$currentMonthViews</b> '
          'and an all-time viewership of <b>$totalViews</b>.';
    } else {
      status = 'negative';
      message = 'Your site has seen a decrease of <b>${(-viewsGrowth).toStringAsFixed(1)}%</b> '
          'from last month, with currently <b>$currentMonthViews</b> views this month. '
          'Consider updating your listing to attract more visitors.';
    }

    return {
      'status': status,
      'message': message,
    };
  }

  /// Generate insight for engagement statistics
  Map<String, dynamic> _generateEngagementInsight(
      int totalViews,
      int totalFavorites,
      int totalReviews,
      Map<String, dynamic> reviewsData
      ) {
    String message = '';
    String status = '';

    // Calculate save rate (favorites / views)
    double saveRate = totalViews > 0 ? (totalFavorites / totalViews) * 100 : 0;

    // Calculate positive review percentage
    int positiveReviews = 0;
    int neutralReviews = 0;
    int negativeReviews = 0;

    if (totalReviews > 0) {
      // Count different rating categories
      positiveReviews = (reviewsData['ratingDistribution']['5'] as int) +
          (reviewsData['ratingDistribution']['4'] as int);
      neutralReviews = reviewsData['ratingDistribution']['3'] as int;
      negativeReviews = (reviewsData['ratingDistribution']['2'] as int) +
          (reviewsData['ratingDistribution']['1'] as int);
    }

    double positiveReviewPercentage = totalReviews > 0
        ? (positiveReviews / totalReviews) * 100
        : 0;

    // Determine status based on save rate and positive reviews
    if (saveRate >= 15 && positiveReviewPercentage >= 80) {
      status = 'positive';
      message = 'Your campsite has great engagement! <b>${saveRate.toStringAsFixed(1)}%</b> of visitors '
          'save your site, and <b>${positiveReviewPercentage.toStringAsFixed(1)}%</b> of reviews are positive (4-5 stars). '
          'Keep up the good work!';
    } else if (saveRate >= 5 && positiveReviewPercentage >= 60) {
      status = 'moderate';
      message = 'Your campsite has moderate engagement with a <b>${saveRate.toStringAsFixed(1)}%</b> save rate '
          'and <b>${positiveReviewPercentage.toStringAsFixed(1)}%</b> positive reviews. There''s room for improvement '
      'to attract more interest.';
    } else {
      status = 'negative';
      message = 'Your engagement could be improved. Only <b>${saveRate.toStringAsFixed(1)}%</b> of visitors save '
          'your site. Consider enhancing your listing with better photos and information to '
          'increase visitor interest.';
    }

    return {
      'status': status,
      'message': message,
      'saveRate': saveRate,
      'positiveReviewPercentage': positiveReviewPercentage,
    };
  }

  /// Helper function to get month name
  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}