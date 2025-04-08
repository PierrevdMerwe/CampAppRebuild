import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/widgets/cached_firebase_image.dart';
import '../../shared/widgets/star_rating_widget.dart';
import '../services/favorite_service.dart';
import '../services/rating_service.dart';
import '../services/view_tracking_service.dart';
import '../widgets/comment_section_widget.dart';
import 'campsite_search_screen.dart';

class CampsiteDetailsPage extends StatefulWidget {
  final DocumentSnapshot campsite;

  const CampsiteDetailsPage(this.campsite, {super.key});

  @override
  _CampsiteDetailsPageState createState() => _CampsiteDetailsPageState();
}

class _CampsiteDetailsPageState extends State<CampsiteDetailsPage> with SingleTickerProviderStateMixin {
  late Future<List<String>> futureImages;
  bool _isFavorite = false;
  bool _isCheckingFavorite = true;
  final FavoriteService _favoriteService = FavoriteService();
  final RatingService _ratingService = RatingService();
  late AnimationController _favoriteAnimController;
  late Animation<double> _favoriteScaleAnimation;
  double _averageRating = 0;
  bool _isLoadingRating = true;
  int _totalReviews = 0;
  final ViewTrackingService _viewTrackingService = ViewTrackingService();
  bool _viewTracked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Track the view only once per session
    if (!_viewTracked) {
      _trackView();
      _viewTracked = true;
    }
  }

  @override
  void initState() {
    super.initState();
    futureImages = _getAllImageUrls(widget.campsite);
    // Create animation controller for heart icon
    _favoriteAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _favoriteScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
    ]).animate(_favoriteAnimController);

    // Check if this campsite is a favorite
    _checkFavoriteStatus();

    // Load the campsite's average rating
    _loadAverageRating();
  }

  @override
  void dispose() {
    _favoriteAnimController.dispose();
    super.dispose();
  }

  Future<void> _trackView() async {
    try {
      await _viewTrackingService.incrementViewCount(widget.campsite.id);
    } catch (e) {
      print('Error tracking view: $e');
    }
  }

  Future<void> _loadAverageRating() async {
    setState(() {
      _isLoadingRating = true;
    });

    try {
      final avgRating = await _ratingService.getCampsiteAverageRating(widget.campsite.id);
      final comments = await _ratingService.getCampsiteComments(widget.campsite.id);

      setState(() {
        _averageRating = avgRating;
        _totalReviews = comments.length;
        _isLoadingRating = false;
      });
    } catch (e) {
      print('Error loading average rating: $e');
      setState(() {
        _isLoadingRating = false;
      });
    }
  }

  Future<void> _checkFavoriteStatus() async {
    setState(() {
      _isCheckingFavorite = true;
    });

    try {
      _isFavorite = await _favoriteService.isCampsiteFavorite(widget.campsite.id);
    } catch (e) {
      print('Error checking favorite status: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingFavorite = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      final newStatus = await _favoriteService.toggleFavorite(widget.campsite.id);

      if (mounted) {
        setState(() {
          _isFavorite = newStatus;
        });

        // Play animation when adding to favorites
        if (_isFavorite) {
          _favoriteAnimController.forward(from: 0.0);
        }
      }
    } catch (e) {
      print('Error toggling favorite status: $e');
    }
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Campsite Details', style: GoogleFonts.montserrat()),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.red),
            onPressed: () {
              // Will be implemented later
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing will be implemented soon')),
              );
            },
          ),
        ],
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
                  height: MediaQuery.of(context).size.height * 0.4,
                  color: Colors.white,
                ),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}', style: GoogleFonts.montserrat());
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      CarouselSlider(
                        options: CarouselOptions(
                          aspectRatio: 1.5,
                          viewportFraction: 1.0,
                          enableInfiniteScroll: snapshot.data!.length > 1,
                          autoPlay: snapshot.data!.length > 1,
                          autoPlayInterval: const Duration(seconds: 5),
                        ),
                        items: snapshot.data!.map((imageUrl) {
                          return Builder(
                            builder: (BuildContext context) {
                              return CachedFirebaseImage(
                                firebaseUrl: imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
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
                                    height: MediaQuery.of(context).size.height * 0.4,
                                    child: CarouselSlider(
                                      options: CarouselOptions(
                                        aspectRatio: 1.5,
                                        enlargeCenterPage: true,
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
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Rating
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${widget.campsite['name']}',
                                    style: GoogleFonts.montserrat(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (_isLoadingRating)
                                    const SizedBox(
                                      width: 80,
                                      child: LinearProgressIndicator(
                                        color: Color(0xff2e6f40),
                                        backgroundColor: Color(0xFFE0E0E0),
                                      ),
                                    )
                                  else
                                    Row(
                                      children: [
                                        StarRating(
                                          rating: _averageRating.round(),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '$_totalReviews ${_totalReviews == 1 ? 'review' : 'reviews'}',
                                          style: GoogleFonts.montserrat(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            // Price
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xff2e6f40).withValues(alpha: .1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'R${NumberFormat("#,##0").format(int.parse(widget.campsite['price']))}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xff2e6f40),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Tags
                        _buildTagRow(widget.campsite['tags']),

                        const SizedBox(height: 16),

                        // Location
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Color(0xff2e6f40), size: 20),
                            const SizedBox(width: 8),
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
                                    decoration: TextDecoration.underline,
                                    decorationColor: const Color(0xff2e6f40),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Favorite button
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: ScaleTransition(
                                  scale: _favoriteScaleAnimation,
                                  child: Icon(
                                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                                label: Text(
                                  _isFavorite ? 'Saved' : 'Save',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isFavorite ? Colors.red : const Color(0xff2e6f40),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _isCheckingFavorite ? null : _toggleFavorite,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Description
                        Text(
                          'About this campsite',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.campsite['description'] ?? 'No description available',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Pricing and details
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Campsite Details',
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                FontAwesomeIcons.moneyBill,
                                'Rates From',
                                'R${widget.campsite['price']}',
                              ),
                              const SizedBox(height: 12),
                              _buildDetailRow(
                                Icons.phone,
                                'Contact',
                                widget.campsite['telephone'] ?? 'Not provided',
                                isPhone: true,
                              ),
                              const SizedBox(height: 12),
                              _buildDetailRow(
                                Icons.location_city,
                                'Province',
                                widget.campsite['province'] ?? 'Not specified',
                              ),
                              const SizedBox(height: 12),
                              _buildDetailRow(
                                Icons.signal_cellular_alt,
                                'Cell Reception',
                                widget.campsite['signal'] ?? 'Unknown',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildBookNowButton(),
                  // Comments Section
                  CommentSection(
                    campsiteId: widget.campsite.id,
                    campsiteName: widget.campsite['name'],
                  ),

                  const SizedBox(height: 32),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isPhone = false}) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xff2e6f40), size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.montserrat(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            isPhone ? GestureDetector(
              onTap: () => _launchPhone(value),
              child: Text(
                value,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: const Color(0xff2e6f40),
                  decoration: TextDecoration.underline,
                ),
              ),
            ) : Text(
              value,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber.replaceAll(' ', ''));
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      print('Could not launch $phoneUri');
    }
  }

  Widget _buildBookNowButton() {
    // Safely check if the book_link field exists and is not empty
    final data = widget.campsite.data() as Map<String, dynamic>?;
    final bookLink = data != null && data.containsKey('book_link') ? data['book_link'] : null;

    if (bookLink == null || bookLink.isEmpty) {
      return const SizedBox.shrink(); // Don't show button if no link
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.open_in_new, color: Colors.white),
          label: Text(
            'Book Now',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff2e6f40),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => _launchUrl(bookLink),
        ),
      ),
    );
  }

  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);

    try {
      // Track the click before launching URL
      final bookingTrackingService = ViewTrackingService();
      await bookingTrackingService.incrementBookingLinkClicks(widget.campsite.id);

      // Launch the URL
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch booking link')),
        );
      }
    } catch (e) {
      print('Error tracking or launching booking URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch booking link')),
      );
    }
  }

  Widget _buildTagRow(List<dynamic> tags) {
    final excludedTags = [
      'Self Catering',
      'Pet Friendly',
      'Only Campsites',
      'Pets With Arrangements',
      'Campsites'
    ];

    final includedTags = tags.where((tag) => !excludedTags.contains(tag)).toList();
    const int maxVisibleTags = 3; // Maximum tags to show before using the +X button

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

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...includedTags.take(maxVisibleTags).map((tag) {
          final IconData icon = tagIcons[tag] ?? Icons.tag;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xff2e6f40).withValues(alpha: .1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: const Color(0xff2e6f40)),
                const SizedBox(width: 4),
                Text(
                  tag,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: const Color(0xff2e6f40),
                  ),
                ),
              ],
            ),
          );
        }).toList(),

        // Add the +X button if there are more tags
        if (includedTags.length > maxVisibleTags)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xff2e6f40).withValues(alpha: .1),
              shape: BoxShape.circle,
            ),
            child: GestureDetector(
              onTap: () => _showAllTags(includedTags),
              child: Text(
                '+${includedTags.length - maxVisibleTags}',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: const Color(0xff2e6f40),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showAllTags(List<dynamic> tags) {
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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
              'All Amenities',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              )
          ),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((tag) {
                IconData icon = tagIcons[tag] ?? Icons.tag;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xff2e6f40).withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xff2e6f40).withValues(alpha: .2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 18, color: const Color(0xff2e6f40)),
                      const SizedBox(width: 6),
                      Text(
                        tag,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: const Color(0xff2e6f40),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                overlayColor: const Color(0xff2e6f40).withValues(alpha: .1),
              ),
              child: Text(
                  'Close',
                  style: GoogleFonts.montserrat(
                    color: const Color(0xff2e6f40),
                    fontWeight: FontWeight.bold,
                  )
              ),
            ),
          ],
        );
      },
    );
  }
}