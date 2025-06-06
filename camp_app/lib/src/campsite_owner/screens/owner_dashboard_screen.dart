// lib/src/campsite_owner/screens/owner_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../auth/providers/user_provider.dart';
import '../../core/config/theme/theme_model.dart';
import '../widgets/dashboard_section_card.dart';
import '../widgets/owner_sliding_menu.dart';
import './campsite_info_screen.dart';
import './analytics_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  _OwnerDashboardScreenState createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _hasCampsites = false;
  bool _isLoading = true;
  List<String> _campsiteIds = [];
  Map<String, dynamic> _analyticsData = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _checkCampsites();
  }

  Future<void> _checkCampsites() async {
    if (!mounted) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user != null) {
      try {
        final doc = await _firestore
            .collection('site_owners')
            .where('firebase_uid', isEqualTo: userProvider.user!.uid)
            .get();

        if (!mounted) return;

        if (doc.docs.isNotEmpty) {
          final data = doc.docs.first.data();
          final ownedSites = data['owned_sites'] as List?;
          print('Found owned_sites: $ownedSites'); // Debug log

          if (ownedSites != null && ownedSites.isNotEmpty) {
            // Convert to List<String> and fetch analytics data
            _campsiteIds = List<String>.from(ownedSites.map((site) => site.toString()));
            await _fetchAnalyticsData();
          }

          if (mounted) {
            setState(() {
              _hasCampsites = ownedSites != null && ownedSites.isNotEmpty;
              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _hasCampsites = false;
              _isLoading = false;
            });
          }
        }
      } catch (e) {
        print('Error checking campsites: $e');
        if (mounted) {
          setState(() {
            _hasCampsites = false;
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _hasCampsites = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchAnalyticsData() async {
    try {
      Map<String, dynamic> analyticsData = {
        'totalViews': 0,
        'monthlyViews': {},
        'currentMonthViews': 0,
        'favorites': 0,
        'comments': 0,
      };

      // Get current month/year for filtering
      final now = DateTime.now();
      final currentMonthYear = '${_getMonthName(now.month).toLowerCase()}_${now.year}';

      for (String campsiteId in _campsiteIds) {
        final docSnapshot = await _firestore.collection('sites').doc(campsiteId).get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data()!;
          // No longer tracking provinces and tags for the overview

          // Aggregate total views
          if (data['total_views'] != null) {
            analyticsData['totalViews'] += data['total_views'] as int;
          }

          // Process monthly views
          if (data['views'] != null && data['views'] is Map) {
            final viewsData = Map<String, dynamic>.from(data['views']);

            // Add to monthly totals
            viewsData.forEach((month, count) {
              if (!analyticsData['monthlyViews'].containsKey(month)) {
                analyticsData['monthlyViews'][month] = 0;
              }
              analyticsData['monthlyViews'][month] += count as int;

              // Track current month views
              if (month == currentMonthYear) {
                analyticsData['currentMonthViews'] += count;
              }
            });
          }

          // Count favorites
          if (data['total_favorites'] != null) {
            analyticsData['favorites'] += data['total_favorites'] as int;
          }

          // Count comments
          if (data['comments'] != null && data['comments'] is List) {
            analyticsData['comments'] += (data['comments'] as List).length;
          }
        }
      }

      // No longer need to convert province and tag sets

      if (mounted) {
        setState(() {
          _analyticsData = analyticsData;
        });
      }
    } catch (e) {
      print('Error fetching analytics data: $e');
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  void _toggleMenu() {
    if (_animationController.value == 0) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _showComingSoonDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Coming Soon!',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              color: const Color(0xff2e6f40),
            ),
          ),
          content: Text(
            'We\'re working hard to bring you this feature. Stay tuned!',
            style: GoogleFonts.montserrat(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: GoogleFonts.montserrat(
                  color: const Color(0xff2e6f40),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return SafeArea(
      child: Column(
        children: [
          // App Bar equivalent for empty state
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Consumer<UserProvider>(
                  builder: (context, userProvider, _) =>
                      Text(
                        userProvider.user?.name ?? 'Campsite Dashboard',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff2e6f40),
                        ),
                      ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.menu,
                    color: Color(0xff2e6f40),
                    size: 32,
                  ),
                  onPressed: _toggleMenu,
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome to Campp!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff2e6f40),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Please click the "+" icon below to begin the process of adding your campsite. Once completed, you\'ll be able to view analytics and handle your listings with ease.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),
                    InkWell(
                      onTap: _showComingSoonDialog,
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: .1),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xff2e6f40).withValues(alpha: .1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 32,
                                color: Color(0xff2e6f40),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Add Your Campsite',
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xff2e6f40),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: <Widget>[
        SliverAppBar(
          expandedHeight: MediaQuery.of(context).size.height * 0.25,
          pinned: true,
          backgroundColor: const Color(0xffF5F8F5),
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            background: Image.asset(
              'images/homepage_banner.jpg',
              fit: BoxFit.cover,
            ),
            titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
            expandedTitleScale: 1.2,
            title: Consumer<UserProvider>(
              builder: (context, userProvider, _) =>
                  Text(
                    '${userProvider.user?.name ?? 'Campsite'} Dashboard',
                    style: GoogleFonts.montserrat(
                      color: const Color(0xff2e6f40),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ),
            centerTitle: false,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 8.0),
              child: IconButton(
                icon: const Icon(
                  Icons.menu,
                  color: Color(0xff2e6f40),
                  size: 32,
                ),
                onPressed: _toggleMenu,
                padding: EdgeInsets.zero,
                alignment: Alignment.topRight,
              ),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildOverviewCard(),
                const SizedBox(height: 20),
                _buildCampsiteInfoCard(),
                const SizedBox(height: 20),
                _buildViewsEngagementCard(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, themeModel, child) {
        return Scaffold(
          backgroundColor: themeModel.isDark ? Colors.black : Colors.white,
          body: Stack(
            children: [
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform(
                    alignment: Alignment.centerRight,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(-0.3 * _animationController.value)
                      ..translate(-MediaQuery.of(context).size.width * 0.4 * _animationController.value)
                      ..scale(1 - 0.2 * _animationController.value),
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTap: _animationController.value == 1 ? _toggleMenu : null,
                  child: Container(
                    color: themeModel.isDark ? Colors.black : Colors.white,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : !_hasCampsites
                        ? _buildEmptyState()
                        : _buildDashboardContent(),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        MediaQuery.of(context).size.width * 0.6 * (1 - _animationController.value),
                        0,
                      ),
                      child: child,
                    );
                  },
                  child: OwnerSlidingMenu(onClose: _toggleMenu),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewCard() {
    return DashboardSectionCard(
      title: 'Overview',
      onTap: () {},
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InfoItem(
              icon: FontAwesomeIcons.eye,
              label: 'Total Views',
              value: '${_analyticsData['totalViews'] ?? 0}',
            ),
            InfoItem(
              icon: FontAwesomeIcons.heart,
              label: 'Favorites',
              value: '${_analyticsData['favorites'] ?? 0}',
            ),
            InfoItem(
              icon: FontAwesomeIcons.comment,
              label: 'Reviews',
              value: '${_analyticsData['comments'] ?? 0}',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCampsiteInfoCard() {
    return FutureBuilder<QuerySnapshot>(
      future: _firestore.collection('sites')
          .where(FieldPath.documentId, whereIn: _campsiteIds.isEmpty ? ['none'] : _campsiteIds)
          .limit(1)
          .get(),
      builder: (context, snapshot) {
        // Default values
        String campsiteName = 'Not available';
        String price = '0';
        String telephone = 'Not available';

        // If we have data, update the values
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            snapshot.data!.docs.isNotEmpty) {
          final campsite = snapshot.data!.docs[0];
          final data = campsite.data() as Map<String, dynamic>;

          campsiteName = data['name'] ?? 'Not available';
          price = data['price']?.toString() ?? '0';
          telephone = data['telephone'] ?? 'Not available';
        }

        return DashboardSectionCard(
          title: 'Campsite Information',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CampsiteInfoScreen()),
            );
          },
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
          children: [
            InfoItem(
              icon: FontAwesomeIcons.campground,
              label: 'Name',
              value: campsiteName,
            ),
            const SizedBox(height: 12),
            InfoItem(
              icon: FontAwesomeIcons.moneyBill,
              label: 'Price',
              value: 'R$price',
            ),
            const SizedBox(height: 12),
            InfoItem(
              icon: FontAwesomeIcons.phone,
              label: 'Telephone',
              value: telephone,
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnalyticsCard() {
    return DashboardSectionCard(
      title: 'Analytics',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
        );
      },
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      children: [
        InfoItem(
          icon: Icons.trending_up,
          label: 'Page Views',
          value: '${_analyticsData['totalViews'] ?? 0} Total',
        ),
        const SizedBox(height: 12),
        InfoItem(
          icon: Icons.favorite,
          label: 'Favorited',
          value: '${_analyticsData['favorites'] ?? 0} Saves',
        ),
        const SizedBox(height: 12),
        InfoItem(
          icon: Icons.star,
          label: 'Review Activity',
          value: '${_analyticsData['comments'] ?? 0} Reviews',
        ),
      ],
    );
  }

  Widget _buildViewsEngagementCard() {
    // Get current and previous month
    final now = DateTime.now();
    final currentMonth = _getMonthName(now.month);
    final previousMonth = _getMonthName(now.month > 1 ? now.month - 1 : 12);

    // Calculate current and previous month views
    final currentMonthKey = '${currentMonth.toLowerCase()}_${now.year}';
    final previousMonthKey = '${previousMonth.toLowerCase()}_${now.month > 1 ? now.year : now.year - 1}';

    final currentMonthViews = _analyticsData['monthlyViews']?[currentMonthKey] ?? 0;
    final previousMonthViews = _analyticsData['monthlyViews']?[previousMonthKey] ?? 0;

    // Calculate percentage change
    int? percentChange = 0;
    if (previousMonthViews > 0) {
      percentChange = ((currentMonthViews - previousMonthViews) / previousMonthViews * 100).round();
    } else if (currentMonthViews > 0) {
      // If previous month was 0 but current month has views, that's a 100% increase for each view
      percentChange = (100 * currentMonthViews) as int?;
    }

    return DashboardSectionCard(
      title: 'Views & Engagement',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
        );
      },
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      children: [
        InfoItem(
          icon: FontAwesomeIcons.calendarDay,
          label: '$currentMonth Views',
          value: '$currentMonthViews',
        ),
        const SizedBox(height: 12),
        InfoItem(
          icon: FontAwesomeIcons.arrowsLeftRight,
          label: 'Change from $previousMonth',
          value: percentChange! >= 0 ? '+$percentChange%' : '$percentChange%',
          iconColor: percentChange >= 0 ? Colors.green : Colors.red,
        ),
        const SizedBox(height: 12),
        const InfoItem(
          icon: FontAwesomeIcons.chartLine,
          label: 'View Analytics',
          value: 'Click for details',
        ),
      ],
    );
  }
}