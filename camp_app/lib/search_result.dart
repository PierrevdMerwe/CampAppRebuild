import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SearchScreen extends StatefulWidget {
  final String query;

  const SearchScreen(this.query, {Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late Future<List<DocumentSnapshot>> futureResults;

  @override
  void initState() {
    super.initState();
    futureResults = performSearch(widget.query);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search results for "${widget.query}"'),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: futureResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: ListView.builder(
                itemCount: 10, // This can be adjusted based on your needs
                itemBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 5.0,
                    child: ListTile(
                      title: Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: 12.0,
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xfff51957),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          // Implement your filter functionality here
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.filter_list, color: Colors.white),
                            Text('Filter',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xfff51957),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          // Implement your map functionality here
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.map, color: Colors.white),
                            Text('Map', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${snapshot.data!.length} Items Found',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      DropdownButton<String>(
                        hint: const Text('Sort by'),
                        items: <String>[
                          'Price: Low to High',
                          'Price: High to Low',
                          'Rating',
                          'A-Z',
                          'Z-A'
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (_) {},
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder<String?>(
                        future: _getPreviewImageUrl(snapshot.data![index]),
                        builder: (context, imageSnapshot) {
                          if (imageSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: double.infinity,
                                height: 200.0,
                                color: Colors.white,
                              ),
                            );
                          } else if (imageSnapshot.hasError) {
                            return Text('Error: ${imageSnapshot.error}');
                          } else {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Card(
                                elevation: 5.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (imageSnapshot.data != null)
                                      Image.network(
                                        imageSnapshot.data!,
                                        height: 200.0,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8.0, left: 4),
                                      child: Text(
                                        snapshot.data![index]['name'],
                                        style: GoogleFonts.montserrat(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    ListTile(
                                      contentPadding:
                                          const EdgeInsets.only(left: 4),
                                      leading: const Icon(Icons.location_pin,
                                          color: Color(0xfff51957)),
                                      title: Text(
                                        snapshot.data![index]['main_fall_under'],
                                        style: GoogleFonts.montserrat(),
                                      ),
                                    ),
                                    ListTile(
                                      contentPadding:
                                          const EdgeInsets.only(left: 4),
                                      leading: const Icon(Icons.phone,
                                          color: Color(0xfff51957)),
                                      title: Text(
                                        snapshot.data![index]['telephone'],
                                        style: GoogleFonts.montserrat(),
                                      ),
                                    ),
                                    if (snapshot.data![index]['tags']
                                            .contains('Pet Friendly') ||
                                        snapshot.data![index]['tags']
                                            .contains('Pets With Arrangements'))
                                      ListTile(
                                        contentPadding:
                                            const EdgeInsets.only(left: 4),
                                        leading: const Icon(Icons.pets,
                                            color: Color(0xfff51957)),
                                        title: Text(
                                          snapshot.data![index]['tags']
                                                  .contains('Pet Friendly')
                                              ? 'Pet Friendly'
                                              : 'Pets With Arrangements',
                                          style: GoogleFonts.montserrat(),
                                        ),
                                      )
                                    else
                                      const ListTile(
                                        contentPadding: EdgeInsets.only(left: 4),
                                        leading: Icon(Icons.do_not_disturb_alt,
                                            color: Color(0xfff51957)),
                                        title: Text('No Pets Allowed'),
                                      ),
                                    ListTile(
                                      contentPadding:
                                          const EdgeInsets.only(left: 4),
                                      leading: const Icon(
                                          Icons.check_circle_outline,
                                          color: Color(0xfff51957)),
                                      title: Text(
                                        snapshot.data![index]['tags']
                                                .contains('Only Campsites')
                                            ? 'Only Campsites'
                                            : snapshot.data![index]['tags']
                                                        .contains(
                                                            'Self Catering') &&
                                                    snapshot.data![index]['tags']
                                                        .contains('Campsites')
                                                ? 'Campsites & Self Catering'
                                                : 'Self Catering',
                                        style: GoogleFonts.montserrat(),
                                      ),
                                    ),
                                    const Divider(),
                                    _buildTagRow(snapshot.data![index]['tags'], snapshot.data![index]['price']),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Future<List<DocumentSnapshot>> performSearch(String query) async {
    query = query.toLowerCase();
    List<DocumentSnapshot> results = [];

    await FirebaseFirestore.instance
        .collection('sites')
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        var data = doc.data();
        bool found = false;

        // Check 'fall_under' field
        if (data['fall_under'] != null &&
            data['fall_under']
                .map((e) => e.toString().toLowerCase())
                .contains(query)) {
          found = true;
        }

        // Check 'main_fall_under' field
        if (data['main_fall_under'] != null &&
            data['main_fall_under'].toLowerCase().contains(query)) {
          found = true;
        }

        // Check 'name' field
        if (data['name'] != null &&
            data['name'].toLowerCase().contains(query)) {
          found = true;
        }

        // Check 'tags' field
        if (data['tags'] != null &&
            data['tags']
                .map((e) => e.toString().toLowerCase())
                .contains(query)) {
          found = true;
        }

        if (found) {
          results.add(doc);
        }
      }
    });

    return results;
  }

  Widget _buildTagRow(List<dynamic> tags, String price) {
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
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: const Color(0xfff51957),
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
              const SizedBox(width: 10.0),
              if (includedTags.length > 1)
                InkWell(
                  onTap: () {
                    if (includedTags.length > 1) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Other Tags'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: includedTags.skip(1).map((tag) => Text(tag)).toList(),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Close'),
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
                      color: Color(0xfff51957),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'R${NumberFormat("#,##0").format(int.parse(price))}',
              style: GoogleFonts.montserrat(
                color: const Color(0xfff51957),
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
