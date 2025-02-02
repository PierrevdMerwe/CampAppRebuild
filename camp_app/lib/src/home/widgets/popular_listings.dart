// lib/src/home/widgets/popular_listings.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/config/theme/theme_model.dart';
import '../../campsite/models/campsite_model.dart';
import '../../campsite/services/campsite_service.dart';
import '../../campsite/screens/campsite_details_screen.dart';

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
      setState(() {
        _isLoading = false;
      });
      // Handle error appropriately
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
      // Handle error appropriately
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
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CampsiteDetailsPage(widget.campsite as DocumentSnapshot<Object?>),
            ),
          ),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 5),
                  _buildImage(),
                  const SizedBox(height: 10),
                  Text(
                    widget.campsite.name,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: themeModel.isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                          Icons.location_on,
                          color: Color(0xff2e6f40)
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.campsite.mainFallUnder,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: themeModel.isDark ? Colors.white : Colors.black,
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

  Widget _buildImage() {
    return Container(
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
          return Center(
            child: Text(
              'Error loading image',
              style: GoogleFonts.montserrat(),
            ),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}