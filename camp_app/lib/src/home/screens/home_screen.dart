import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../campsite/screens/campsite_search_screen.dart';
import '../../core/config/theme/theme_model.dart';
import '../widgets/home_banner.dart';
import '../widgets/category_grid.dart';
import '../widgets/location_list.dart';
import '../widgets/popular_listings.dart';
import '../widgets/search_bar.dart';
import '../widgets/sliding_menu.dart';
import '../widgets/social_footer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  Color _textColor = Colors.white;

  final Map<String, IconData> categories = {
    'Swimming Pool': Icons.waves,
    'Pets Allowed': Icons.pets,
    'Hiking': Icons.hiking,
    'Braai Place': Icons.local_fire_department,
    'Jacuzzi': Icons.bathtub,
    'Glamping': Icons.house,
    'Signal': Icons.signal_cellular_alt,
    'Beach Camping': Icons.beach_access,
    'Fishing': Icons.water_drop,
  };

  final Map<String, Color> categoryColors = {
    'Swimming Pool': Colors.blue,
    'Pets Allowed': Colors.brown,
    'Hiking': Colors.green,
    'Braai Place': Colors.deepOrangeAccent,
    'Jacuzzi': Colors.blue,
    'Glamping': Colors.indigo,
    'Signal': Colors.purple,
    'Beach Camping': Colors.pink,
    'Fishing': Colors.blueAccent,
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _onScroll() {
    final double offset = _scrollController.offset;
    setState(() {
      _textColor = offset > 50 ? const Color(0xff2e6f40) : Colors.white;
    });
  }

  void _toggleMenu() {
    if (_animationController.value == 0) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, themeModel, child) {
        return Scaffold(
          backgroundColor: themeModel.isDark ? Colors.black : Colors.white,
          body: Stack(
            children: [
              // Main Content
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
                    child: CustomScrollView(
                      controller: _scrollController,
                      slivers: <Widget>[
                        SliverAppBar(
                          expandedHeight: MediaQuery.of(context).size.height * 0.25,
                          pinned: true,
                          elevation: 0,
                          backgroundColor: Colors.white,
                          automaticallyImplyLeading: false,
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
                          flexibleSpace: HomeBanner(textColor: _textColor),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.03
                          ),
                        ),
                        SliverPersistentHeader(
                          delegate: _SearchBarDelegate(),
                          pinned: true,
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SearchScreen(
                                        '', // Empty query to show all campsites
                                        initialShowMap: true, // Start with map view
                                        initialCenter: const LatLng(-30.74155601977579, 24.34204925536877), // Default center
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff2e6f40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                icon: const Icon(Icons.map, color: Colors.white),
                                label: Text(
                                  'View All Campsites on Map',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        _buildSectionTitle(
                          'Popular Listings',
                          themeModel.isDark,
                          topPadding: 40,
                        ),
                        const SliverToBoxAdapter(
                          child: PopularListings(),
                        ),
                        _buildSectionTitle(
                          'Explore Special Campsites Categories',
                          themeModel.isDark,
                        ),
                        SliverToBoxAdapter(
                          child: CategoryGrid(
                            categories: categories,
                            categoryColors: categoryColors,
                          ),
                        ),
                        _buildSectionTitle(
                          'Explore Locations',
                          themeModel.isDark,
                        ),
                        SliverToBoxAdapter(
                          child: LocationList(
                            locations: LocationData.getAllLocations(),
                          ),
                        ),
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(top: 40.0),
                            child: SocialFooter(),
                          ),
                        ),
                        const SliverPadding(
                          padding: EdgeInsets.only(bottom: 20.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Menu
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(MediaQuery.of(context).size.width * 0.6 * (1 - _animationController.value), 0),
                      child: child,
                    );
                  },
                  child: SlidingMenu(onClose: _toggleMenu),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, bool isDark, {double topPadding = 40}) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
          top: topPadding,
          bottom: 20,
          left: 24,
        ),
        child: Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return const CustomSearchBar();
  }

  @override
  double get maxExtent => 56.0;

  @override
  double get minExtent => 56.0;

  @override
  bool shouldRebuild(_SearchBarDelegate oldDelegate) => false;
}