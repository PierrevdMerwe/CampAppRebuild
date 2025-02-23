// lib/src/campsite_owner/screens/owner_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/providers/user_provider.dart';
import '../../core/config/theme/theme_model.dart';
import '../widgets/dashboard_section_card.dart';
import '../widgets/owner_sliding_menu.dart';
import './campsite_info_screen.dart';
import './bookings_screen.dart';
import './analytics_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({Key? key}) : super(key: key);

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
                      'Please click the "+" icon below to begin the process of adding your campsite. Once completed, you\'ll be able to manage bookings, view analytics, and handle your listings with ease.',
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
                              color: Colors.grey.withOpacity(0.1),
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
                                color: const Color(0xff2e6f40).withOpacity(0.1),
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
          expandedHeight: MediaQuery
              .of(context)
              .size
              .height * 0.25,
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
                _buildBookingsCard(),
                const SizedBox(height: 20),
                _buildAnalyticsCard(),
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
                      ..translate(-MediaQuery
                          .of(context)
                          .size
                          .width * 0.4 * _animationController.value)
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
                        MediaQuery
                            .of(context)
                            .size
                            .width * 0.6 * (1 - _animationController.value),
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
              icon: Icons.visibility,
              label: 'Views',
              value: '245',
            ),
            InfoItem(
              icon: Icons.calendar_today,
              label: 'Bookings',
              value: '12',
            ),
            InfoItem(
              icon: Icons.star,
              label: 'Rating',
              value: '4.8',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCampsiteInfoCard() {
    return DashboardSectionCard(
      title: 'Campsite Information',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CampsiteInfoScreen()),
        );
      },
      children: [
        InfoItem(
          icon: Icons.location_on,
          label: 'Location',
          value: 'Cape Town, Western Cape',
        ),
        const SizedBox(height: 12),
        InfoItem(
          icon: Icons.emoji_nature,
          label: 'Amenities',
          value: '8 Available',
        ),
        const SizedBox(height: 12),
        InfoItem(
          icon: Icons.photo_library,
          label: 'Gallery',
          value: '12 Photos',
        ),
      ],
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildBookingsCard() {
    return DashboardSectionCard(
      title: 'Recent Bookings',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BookingsScreen()),
        );
      },
      children: [
        InfoItem(
          icon: Icons.event,
          label: 'Pending',
          value: '3 Bookings',
        ),
        const SizedBox(height: 12),
        InfoItem(
          icon: Icons.event_available,
          label: 'Upcoming',
          value: '5 Bookings',
        ),
        const SizedBox(height: 12),
        InfoItem(
          icon: Icons.history,
          label: 'This Month',
          value: '15 Total',
        ),
      ],
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
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
      children: [
        InfoItem(
          icon: Icons.trending_up,
          label: 'Revenue',
          value: 'R 25,480',
        ),
        const SizedBox(height: 12),
        InfoItem(
          icon: Icons.people,
          label: 'Total Visitors',
          value: '156 This Month',
        ),
        const SizedBox(height: 12),
        InfoItem(
          icon: Icons.assessment,
          label: 'Occupancy Rate',
          value: '78%',
        ),
      ],
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
    );
  }
}