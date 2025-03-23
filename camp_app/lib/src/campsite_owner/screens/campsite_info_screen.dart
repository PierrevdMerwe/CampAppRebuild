import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../auth/providers/user_provider.dart';
import '../../shared/widgets/cached_firebase_image.dart';

class CampsiteInfoScreen extends StatefulWidget {
  const CampsiteInfoScreen({super.key});

  @override
  State<CampsiteInfoScreen> createState() => _CampsiteInfoScreenState();
}

class _CampsiteInfoScreenState extends State<CampsiteInfoScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  bool _isLoading = true;
  DocumentSnapshot? _campsiteDoc;
  List<String> _imageUrls = [];
  String? _selectedCampsiteId;

  @override
  void initState() {
    super.initState();
    _fetchUserCampsite();
  }

  Future<void> _fetchUserCampsite() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get owner's campsites
      final ownerDoc = await _firestore
          .collection('site_owners')
          .where('firebase_uid', isEqualTo: userProvider.user!.uid)
          .get();

      if (ownerDoc.docs.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final ownedSites = ownerDoc.docs.first.data()['owned_sites'] as List?;
      if (ownedSites == null || ownedSites.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get the first campsite for display
      _selectedCampsiteId = ownedSites[0].toString();
      final campsiteDoc = await _firestore.collection('sites').doc(_selectedCampsiteId).get();

      if (!campsiteDoc.exists) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Fetch images
      final imageUrls = await _getCampsiteImages(_selectedCampsiteId!);

      setState(() {
        _campsiteDoc = campsiteDoc;
        _imageUrls = imageUrls;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching campsite: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<String>> _getCampsiteImages(String campsiteId) async {
    try {
      final sitesFolderRef = _storage.ref().child('sites');
      final campsiteFolderRef = sitesFolderRef.child(campsiteId);
      final result = await campsiteFolderRef.listAll();

      final imageItems = result.items.where((item) =>
      item.fullPath.toLowerCase().endsWith('.jpg') ||
          item.fullPath.toLowerCase().endsWith('.jpeg') ||
          item.fullPath.toLowerCase().endsWith('.png') ||
          item.fullPath.toLowerCase().endsWith('.webp')).toList();

      List<String> imageUrls = [];
      for (var item in imageItems) {
        String url = await item.getDownloadURL();
        imageUrls.add(url);
      }
      return imageUrls;
    } catch (e) {
      print('Error fetching images: $e');
      return [];
    }
  }

  void _showEditListingForm() {
    if (_campsiteDoc == null) return;

    final data = _campsiteDoc!.data() as Map<String, dynamic>;

    // Controllers for the form fields
    final nameController = TextEditingController(text: data['name'] ?? '');
    final descriptionController = TextEditingController(text: data['description'] ?? '');
    final priceController = TextEditingController(text: data['price']?.toString() ?? '');
    final telephoneController = TextEditingController(text: data['telephone'] ?? '');
    final provinceController = TextEditingController(text: data['province'] ?? '');
    final signalController = TextEditingController(text: data['signal'] ?? '');

    // Save form data
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Edit Listing',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff2e6f40),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: GoogleFonts.montserrat(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: GoogleFonts.montserrat(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: 'Price',
                        labelStyle: GoogleFonts.montserrat(),
                        prefixText: 'R',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: telephoneController,
                      decoration: InputDecoration(
                        labelText: 'Telephone',
                        labelStyle: GoogleFonts.montserrat(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: provinceController,
                      decoration: InputDecoration(
                        labelText: 'Province',
                        labelStyle: GoogleFonts.montserrat(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: signalController,
                      decoration: InputDecoration(
                        labelText: 'Signal (Yes/No/Weak)',
                        labelStyle: GoogleFonts.montserrat(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xff2e6f40),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.montserrat(
                      color: const Color(0xff2e6f40),
                    ),
                  ),
                ),
                isSaving
                    ? const CircularProgressIndicator(color: Color(0xff2e6f40))
                    : ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      isSaving = true;
                    });

                    try {
                      // Create change request document
                      await _firestore.collection('listing_change_requests').add({
                        'campsite_id': _selectedCampsiteId,
                        'name': nameController.text,
                        'description': descriptionController.text,
                        'price': priceController.text,
                        'telephone': telephoneController.text,
                        'province': provinceController.text,
                        'signal': signalController.text,
                        'requested_at': FieldValue.serverTimestamp(),
                        'status': 'pending',
                        'owner_uid': Provider.of<UserProvider>(context, listen: false).user?.uid,
                      });

                      Navigator.pop(context); // Close the form

                      // Show confirmation dialog
                      _showConfirmationDialog();
                    } catch (e) {
                      print('Error submitting changes: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error submitting changes: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      setState(() {
                        isSaving = false;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2e6f40),
                  ),
                  child: Text(
                    'Submit',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(
                FontAwesomeIcons.circleCheck,
                color: Color(0xff2e6f40),
              ),
              const SizedBox(width: 10),
              Text(
                'Changes Submitted',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff2e6f40),
                ),
              ),
            ],
          ),
          content: Text(
            'Your changes have been submitted for review. Our team will approve them soon if there are no issues.',
            style: GoogleFonts.montserrat(),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2e6f40),
              ),
              child: Text(
                'OK',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Ensuring white background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff2e6f40)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Campsite Information',
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xff2e6f40)))
          : _campsiteDoc == null
          ? _buildNoCampsiteView()
          : _buildCampsiteDetails(),
    );
  }

  Widget _buildNoCampsiteView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            FontAwesomeIcons.campground,
            size: 64,
            color: Color(0xff2e6f40),
          ),
          const SizedBox(height: 24),
          Text(
            'No Campsite Found',
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Please add a campsite to manage its details.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampsiteDetails() {
    final data = _campsiteDoc!.data() as Map<String, dynamic>;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image carousel
          Stack(
            children: [
              _imageUrls.isEmpty
                  ? Container(
                width: double.infinity,
                height: 250,
                color: Colors.grey[300],
                child: Center(
                  child: Text(
                    'No Images Available',
                    style: GoogleFonts.montserrat(),
                  ),
                ),
              )
                  : CarouselSlider(
                options: CarouselOptions(
                  aspectRatio: 16 / 9,
                  viewportFraction: 1.0,
                  enableInfiniteScroll: _imageUrls.length > 1,
                  autoPlay: _imageUrls.length > 1,
                  autoPlayInterval: const Duration(seconds: 5),
                ),
                items: _imageUrls.map((imageUrl) {
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
                child: ElevatedButton.icon(
                  icon: const Icon(FontAwesomeIcons.image, size: 16, color: Colors.white),
                  label: Text(
                    'Manage Photos',
                    style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2e6f40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Implement photo management functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Photo management coming soon!'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        data['name'] ?? 'Unnamed Campsite',
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
                        'R${NumberFormat("#,##0").format(int.tryParse(data['price']?.toString() ?? '0') ?? 0)}',
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
                _buildTagsSection(data),

                const SizedBox(height: 24),

                // Edit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(FontAwesomeIcons.penToSquare, color: Colors.white),
                    label: Text(
                      'Edit Your Listing',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
                    onPressed: _showEditListingForm,
                  ),
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
                  data['description'] ?? 'No description available',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                // Campsite details
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
                        'R${data['price'] ?? '0'}',
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        FontAwesomeIcons.phone,
                        'Contact',
                        data['telephone'] ?? 'Not provided',
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        FontAwesomeIcons.locationDot,
                        'Province',
                        data['province'] ?? 'Not specified',
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        FontAwesomeIcons.signal,
                        'Cell Reception',
                        data['signal'] ?? 'Unknown',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection(Map<String, dynamic> data) {
    final List<dynamic> tags = data['tags'] ?? [];

    // Define excluded tags (these are shown in other sections)
    final excludedTags = [
      'Self Catering',
      'Pet Friendly',
      'Only Campsites',
      'Pets With Arrangements',
      'Campsites'
    ];

    // Filter included tags
    final includedTags = tags.where((tag) => !excludedTags.contains(tag)).toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: includedTags.map((tag) {
        IconData icon = FontAwesomeIcons.tag;

        // Assign specific icons based on tag
        if (tag == 'Braai Place') {
          icon = FontAwesomeIcons.fire;
        } else if (tag == 'Swimming Pool') {
          icon = FontAwesomeIcons.personSwimming;
        } else if (tag == 'Signal') {
          icon = FontAwesomeIcons.signal;
        } else if (tag == 'Fishing') {
          icon = FontAwesomeIcons.fish;
        } else if (tag == 'Hiking') {
          icon = FontAwesomeIcons.personHiking;
        } else if (tag == 'Jacuzzi') {
          icon = FontAwesomeIcons.hotTubPerson;
        } else if (tag == 'Glamping') {
          icon = FontAwesomeIcons.tent;
        } else if (tag == 'Beach Camping') {
          icon = FontAwesomeIcons.umbrella;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xff2e6f40).withValues(alpha: .1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(icon, size: 16, color: const Color(0xff2e6f40)),
              const SizedBox(width: 4),
              Text(
                tag.toString(),
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: const Color(0xff2e6f40),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        FaIcon(icon, color: const Color(0xff2e6f40), size: 20),
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
            Text(
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
}