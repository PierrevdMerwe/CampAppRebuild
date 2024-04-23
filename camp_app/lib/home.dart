import 'dart:async';

import 'package:camp_app/search_result.dart';
import 'package:camp_app/theme_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    FirebaseFirestore.instance
        .collection('sites')
        .snapshots()
        .listen((snapshot) {
      _streamController.add(snapshot);
    });
  }

  @override
  void dispose() {
    _streamController.close();
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
                slivers: <Widget>[
                  SliverAppBar(
                    expandedHeight: MediaQuery.of(context).size.height * 0.25,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Image.asset(
                        'images/homepage_banner.jpg',
                        fit: BoxFit.cover,
                      ),
                      titlePadding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.03,
                          bottom: 16.0),
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'LekkeR Kampplekke',
                            style: GoogleFonts.montserrat(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Best Campgrounds in South Africa',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                            ),
                          ),
                        ],
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
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _streamController.stream,
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Text(
                              'Something went wrong loading the campsites',
                              style: GoogleFonts.montserrat(
                                color: themeModel.isDark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Shimmer.fromColors(
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
                            );
                          }

                          return ListView(
                            scrollDirection: Axis.horizontal,
                            children: snapshot.data!.docs
                                .map((DocumentSnapshot document) {
                              Map<String, dynamic> data =
                                  document.data() as Map<String, dynamic>;
                              return FutureBuilder<String?>(
                                future: _getPreviewImageUrl(document),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(color: Colors.white),
                                    );
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
                                                      BorderRadius.circular(
                                                          15.0),
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                        snapshot.data!),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                data['name'],
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: themeModel.isDark
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(Icons.location_on,
                                                      color: Color(0xfff51957)),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    data['main_fall_under'],
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      fontSize: 14,
                                                      color: themeModel.isDark
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
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
                              padding: const EdgeInsets.all(20.0),
                              child: SizedBox(
                                width: 100, // Increase the width
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
                              padding: const EdgeInsets.all(20.0),
                              child: SizedBox(
                                width: 100, // Increase the width
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
                                                    ? Icons.forest
                                                    : index == 3
                                                        ? Icons
                                                            .local_fire_department
                                                        : index == 4
                                                            ? Icons
                                                                .shopping_cart
                                                            : index == 5
                                                                ? Icons.school
                                                                : index == 6
                                                                    ? Icons
                                                                        .local_cafe
                                                                    : index == 7
                                                                        ? Icons
                                                                            .movie
                                                                        : Icons
                                                                            .music_note,
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
                                                                            .brown, // Replace with your colors
                                      ),
                                      Text(
                                        // Replace with your text labels
                                        index == 0
                                            ? 'River'
                                            : index == 1
                                                ? 'Pets'
                                                : index == 2
                                                    ? 'Bush'
                                                    : index == 3
                                                        ? 'Braai'
                                                        : index == 4
                                                            ? 'Shopping'
                                                            : index == 5
                                                                ? 'School'
                                                                : index == 6
                                                                    ? 'Cafe'
                                                                    : index == 7
                                                                        ? 'Movie'
                                                                        : 'Music',
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
                              title = 'Kwazulu-Natal';
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
        Positioned(
          top: 40.0,
          right: 10.0,
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
    );
  }

  Future<String?> _getPreviewImageUrl(DocumentSnapshot campsite) async {
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
  double get maxExtent => 60.0;

  @override
  double get minExtent => 60.0;

  @override
  bool shouldRebuild(_SearchBarDelegate oldDelegate) => false;
}

