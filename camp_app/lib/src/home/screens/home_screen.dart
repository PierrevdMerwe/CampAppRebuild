// lib/src/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/config/theme/theme_model.dart';
import '../widgets/home_banner.dart';
import '../widgets/category_grid.dart';
import '../widgets/location_list.dart';
import '../widgets/popular_listings.dart';
import '../widgets/search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  bool _isMenuOpen = false;
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
  }

  void _onScroll() {
    final double offset = _scrollController.offset;
    setState(() {
      _textColor = offset > 50 ? const Color(0xff2e6f40) : Colors.white;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, themeModel, child) {
        return Scaffold(
          key: _scaffoldKey,
          endDrawer: _buildDrawer(themeModel),
          backgroundColor: themeModel.isDark ? Colors.black : Colors.white,
          body: CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.25,
                pinned: true,
                elevation: 0,
                automaticallyImplyLeading: false,
                actions: [_buildMenuButton()],
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0, top: 10.0),
      child: IconButton(
        icon: const Icon(
          Icons.menu,
          color: Color(0xff2e6f40),
          size: 40,
        ),
        onPressed: () {
          if (_isMenuOpen) {
            Navigator.of(context).maybePop();
          } else {
            _scaffoldKey.currentState!.openEndDrawer();
          }
          setState(() {
            _isMenuOpen = !_isMenuOpen;
          });
        },
      ),
    );
  }

  Widget _buildDrawer(ThemeModel themeModel) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.only(top: 70.0),
        children: <Widget>[
          _buildDrawerItem(Icons.home, 'Home', () {}),
          const SizedBox(height: 10),
          _buildCampingExpansionTile(),
          const SizedBox(height: 10),
          _buildDrawerItem(Icons.business, 'Business Providers', () {}),
          const SizedBox(height: 10),
          _buildDrawerItem(Icons.shopping_cart_outlined, 'Shop', () {}),
          const SizedBox(height: 10),
          _buildDrawerItem(Icons.contact_mail, 'Contact us', () {}),
          const SizedBox(height: 325),
          _buildDrawerButton('Sign in'),
          const SizedBox(height: 10),
          _buildDrawerButton('Add listing'),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
      ),
      onTap: onTap,
    );
  }

  Widget _buildCampingExpansionTile() {
    return ExpansionTile(
      leading: const Icon(Icons.forest),
      title: Text(
        'Camping',
        style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
      ),
      iconColor: const Color(0xff2e6f40),
      children: <Widget>[
        _buildDrawerItem(Icons.place, 'Namibia', () {}),
        const SizedBox(height: 10),
        _buildDrawerItem(Icons.check_box, 'Camping checklist', () {}),
        const SizedBox(height: 10),
        _buildDrawerItem(Icons.map, 'Roadtrip planner', () {}),
      ],
    );
  }

  Widget _buildDrawerButton(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff2e6f40),
        ),
        child: Text(
          text,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return CustomSearchBar();
  }

  @override
  double get maxExtent => 56.0;

  @override
  double get minExtent => 56.0;

  @override
  bool shouldRebuild(_SearchBarDelegate oldDelegate) => false;
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