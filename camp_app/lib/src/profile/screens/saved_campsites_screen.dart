import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import '../../campsite/services/favorite_service.dart';
import '../../campsite/screens/campsite_details_screen.dart';
import '../../shared/widgets/cached_firebase_image.dart';

class SavedCampsitesScreen extends StatefulWidget {
  const SavedCampsitesScreen({super.key});

  @override
  State<SavedCampsitesScreen> createState() => _SavedCampsitesScreenState();
}

class _SavedCampsitesScreenState extends State<SavedCampsitesScreen> {
  final FavoriteService _favoriteService = FavoriteService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<List<DocumentSnapshot>> _favoriteCampsitesFuture;

  @override
  void initState() {
    super.initState();
    _favoriteCampsitesFuture = _loadFavoriteCampsites();
  }

  Future<List<DocumentSnapshot>> _loadFavoriteCampsites() async {
    try {
      // Get the IDs of favorite campsites
      final favoriteIds = await _favoriteService.getFavoriteCampsites();

      if (favoriteIds.isEmpty) {
        return [];
      }

      // Fetch each campsite document
      final List<DocumentSnapshot> campsites = [];

      // Use batching to avoid too many parallel requests
      const int batchSize = 10;
      for (int i = 0; i < favoriteIds.length; i += batchSize) {
        final int end = (i + batchSize < favoriteIds.length) ? i + batchSize : favoriteIds.length;
        final batch = favoriteIds.sublist(i, end);

        final queries = await Future.wait(
            batch.map((id) => _firestore.collection('sites').doc(id).get())
        );

        campsites.addAll(queries.where((doc) => doc.exists));
      }

      return campsites;
    } catch (e) {
      print('Error loading favorite campsites: $e');
      return [];
    }
  }

  Future<String?> _getPreviewImageUrl(DocumentSnapshot campsite) async {
    try {
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

      if (imageItems.isNotEmpty) {
        final previewImageRef = imageItems.first;
        return await previewImageRef.getDownloadURL();
      }

      return null;
    } catch (e) {
      print('Error getting preview image: $e');
      return null;
    }
  }

  Future<void> _refreshFavorites() async {
    setState(() {
      _favoriteCampsitesFuture = _loadFavoriteCampsites();
    });
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
              const SizedBox(width: 10.0),
              if (includedTags.length > 1)
                Container(
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
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'R${NumberFormat("#,##0").format(int.parse(price))}',
              style: GoogleFonts.montserrat(
                color: const Color(0xff2e6f40),
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff2e6f40)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Saved Campsites',
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _refreshFavorites();
        },
        child: FutureBuilder<List<DocumentSnapshot>>(
          future: _favoriteCampsitesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: ListView.builder(
                  itemCount: 3,
                  itemBuilder: (_, __) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading saved campsites',
                  style: GoogleFonts.montserrat(),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No saved campsites yet',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the heart icon on a campsite to save it',
                      style: GoogleFonts.montserrat(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final campsite = snapshot.data![index];
                  return FutureBuilder<String?>(
                    future: _getPreviewImageUrl(campsite),
                    builder: (context, imageSnapshot) {
                      if (imageSnapshot.connectionState == ConnectionState.waiting) {
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
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CampsiteDetailsPage(campsite),
                                ),
                              ).then((_) => _refreshFavorites());
                            },
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
                                    CachedFirebaseImage(
                                      firebaseUrl: imageSnapshot.data!,
                                      height: 200.0,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: const SizedBox(
                                        height: 200.0,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: Color(0xff2e6f40),
                                          ),
                                        ),
                                      ),
                                      errorWidget: Container(
                                        height: 200.0,
                                        color: Colors.grey[300],
                                        child: Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, left: 4),
                                    child: Text(
                                      campsite['name'],
                                      style: GoogleFonts.montserrat(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    contentPadding:
                                    const EdgeInsets.only(left: 4),
                                    leading: const Icon(
                                        Icons.location_pin,
                                        color: Color(0xff2e6f40)),
                                    title: Text(
                                      campsite['main_fall_under'],
                                      style: GoogleFonts.montserrat(),
                                    ),
                                  ),
                                  ListTile(
                                    contentPadding:
                                    const EdgeInsets.only(left: 4),
                                    leading: const Icon(Icons.phone,
                                        color: Color(0xff2e6f40)),
                                    title: Text(
                                      campsite['telephone'],
                                      style: GoogleFonts.montserrat(),
                                    ),
                                  ),
                                  if (campsite['tags']
                                      .contains('Pet Friendly') ||
                                      campsite['tags']
                                          .contains(
                                          'Pets With Arrangements'))
                                    ListTile(
                                      contentPadding:
                                      const EdgeInsets.only(
                                          left: 4),
                                      leading: const Icon(Icons.pets,
                                          color: Color(0xff2e6f40)),
                                      title: Text(
                                        campsite['tags']
                                            .contains(
                                            'Pet Friendly')
                                            ? 'Pet Friendly'
                                            : 'Pets With Arrangements',
                                        style: GoogleFonts.montserrat(),
                                      ),
                                    )
                                  else
                                    const ListTile(
                                      contentPadding:
                                      EdgeInsets.only(left: 4),
                                      leading: Icon(
                                          Icons.do_not_disturb_alt,
                                          color: Color(0xff2e6f40)),
                                      title: Text('No Pets Allowed'),
                                    ),
                                  ListTile(
                                    contentPadding:
                                    const EdgeInsets.only(left: 4),
                                    leading: const Icon(
                                        Icons.check_circle_outline,
                                        color: Color(0xff2e6f40)),
                                    title: Text(
                                      campsite['tags']
                                          .contains(
                                          'Only Campsites')
                                          ? 'Only Campsites'
                                          : campsite['tags']
                                          .contains(
                                          'Self Catering') &&
                                          campsite['tags']
                                              .contains(
                                              'Campsites')
                                          ? 'Campsites & Self Catering'
                                          : 'Self Catering',
                                      style: GoogleFonts.montserrat(),
                                    ),
                                  ),
                                  const Divider(),
                                  _buildTagRow(
                                      campsite['tags'],
                                      campsite['price']),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}