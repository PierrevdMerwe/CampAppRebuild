import 'package:camp_app/theme_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

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
  late AnimationController _controller;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
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
                    // Add your drawer items here
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
                      title: const Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'LekkeR Kampplekke',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          Text(
                            'Best Campgrounds in South Africa',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.03),
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
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                          color:
                              themeModel.isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 230, // Adjust as needed
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 9, // Number campsites in horizontal scroll
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: SizedBox(
                              width: 250, // Adjust as needed
                              child: Card(
                                child: Column(
                                  children: <Widget>[
                                    const SizedBox(height: 5,),
                                    Container(
                                      width: 225,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15.0),  // same border radius as the card
                                        image: const DecorationImage(
                                          image: AssetImage('images/homepage_banner.jpg'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Campsite Title $index',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Montserrat',
                                        color: themeModel.isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    Text(
                                      'Placeholder text for future information',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Montserrat',
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
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                          color: themeModel.isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 9,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: SizedBox(
                              width: 80,
                              child: Card(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      // Replace with your icons
                                      index == 0 ? Icons.waves :
                                      index == 1 ? Icons.pets :
                                      index == 2 ? Icons.forest :
                                      index == 3 ? Icons.home :
                                      index == 4 ? Icons.shopping_cart :
                                      index == 5 ? Icons.school :
                                      index == 6 ? Icons.local_cafe :
                                      index == 7 ? Icons.movie :
                                      Icons.music_note,
                                      size: 20,
                                      color: index == 0 ? Colors.blue :
                                      index == 1 ? Colors.brown :
                                      index == 2 ? Colors.green :
                                      index == 3 ? Colors.deepOrangeAccent :
                                      index == 4 ? Colors.blue :
                                      index == 5 ? Colors.indigo :
                                      index == 6 ? Colors.purple :
                                      index == 7 ? Colors.pink :
                                      Colors.brown, // Replace with your colors
                                    ),
                                    Text(
                                      // Replace with your text labels
                                      index == 0 ? 'River' :
                                      index == 1 ? 'Pets' :
                                      index == 2 ? 'Bush' :
                                      index == 3 ? 'Home' :
                                      index == 4 ? 'Shopping' :
                                      index == 5 ? 'School' :
                                      index == 6 ? 'Cafe' :
                                      index == 7 ? 'Movie' :
                                      'Music',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Montserrat',
                                        color: themeModel.isDark ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ],
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
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (_isMenuOpen) {
                  _controller.animateTo(1.0, duration: const Duration(milliseconds: 800));  // animate to end
                  Navigator.pop(context);
                } else {
                  _controller.animateTo(0.6, duration: const Duration(milliseconds: 800));  // animate to cross
                  _scaffoldKey.currentState!.openEndDrawer();
                }
                _isMenuOpen = !_isMenuOpen;
              });
            },
            child: SizedBox(
              width: 60.0, // adjust as needed
              height: 60.0, // adjust as needed
              child: Lottie.asset(
                'assets/menu.json',
                controller: _controller,
                onLoaded: (composition) {
                  _controller.duration = composition.duration;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'What are you looking for?',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide(color: Colors.grey[900]!),
          ),
        ),
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
