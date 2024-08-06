import 'dart:async';
import 'package:camp_app/search_result.dart';
import 'package:camp_app/theme_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'campsite_details_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isMenuOpen = false;
  final StreamController<QuerySnapshot> _streamController = StreamController();
  final ScrollController _scrollController = ScrollController();
  Color _textColor = Colors.white;
  List<DocumentSnapshot> _popularListings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadPopularListings();
  }

  Future<void> _loadPopularListings() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('sites').get();
      setState(() {
        _popularListings = snapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    final double offset = _scrollController.offset;
    setState(() {
      _textColor = offset > 50 ? const Color(0xfff51957) : Colors.white;
    });
  }

  @override
  void dispose() {
    _streamController.close();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Consumer<ThemeModel>(
          builder: (context, themeModel, child) {
            return Scaffold(
              key: _scaffoldKey,
              endDrawer: Drawer(
                child: ListView(
                  padding: const EdgeInsets.only(top: 70.0),
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.home),
                      title: Text(
                        'Home',
                        style:
                            GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                      ),
                      onTap: () {},
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ExpansionTile(
                      leading: const Icon(Icons.forest),
                      title: Text(
                        'Camping',
                        style:
                            GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                      ),
                      iconColor: const Color(0xfff51957),
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.place),
                          title: Text(
                            'Namibia',
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold),
                          ),
                          onTap: () {},
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ListTile(
                          leading: const Icon(Icons.check_box),
                          title: Text(
                            'Camping checklist',
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold),
                          ),
                          onTap: () {},
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ListTile(
                          leading: const Icon(Icons.map),
                          title: Text(
                            'Roadtrip planner',
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold),
                          ),
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ListTile(
                      leading: const Icon(Icons.business),
                      title: Text(
                        'Business Providers',
                        style:
                            GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                      ),
                      onTap: () {},
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ListTile(
                      leading: const Icon(Icons.shopping_cart_outlined),
                      title: Text(
                        'Shop',
                        style:
                            GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                      ),
                      onTap: () {},
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ListTile(
                      leading: const Icon(Icons.contact_mail),
                      title: Text(
                        'Contact us',
                        style:
                            GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                      ),
                      onTap: () {},
                    ),
                    const SizedBox(
                      height: 325,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xfff51957),
                        ),
                        child: Text(
                          'Sign in',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xfff51957),
                        ),
                        child: Text(
                          'Add listing',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              backgroundColor: themeModel.isDark ? Colors.black : Colors.white,
              body: CustomScrollView(
                controller: _scrollController,
                slivers: <Widget>[
                  SliverAppBar(
                    expandedHeight: MediaQuery.of(context).size.height * 0.25,
                    pinned: true,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0, top: 10.0),
                        child: IconButton(
                          icon: const Icon(
                            Icons.menu,
                            color: Color(0xfff51957),
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
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.03,
                          bottom: 16.0
                      ),
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'LekkeR Kampplekke',
                            style: GoogleFonts.montserrat(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _textColor,
                            ),
                          ),
                          Text(
                            'Best Campgrounds in South Africa',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              color: _textColor,
                            ),
                          ),
                        ],
                      ),
                      background: Image.asset(
                        'images/homepage_banner.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.03),
                  ),
                  SliverPersistentHeader(
                    delegate: _SearchBarDelegate(),
                    pinned: true,
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: 40,
                          bottom: 20,
                          left: MediaQuery.of(context).size.width * 0.03),
                      child: Text(
                        'Popular Listings',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color:
                              themeModel.isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 230,
                      child: _isLoading
                          ? Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: ListView.builder(
                          itemCount: 9,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (_, __) => Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SizedBox(
                              width: 250,
                              child: Card(child: Container()),
                            ),
                          ),
                        ),
                      )
                          : _popularListings.isEmpty
                          ? Center(
                        child: Text(
                          'No popular listings available',
                          style: GoogleFonts.montserrat(
                            color: themeModel.isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      )
                          : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _popularListings.length,
                        itemBuilder: (context, index) {
                          return PopularListingItem(
                            document: _popularListings[index],
                            themeModel: themeModel,
                          );
                        },
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: 40,
                          bottom: 20,
                          left: MediaQuery.of(context).size.width * 0.03),
                      child: Text(
                        'Explore Special Campsites Categories',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color:
                              themeModel.isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 125, // Increase the height
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 10,
                        // Increase the itemCount by 1 to accommodate the button
                        itemBuilder: (BuildContext context, int index) {
                          if (index == 9) {
                            // If it's the last item, return the button
                            return Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: SizedBox(
                                width: 150, // Increase the width
                                child: Card(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Add your onPressed function here
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xfff51957),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        const Icon(
                                          Icons.arrow_forward,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          'All',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: SizedBox(
                                width: 150, // Increase the width
                                child: GestureDetector(
                                  onTap: () {
                                    String category = index == 0
                                        ? 'Swimming Pool'
                                        : index == 1
                                        ? 'Pets Allowed'
                                        : index == 2
                                        ? 'Hiking'
                                        : index == 3
                                        ? 'Braai Place'
                                        : index == 4
                                        ? 'Jacuzzi'
                                        : index == 5
                                        ? 'Glamping'
                                        : index == 6
                                        ? 'Signal'
                                        : index == 7
                                        ? 'Beach Camping'
                                        : 'Fishing'; // This is the category name
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SearchScreen(category),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          // Replace with your icons
                                          index == 0
                                              ? Icons.waves
                                              : index == 1
                                                  ? Icons.pets
                                                  : index == 2
                                                      ? Icons.hiking
                                                      : index == 3
                                                          ? Icons
                                                              .local_fire_department
                                                          : index == 4
                                                              ? Icons
                                                                  .bathtub
                                                              : index == 5
                                                                  ? Icons.house
                                                                  : index == 6
                                                                      ? Icons
                                                                          .signal_cellular_alt
                                                                      : index == 7
                                                                          ? Icons
                                                                              .beach_access
                                                                          : Icons
                                                                              .water_drop,
                                          size: 30, // Increase the size
                                          color: index == 0
                                              ? Colors.blue
                                              : index == 1
                                                  ? Colors.brown
                                                  : index == 2
                                                      ? Colors.green
                                                      : index == 3
                                                          ? Colors
                                                              .deepOrangeAccent
                                                          : index == 4
                                                              ? Colors.blue
                                                              : index == 5
                                                                  ? Colors.indigo
                                                                  : index == 6
                                                                      ? Colors
                                                                          .purple
                                                                      : index == 7
                                                                          ? Colors
                                                                              .pink
                                                                          : Colors
                                                                              .blueAccent, // Replace with your colors
                                        ),
                                        Text(
                                          // Replace with your text labels
                                          index == 0
                                              ? 'Swimming Pool'
                                              : index == 1
                                                  ? 'Pets Allowed'
                                                  : index == 2
                                                      ? 'Hiking'
                                                      : index == 3
                                                          ? 'Braai Place'
                                                          : index == 4
                                                              ? 'Jacuzzi'
                                                              : index == 5
                                                                  ? 'Glamping'
                                                                  : index == 6
                                                                      ? 'Signal'
                                                                      : index == 7
                                                                          ? 'Beach Camping'
                                                                          : 'Fishing',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: themeModel.isDark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: 40,
                          bottom: 20,
                          left: MediaQuery.of(context).size.width * 0.03),
                      child: Text(
                        'Explore Locations',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color:
                              themeModel.isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 9,
                        itemBuilder: (BuildContext context, int index) {
                          String imagePath = '';
                          String title = '';
                          switch (index) {
                            case 0:
                              imagePath = 'images/western_cape.png';
                              title = 'Western Cape';
                              break;
                            case 1:
                              imagePath = 'images/northern_cape.png';
                              title = 'Northern Cape';
                              break;
                            case 2:
                              imagePath = 'images/north_west.png';
                              title = 'North West';
                              break;
                            case 3:
                              imagePath = 'images/mpumalanga.png';
                              title = 'Mpumalanga';
                              break;
                            case 4:
                              imagePath = 'images/limpopo.png';
                              title = 'Limpopo';
                              break;
                            case 5:
                              imagePath = 'images/kzn.png';
                              title = 'KwaZulu-Natal';
                              break;
                            case 6:
                              imagePath = 'images/gauteng.png';
                              title = 'Gauteng';
                              break;
                            case 7:
                              imagePath = 'images/free_state.jpg';
                              title = 'Free State';
                              break;
                            case 8:
                              imagePath = 'images/eastern_cape.png';
                              title = 'Eastern Cape';
                              break;
                          }
                          return Padding(
                            padding: const EdgeInsets.only(
                              top: 10.0,
                              left: 10.0,
                              right: 10.0,
                              bottom: 5.0,
                            ),
                            child: SizedBox(
                              width: 250,
                              child: GestureDetector(
                                onTap: () {
                                  String location = index == 0
                                      ? 'Western Cape'
                                      : index == 1
                                      ? 'Northern Cape'
                                      : index == 2
                                      ? 'North West'
                                      : index == 3
                                      ? 'Mpumalanga'
                                      : index == 4
                                      ? 'Limpopo'
                                      : index == 5
                                      ? 'KwaZulu-Natal'
                                      : index == 6
                                      ? 'Gauteng'
                                      : index == 7
                                      ? 'Free State'
                                      : 'Eastern Cape'; // This is the location name
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SearchScreen(location),
                                    ),
                                  );
                                },
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Container(
                                          width: 225,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            image: DecorationImage(
                                              image: AssetImage(imagePath),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          title,
                                          style: GoogleFonts.montserrat(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: themeModel.isDark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class PopularListingItem extends StatefulWidget {
  final DocumentSnapshot document;
  final ThemeModel themeModel;

  const PopularListingItem({Key? key, required this.document, required this.themeModel}) : super(key: key);

  @override
  _PopularListingItemState createState() => _PopularListingItemState();
}

class _PopularListingItemState extends State<PopularListingItem> with AutomaticKeepAliveClientMixin {
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    _loadImageUrl();
  }

  Future<void> _loadImageUrl() async {
    final url = await _getPreviewImageUrl(widget.document);
    if (mounted) {
      setState(() {
        imageUrl = url;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Map<String, dynamic> data = widget.document.data() as Map<String, dynamic>;

    return Padding(
      padding: const EdgeInsets.only(
        top: 10.0,
        left: 10.0,
        right: 10.0,
        bottom: 5.0,
      ),
      child: SizedBox(
        width: 250,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CampsiteDetailsPage(widget.document),
              ),
            );
          },
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 5),
                  Container(
                    width: 225,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: imageUrl == null
                        ? Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    )
                        : Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(child: Text('Error loading image', style: GoogleFonts.montserrat()));
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    data['name'],
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.themeModel.isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xfff51957)),
                      const SizedBox(width: 4),
                      Text(
                        data['main_fall_under'],
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: widget.themeModel.isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Future<String?> _getPreviewImageUrl(DocumentSnapshot campsite) async {
    print('_getPreviewImageUrl called for campsite ${campsite.id}');
    final storage = FirebaseStorage.instance;
    final sitesFolderRef =
    storage.ref().child('sites'); // Access the 'sites' folder
    final campsiteFolderRef = sitesFolderRef
        .child(campsite.id); // Access the specific campsite folder
    final result = await campsiteFolderRef.listAll();
    final imageItems = result.items
        .where((item) =>
    item.fullPath.toLowerCase().endsWith('.jpg') ||
        item.fullPath.toLowerCase().endsWith('.jpeg') ||
        item.fullPath.toLowerCase().endsWith('.webp') ||
        item.fullPath.toLowerCase().endsWith('.png'))
        .toList();
    if (imageItems.isNotEmpty) {
      final previewImageRef = imageItems.first;
      return await previewImageRef.getDownloadURL();
    }
    print('URL fetched for campsite ${campsite.id}');
    return null;
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'What are you looking for?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(color: Colors.grey[900]!),
                ),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            Container(
              height: 40.0, // Adjust as needed
              decoration: BoxDecoration(
                color: const Color(0xfff51957),
                borderRadius: BorderRadius.circular(15.0), // 15% border radius
              ),
              child: IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  // Navigate to the search screen with the query
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchScreen(_searchController.text)),
                  );
                },
                padding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 56.0;

  @override
  double get minExtent => 56.0;

  @override
  bool shouldRebuild(_SearchBarDelegate oldDelegate) => false;
}

