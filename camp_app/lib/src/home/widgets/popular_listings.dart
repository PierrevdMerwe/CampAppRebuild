import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/config/theme/theme_model.dart';
import '../../campsite/services/campsite_service.dart';
import '../../campsite/screens/campsite_details_screen.dart';
import '../../campsite/models/campsite_model.dart';
import '../../shared/widgets/cached_firebase_image.dart';

class PopularListings extends StatefulWidget {
  const PopularListings({super.key});

  @override
  State<PopularListings> createState() => _PopularListingsState();
}

class _PopularListingsState extends State<PopularListings> {
  final CampsiteService _campsiteService = CampsiteService();
  bool _isLoading = true;
  List<CampsiteModel> _popularListings = [];

  @override
  void initState() {
    super.initState();
    _loadPopularListings();
  }

  Future<void> _loadPopularListings() async {
    try {
      final listings = await _campsiteService.getPopularCampsites();
      setState(() {
        _popularListings = listings;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading popular listings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: _isLoading
          ? _buildShimmer()
          : _popularListings.isEmpty
          ? _buildEmptyState()
          : _buildListingsList(),
    );
  }

  Widget _buildShimmer() {
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

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No popular listings available',
        style: GoogleFonts.montserrat(
          color: Provider.of<ThemeModel>(context).isDark
              ? Colors.white
              : Colors.black,
        ),
      ),
    );
  }

  Widget _buildListingsList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _popularListings.length,
      itemBuilder: (context, index) {
        return PopularListingItem(
          campsite: _popularListings[index],
        );
      },
    );
  }
}

class PopularListingItem extends StatefulWidget {
  final CampsiteModel campsite;

  const PopularListingItem({
    Key? key,
    required this.campsite,
  }) : super(key: key);

  @override
  _PopularListingItemState createState() => _PopularListingItemState();
}

class _PopularListingItemState extends State<PopularListingItem>
    with AutomaticKeepAliveClientMixin {
  final CampsiteService _campsiteService = CampsiteService();
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    _loadImageUrl();
  }

  Future<void> _loadImageUrl() async {
    try {
      final urls = await _campsiteService.getCampsiteImages(widget.campsite.id);
      if (mounted && urls.isNotEmpty) {
        setState(() {
          imageUrl = urls.first;
        });
      }
    } catch (e) {
      print('Error loading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeModel = Provider.of<ThemeModel>(context);

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
          onTap: () async {
            try {
              final doc = await _campsiteService.getCampsiteById(widget.campsite.id);
              if (mounted) {
                final docSnapshot = await FirebaseFirestore.instance
                    .collection('sites')
                    .doc(widget.campsite.id)
                    .get();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CampsiteDetailsPage(docSnapshot),
                  ),
                );
              }
            } catch (e) {
              print('Error navigating to details: $e');
            }
          },
          child: Card(
            color: themeModel.isDark ? Colors.black : const Color(0xffF5F8F5),
            child: SizedBox(
              height: 180,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                      child: _buildImage(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.campsite.name,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Color(0xff2e6f40),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.campsite.mainFallUnder,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: double.infinity,
      height: 120,
      color: const Color(0xffF5F8F5),
      child: imageUrl == null
          ? Shimmer.fromColors(
        baseColor: const Color(0xffF5F8F5),
        highlightColor: Colors.white,
        child: Container(
          color: Colors.white,
        ),
      )
          : CachedFirebaseImage(
        firebaseUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
          ),
        ),
        errorWidget: Center(
          child: Text('Error loading image', style: GoogleFonts.montserrat()),
        ),
      )
    );
  }

  @override
  bool get wantKeepAlive => true;
}