// lib/src/campsite_owner/screens/analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../auth/providers/user_provider.dart';
import '../services/analytics_service.dart';
import '../widgets/analytics_stat_card.dart';
import '../widgets/views_section.dart';
import '../widgets/engagement_section.dart';
import '../widgets/reviews_section.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AnalyticsService _analyticsService = AnalyticsService();
  bool _isLoading = true;
  String? _selectedCampsiteId;
  List<String> _campsiteIds = [];
  Map<String, dynamic> _analyticsData = {};

  // Debug mode settings
  final bool _debugMode = false; // Set to true to use dummy data
  final String _debugViewsStatus = 'moderate'; // 'positive', 'moderate', 'negative'
  final String _debugEngagementStatus = 'positive'; // 'positive', 'moderate', 'negative'

  @override
  void initState() {
    super.initState();
    _loadCampsiteData();
  }

  Future<void> _loadCampsiteData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get owner's campsites
      final ownerDoc = await _firestore
          .collection('site_owners')
          .where('firebase_uid', isEqualTo: userProvider.user!.uid)
          .get();

      if (ownerDoc.docs.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final ownedSites = ownerDoc.docs.first.data()['owned_sites'] as List?;
      if (ownedSites == null || ownedSites.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Convert to List<String>
      _campsiteIds = List<String>.from(ownedSites.map((site) => site.toString()));

      // Set the default selected campsite to the first one
      final firstCampsiteId = _campsiteIds.first;

      setState(() {
        _selectedCampsiteId = firstCampsiteId;
      });

      // Load analytics for the selected campsite
      await _loadAnalyticsData(firstCampsiteId);

    } catch (e) {
      print('Error loading campsite data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAnalyticsData(String campsiteId) async {
    setState(() {
      _isLoading = true;
    });

    if (_debugMode) {
      setState(() {
        _analyticsData = _getDebugData();
        _isLoading = false;
      });
      return;
    }

    try {
      final analytics = await _analyticsService.getCampsiteAnalytics(campsiteId);

      setState(() {
        _analyticsData = analytics;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading analytics data: $e');
      setState(() {
        _analyticsData = {};
        _isLoading = false;
      });
    }
  }

  // Generate dummy data for debug mode
  Map<String, dynamic> _getDebugData() {
    // Generate appropriate values based on debug status
    final viewsGrowth = _debugViewsStatus == 'positive' ? 25.5 :
    _debugViewsStatus == 'moderate' ? 5.5 : -15.0;

    final favoriteRate = _debugEngagementStatus == 'positive' ? 18.5 :
    _debugEngagementStatus == 'moderate' ? 8.0 : 0.0;

    final int totalReviews = _debugEngagementStatus == 'positive' ? 15 :
    _debugEngagementStatus == 'moderate' ? 5 : 2;

    final double averageRating = _debugEngagementStatus == 'positive' ? 4.8 :
    _debugEngagementStatus == 'moderate' ? 3.5 : 2.3;

    // Generate a more realistic timeline based on the status
    final List<Map<String, dynamic>> timeline = [];
    final lastSixMonths = _getLastSixMonths();

    // Base monthly views values
    List<int> monthlyValues = [];

    if (_debugViewsStatus == 'positive') {
      // Steadily increasing pattern
      monthlyValues = [50, 65, 85, 95, 110, 140];
    } else if (_debugViewsStatus == 'moderate') {
      // Slightly increasing with some fluctuation
      monthlyValues = [70, 65, 75, 72, 80, 85];
    } else {
      // Declining trend
      monthlyValues = [100, 95, 90, 85, 75, 65];
    }

    // Create timeline data
    for (int i = 0; i < 6; i++) {
      timeline.add({
        'month': lastSixMonths[i],
        'views': monthlyValues[i],
      });
    }

    // Calculate totals based on the timeline
    final int totalViews = monthlyValues.reduce((sum, element) => sum + element);
    final int monthlyViews = monthlyValues.last;
    final int lastMonthViews = monthlyValues[monthlyValues.length - 2];

    // Basic dummy data
    final Map<String, dynamic> dummyData = {
      'totalViews': totalViews,
      'monthlyViews': monthlyViews,
      'lastMonthViews': lastMonthViews,
      'viewsGrowth': viewsGrowth,
      'viewsTimeline': timeline,
      'totalFavorites': (totalViews * favoriteRate / 100).round(),
      'monthlyFavorites': (monthlyViews * favoriteRate / 100).round(),
      'favoritesGrowth': viewsGrowth + 2.5,
      'totalReviews': totalReviews,
      'conversionRate': favoriteRate,
      'insights': {
        'views': {
          'status': _debugViewsStatus,
          'message': _getDebugViewsMessage(viewsGrowth, monthlyViews, lastMonthViews, totalViews),
        },
        'engagement': {
          'status': _debugEngagementStatus,
          'message': _getDebugEngagementMessage(favoriteRate, totalReviews),
        },
      },
      'reviewsData': {
        'averageRating': averageRating,
        'ratingDistribution': {
          '5': _debugEngagementStatus == 'positive' ? 10 : 1,
          '4': _debugEngagementStatus == 'positive' ? 3 : _debugEngagementStatus == 'moderate' ? 2 : 0,
          '3': _debugEngagementStatus == 'moderate' ? 2 : 0,
          '2': _debugEngagementStatus == 'negative' ? 1 : 0,
          '1': _debugEngagementStatus == 'negative' ? 1 : 0,
        },
        'recentReviews': _getDebugReviews(_debugEngagementStatus),
      }
    };

    return dummyData;
  }

  // Helper to get the names of the last six months
  List<String> _getLastSixMonths() {
    final List<String> months = [];
    final now = DateTime.now();

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i);
      months.add(_getMonthAbbreviation(month.month));
    }

    return months;
  }

  String _getMonthAbbreviation(int month) {
    const monthAbbreviations = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthAbbreviations[month - 1];
  }

  String _getDebugViewsMessage(double growth, int currentMonth, int lastMonth, int total) {
    if (_debugViewsStatus == 'positive') {
      return 'Your site has seen excellent growth of <b>${growth.toStringAsFixed(1)}%</b> '
          'increase from last month, bringing it to a monthly total of <b>$currentMonth</b> '
          'and an all-time viewership of <b>$total</b>!';
    } else if (_debugViewsStatus == 'moderate') {
      return 'Your site has seen moderate growth of <b>${growth.toStringAsFixed(1)}%</b> '
          'increase from last month, bringing it to a monthly total of <b>$currentMonth</b> '
          'and an all-time viewership of <b>$total</b>.';
    } else {
      return 'Your site has seen a decrease of <b>${(-growth).toStringAsFixed(1)}%</b> '
          'from last month, with currently <b>$currentMonth</b> views this month. '
          'Consider updating your listing to attract more visitors.';
    }
  }

  String _getDebugEngagementMessage(double saveRate, int totalReviews) {
    if (_debugEngagementStatus == 'positive') {
      return 'Your campsite has great engagement! <b>${saveRate.toStringAsFixed(1)}%</b> of visitors '
          'save your site, and <b>86.7%</b> of reviews are positive (4-5 stars). '
          'Keep up the good work!';
    } else if (_debugEngagementStatus == 'moderate') {
      return 'Your campsite has moderate engagement with a <b>${saveRate.toStringAsFixed(1)}%</b> save rate '
          'and <b>60.0%</b> positive reviews. There''s room for improvement '
      'to attract more interest.';
    } else {
      return 'Your engagement could be improved. Only <b>${saveRate.toStringAsFixed(1)}%</b> of visitors save '
          'your site. Consider enhancing your listing with better photos and information to '
          'increase visitor interest.';
    }
  }

  List<Map<String, dynamic>> _getDebugReviews(String status) {
    final now = DateTime.now();

    if (status == 'positive') {
      return [
        {
          'userId': 'user1',
          'username': 'HappyCamper',
          'userNumber': '#12345',
          'rating': 5,
          'comment': 'We had an amazing time! The facilities were clean and the views were breathtaking. Will definitely be back!',
          'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 2))),
          'profile': {'background': 'FFE91E63'},
        },
        {
          'userId': 'user2',
          'username': 'OutdoorLover',
          'userNumber': '#67890',
          'rating': 5,
          'comment': 'Perfect spot for a weekend getaway. Peaceful and beautiful surroundings.',
          'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 5))),
          'profile': {'background': '2196F3'},
        },
        {
          'userId': 'user3',
          'username': 'NatureFan',
          'userNumber': '#24680',
          'rating': 4,
          'comment': 'Great location and friendly staff. The only small issue was limited hot water.',
          'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 10))),
          'profile': {'background': '4CAF50'},
        },
      ];
    } else if (status == 'moderate') {
      return [
        {
          'userId': 'user1',
          'username': 'WeekendTraveler',
          'userNumber': '#13579',
          'rating': 4,
          'comment': 'Nice place overall. A bit basic but had everything we needed.',
          'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 3))),
          'profile': {'background': 'FF9800'},
        },
        {
          'userId': 'user2',
          'username': 'CampingFan',
          'userNumber': '#24680',
          'rating': 3,
          'comment': 'Decent campsite. Facilities could use some updating.',
          'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 7))),
          'profile': {'background': '9C27B0'},
        },
      ];
    } else {
      return [
        {
          'userId': 'user1',
          'username': 'DisappointedCamper',
          'userNumber': '#11223',
          'rating': 2,
          'comment': 'Not what we expected. The photos online looked much better than reality.',
          'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 4))),
          'profile': {'background': 'F44336'},
        },
        {
          'userId': 'user2',
          'username': 'Toets',
          'userNumber': '#99887',
          'rating': 1,
          'comment': 'It was kak!',
          'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
          'profile': {'background': '607D8B'},
        },
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff2e6f40)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Analytics',
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Add this to make the app bar solid even on scroll
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xff2e6f40)))
          : _campsiteIds.isEmpty
          ? _buildNoCampsitesView()
          : _buildAnalyticsView(),
    );
  }

  Widget _buildNoCampsitesView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FaIcon(
            FontAwesomeIcons.chartLine,
            size: 64,
            color: Color(0xff2e6f40),
          ),
          const SizedBox(height: 24),
          Text(
            'No Campsites Found',
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Please add a campsite to view analytics.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsView() {
    return RefreshIndicator(
      color: const Color(0xff2e6f40), // App green color
      backgroundColor: Colors.white, // White background
      onRefresh: () => _loadAnalyticsData(_selectedCampsiteId!),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Summary cards
            _buildSummaryCards(),

            const SizedBox(height: 20),

            // Views statistics
            ViewsSection(viewsData: _analyticsData),

            const SizedBox(height: 20),

            // Engagement statistics
            EngagementSection(engagementData: _analyticsData),

            const SizedBox(height: 20),

            // Conversion statistics
            _buildConversionCard(),

            const SizedBox(height: 20),

            // Reviews section
            ReviewsSection(reviewsData: _analyticsData['reviewsData'] ?? {}),

            // Add extra space at the bottom
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final int totalViews = _analyticsData['totalViews'] ?? 0;
    final int totalFavorites = _analyticsData['totalFavorites'] ?? 0;
    final int totalReviews = _analyticsData['totalReviews'] ?? 0;

    return Row(
      children: [
        // Total Views
        Expanded(
          child: StatSummaryCard(
            title: 'Total Views',
            value: totalViews.toString(),
            icon: FontAwesomeIcons.eye,
            color: Colors.blue,
          ),
        ),

        const SizedBox(width: 12),

        // Total Favorites
        Expanded(
          child: StatSummaryCard(
            title: 'Favorites',
            value: totalFavorites.toString(),
            icon: FontAwesomeIcons.heart,
            color: Colors.pink,
          ),
        ),

        const SizedBox(width: 12),

        // Total Reviews
        Expanded(
          child: StatSummaryCard(
            title: 'Reviews',
            value: totalReviews.toString(),
            icon: FontAwesomeIcons.comment,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildConversionCard() {
    // Get booking click data from analytics
    final int totalViews = _analyticsData['totalViews'] ?? 0;
    final int totalBookingClicks = _analyticsData['totalBookingClicks'] ?? 0;
    final int currentMonthBookingClicks = _analyticsData['monthlyBookingClicks'] ?? 0;
    final double bookingConversionRate = _analyticsData['bookingConversionRate'] ?? 0.0;
    final double bookingClicksGrowth = _analyticsData['bookingClicksGrowth'] ?? 0.0;

    // Check if we have any booking click data
    final bool hasBookingData = totalBookingClicks > 0;

    return AnalyticsStatCard(
      title: 'Conversions',
      content: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: hasBookingData
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Conversion Rate',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track how many viewers proceed to booking',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            // Conversion Rate
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.chartPie,
                      color: Colors.purple,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conversion Rate',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Views to Booking Clicks',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${bookingConversionRate.toStringAsFixed(1)}%',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff2e6f40),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Total Clicks
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.handPointer,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Booking Clicks',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'All Time',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  totalBookingClicks.toString(),
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Monthly Clicks
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.calendarCheck,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This Month',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Booking Clicks',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  currentMonthBookingClicks.toString(),
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Growth
            if (bookingClicksGrowth != 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bookingClicksGrowth >= 0
                      ? Colors.green.withValues(alpha: .1)
                      : Colors.red.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      bookingClicksGrowth >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                      color: bookingClicksGrowth >= 0 ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${bookingClicksGrowth.abs().toStringAsFixed(1)}% ${bookingClicksGrowth >= 0 ? 'increase' : 'decrease'} from last month',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: bookingClicksGrowth >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Booking Conversion Rate',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track how many viewers proceed to booking',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'When users click on your booking link, conversion data will appear here',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Make sure your campsite listing has a booking link to track conversions',
              style: GoogleFonts.montserrat(
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}