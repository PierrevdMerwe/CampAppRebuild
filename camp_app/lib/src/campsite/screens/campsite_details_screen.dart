import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../shared/widgets/cached_firebase_image.dart';
import 'campsite_search_screen.dart';

class CampsiteDetailsPage extends StatefulWidget {
  final DocumentSnapshot campsite;

  const CampsiteDetailsPage(this.campsite, {super.key});

  @override
  _CampsiteDetailsPageState createState() => _CampsiteDetailsPageState();
}

class _CampsiteDetailsPageState extends State<CampsiteDetailsPage> {
  late Future<List<String>> futureImages;

  @override
  void initState() {
    super.initState();
    futureImages = _getAllImageUrls(widget.campsite);
  }

  Future<List<String>> _getAllImageUrls(DocumentSnapshot campsite) async {
    final storage = FirebaseStorage.instance;
    final sitesFolderRef = storage.ref().child('sites');
    final campsiteFolderRef = sitesFolderRef.child(campsite.id);
    final result = await campsiteFolderRef.listAll();
    final imageItems = result.items
        .where((item) =>
            item.fullPath.toLowerCase().endsWith('.jpg') ||
            item.fullPath.toLowerCase().endsWith('.jpeg') ||
            item.fullPath.toLowerCase().endsWith('.webp') ||
            item.fullPath.toLowerCase().endsWith('.png'))
        .toList();
    List<String> imageUrls = [];
    for (var item in imageItems) {
      String url = await item.getDownloadURL();
      imageUrls.add(url);
    }
    return imageUrls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Campsite Details', style: GoogleFonts.montserrat()),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<List<String>>(
          future: futureImages,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height *
                      0.4,
                  color: Colors.white,
                ),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}', style: GoogleFonts.montserrat());
            } else {
              return Column(
                children: [
                  Stack(
                    children: [
                      CarouselSlider(
                        options: CarouselOptions(
                          aspectRatio: 1.5,
                        ),
                        items: snapshot.data!.map((imageUrl) {
                          return Builder(
                            builder: (BuildContext context) {
                              return CachedFirebaseImage(
                                firebaseUrl: imageUrl,
                                fit: BoxFit.cover,
                                placeholder: const CircularProgressIndicator(),
                              );
                            },
                          );
                        }).toList(),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff2e6f40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    'All photos of ${widget.campsite['name']}',
                                    style: GoogleFonts.montserrat(),
                                  ),
                                  content: SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.4,
                                    child: CarouselSlider(
                                      options: CarouselOptions(
                                        aspectRatio: 1.5,
                                      ),
                                      items: snapshot.data!.map((imageUrl) {
                                        return Builder(
                                          builder: (BuildContext context) {
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 4.0),
                                              child: CachedFirebaseImage(
                                                firebaseUrl: imageUrl,
                                                fit: BoxFit.cover,
                                                placeholder: const CircularProgressIndicator(),
                                              )
                                            );
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Close',
                                          style: GoogleFonts.montserrat(
                                            color: const Color(0xff2e6f40),
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text('See all photos',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${widget.campsite['name']}',
                        style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'R${NumberFormat("#,##0").format(int.parse(widget.campsite['price']))}',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff2e6f40),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  _buildTagRow(widget.campsite['tags']),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0, right: 4.0),
                        child: Icon(Icons.location_on, color: Color(0xff2e6f40), size: 20),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchScreen(
                                  widget.campsite['main_fall_under'],
                                  initialShowMap: true,
                                  initialCenter: LatLng(
                                    widget.campsite['location'].latitude,
                                    widget.campsite['location'].longitude,
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Text(
                            widget.campsite['main_fall_under'],
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black, // Changed to black
                              decoration: TextDecoration.underline,
                              decorationColor: const Color(0xff2e6f40),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () {
                          // TODO: Implement share functionality
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1),
                    child: const Divider(thickness: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      widget.campsite['description'] ?? 'No description available',
                      style: GoogleFonts.montserrat(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1),
                    child: const Divider(thickness: 1),
                  ),
                  ListTile(
                    leading: const Icon(Icons.attach_money, color: Color(0xff2e6f40)),
                    title: Text(
                      'Rates From: R${widget.campsite['price']}',
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.local_fire_department, color: Color(0xff2e6f40)),
                    title: Text(
                      'Campsite Rates Per: TODO: pay per what on firebase?',
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildTagRow(List<dynamic> tags) {
    final excludedTags = [
      'Self Catering',
      'Pet Friendly',
      'Only Campsites',
      'Pets With Arrangements',
      'Campsites'
    ];
    final includedTags =
    tags.where((tag) => !excludedTags.contains(tag)).toList();
    final tagIcons = {
      'Braai Place': Icons.local_fire_department,
      'Swimming Pool': Icons.pool,
      'Signal': Icons.signal_cellular_alt,
      'Fishing': Icons.water,
      'Hiking': Icons.hiking,
      'Jacuzzi': Icons.bathtub,
      'Glamping': Icons.house,
      'Beach Camping': Icons.beach_access,
    };

    IconData? icon;
    String firstTag = '';
    if (includedTags.isNotEmpty) {
      firstTag = includedTags[0];
      icon = tagIcons[firstTag];
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Row(
        children: [
          if (icon != null)
            GestureDetector(
              onTap: () {
                setState(() {
                  // Update the query
                  // Perform a new search
                });
              },
              child: Container(
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  color: const Color(0xff2e6f40),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: Colors.white),
                    const SizedBox(width: 5.0),
                    Text(
                      firstTag,
                      style: GoogleFonts.montserrat(
                        fontSize: 16.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(width: 10.0),
          if (includedTags.length > 1)
            InkWell(
              onTap: () {
                if (includedTags.length > 1) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Other Tags', style: GoogleFonts.montserrat()),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: includedTags.skip(1).map((tag) {
                              return ListTile(
                                leading: Row(
                                  mainAxisSize: MainAxisSize.min, // This will make the Row as small as possible
                                  children: [
                                    Icon(tagIcons[tag] ?? Icons.tag), // Use the corresponding icon
                                    const SizedBox(width: 5), // Adjust the space as needed
                                    Text(tag, style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xff2e6f40)
                                    )),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Close', style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xff2e6f40)
                            )),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: const BoxDecoration(
                  color: Color(0xff2e6f40),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '+${includedTags.length - 1}',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}