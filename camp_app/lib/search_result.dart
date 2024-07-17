import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'campsite_details_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchScreen extends StatefulWidget {
  final String query;
  final bool initialShowMap;
  final LatLng? initialCenter;

  const SearchScreen(
    this.query, {
    Key? key,
    this.initialShowMap = false,
    this.initialCenter,
  }) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late Future<List<DocumentSnapshot>> futureResults;
  String? sortOption;
  bool _showMap = false;
  LatLng _center =
      const LatLng(-30.74155601977579, 24.34204925536877); // Default location
  late GoogleMapController mapController;
  String? locationFilter;
  String? categoryFilter;
  String? receptionFilter;
  List<DocumentSnapshot> currentResults = [];
  int? minPrice;
  int? maxPrice;
  final minPriceController = TextEditingController();
  final maxPriceController = TextEditingController();

  // Define your categories/facilities and their corresponding icons
  final Map<String, IconData> categories = {
    'Only Campsites': Icons.forest,
    'Self Catering': Icons.kitchen,
    'Pet Friendly': Icons.pets,
    'Glamping': Icons.house,
    'Braai Place': Icons.local_fire_department,
    // Add more categories as needed
  };

  // This will hold the selected categories
  Map<String, bool> selectedCategories = {
    'Only Campsites': false,
    'Self Catering': false,
    'Pet Friendly': false,
    'Glamping': false,
    'Braai Place': false,
    // Add more categories as needed
  };

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<List<DocumentSnapshot>> sortCurrentResults(String sortOption) async {
    switch (sortOption) {
      case 'Price: Low to High':
        currentResults.sort(
            (a, b) => int.parse(a['price']).compareTo(int.parse(b['price'])));
        break;
      case 'Price: High to Low':
        currentResults.sort(
            (a, b) => int.parse(b['price']).compareTo(int.parse(a['price'])));
        break;
      case 'A-Z':
        currentResults.sort((a, b) => a['name'].compareTo(b['name']));
        break;
      case 'Z-A':
        currentResults.sort((a, b) => b['name'].compareTo(a['name']));
        break;
    }
    return currentResults;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    minPriceController.dispose();
    maxPriceController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _showMap = widget.initialShowMap;
    if (widget.initialCenter != null) {
      _center = widget.initialCenter!;
    }
    _determinePosition();
    futureResults = performSearch(
      widget.query,
      locationFilter,
      categoryFilter as List<String>?,
      receptionFilter,
    );
    futureResults.then((results) {
      currentResults = results; // Update currentResults with the latest results
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Location Services Disabled'),
            content: const Text(
                'Please enable location services in your device settings.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Location Permissions Denied'),
              content: const Text(
                  'Please grant location permissions in your device settings.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Location Permissions Permanently Denied'),
            content: const Text(
                'Location permissions are permanently denied, we cannot request permissions.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _center = LatLng(position.latitude, position.longitude);
    });
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
      body: _buildSearchResults(),
    );
  }

  Widget _buildGoogleMap(List<DocumentSnapshot> documents) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: 16.0,
      ),
      markers: _buildMarkers(documents),
    );
  }

  Set<Marker> _buildMarkers(List<DocumentSnapshot> documents) {
    return documents.map((doc) {
      GeoPoint location = doc['location'];
      return Marker(
        markerId: MarkerId(doc.id),
        position: LatLng(location.latitude, location.longitude),
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              var completer = Completer<void>();
              return FutureBuilder<String?>(
                future: _getPreviewImageUrl(doc),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return AlertDialog(
                      title: const Text('Error'),
                      content: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    return AlertDialog(
                      title: Text(doc['name']),
                      content: Column(
                        mainAxisSize: MainAxisSize.min, // Set to min
                        children: [
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: double.infinity,
                                height: 100.0,
                                color: Colors.white,
                              ),
                            )
                          else if (snapshot.data != null)
                            Image.network(
                              snapshot.data!,
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  completer.complete();
                                  return child;
                                }
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'R${NumberFormat("#,##0").format(int.parse(doc['price']))}',
                              style: GoogleFonts.montserrat(
                                color: const Color(0xfff51957),
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CampsiteDetailsPage(doc),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xfff51957),
                              // background color
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(15), // border radius
                              ),
                            ),
                            child: const Text('View Details',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      );
    }).toSet();
  }

  Widget _buildSearchResults() {
    return FutureBuilder<List<DocumentSnapshot>>(
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
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              // Wrap AlertDialog in a StatefulBuilder to update the state of content
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                Widget buildCategoryFacilityButtons() {
                                  return Wrap(
                                    spacing: 0.5,
                                    // gap between adjacent buttons
                                    runSpacing: 2.0,
                                    // gap between lines
                                    children:
                                        categories.keys.map((String category) {
                                      bool isSelected =
                                          selectedCategories[category] ??
                                              false; // Provide a default value
                                      return ElevatedButton.icon(
                                        icon: Icon(categories[category],
                                            size: 18.0,
                                            color: isSelected
                                                ? Colors.pink.shade50
                                                : const Color(0xfff51957)),
                                        label: Text(category,
                                            style: GoogleFonts.montserrat(
                                                color: isSelected
                                                    ? Colors.pink.shade50
                                                    : const Color(0xfff51957))),
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: isSelected
                                              ? Colors.pink.shade50
                                              : const Color(0xfff51957),
                                          backgroundColor: isSelected
                                              ? const Color(0xfff51957)
                                              : Colors.pink.shade50,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            selectedCategories[category] =
                                                !isSelected;
                                          });
                                        },
                                      );
                                    }).toList(),
                                  );
                                }

                                return AlertDialog(
                                  title: const Text('Filter Options'),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      // Make all selects left aligned
                                      children: <Widget>[
                                        DropdownButton<String>(
                                          isExpanded: true,
                                          // To ensure the dropdown expands to fill the space
                                          value: locationFilter,
                                          hint: Text(
                                              locationFilter ?? 'Location'),
                                          items: <String>[
                                            'Western Cape',
                                            'Northern Cape',
                                            'North West',
                                            'Mpumalanga',
                                            'Limpopo',
                                            'Kwazulu-Natal',
                                            'Gauteng'
                                          ].map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              // Use the setState provided by StatefulBuilder
                                              locationFilter = value;
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 20.0),
                                        // Add some space
                                        const Text('Category/Facilities',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                        buildCategoryFacilityButtons(),
                                        const SizedBox(height: 20.0),
                                        // Add some space
                                        const Text('Price',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: minPriceController,
                                                decoration:
                                                    const InputDecoration(
                                                        labelText: 'Min.'),
                                                keyboardType:
                                                    TextInputType.number,
                                                onChanged: (value) {
                                                  minPrice =
                                                      int.tryParse(value);
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 10.0),
                                            // Add some space between the inputs
                                            Expanded(
                                              child: TextField(
                                                controller: maxPriceController,
                                                decoration:
                                                    const InputDecoration(
                                                        labelText: 'Max.'),
                                                keyboardType:
                                                    TextInputType.number,
                                                onChanged: (value) {
                                                  maxPrice =
                                                      int.tryParse(value);
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20.0),
                                        DropdownButton<String>(
                                          value: receptionFilter,
                                          hint:
                                              const Text('Cellphone Reception'),
                                          items: <String>[
                                            'Yes',
                                            'No',
                                            'Weak',
                                            'Wi-Fi'
                                          ].map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              receptionFilter = value;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    Container(
                                      margin:
                                          const EdgeInsets.only(right: 30.0),
                                      child: TextButton(
                                        child: const Text('Clear Filters',
                                            style: TextStyle(
                                                color: Color(0xfff51957))),
                                        onPressed: () {
                                          setState(() {
                                            minPrice = 0;
                                            maxPrice = null;
                                            minPriceController.text = '0';
                                            maxPriceController.text = '';
                                            locationFilter = null;
                                            categoryFilter = null;
                                            receptionFilter = null;
                                            selectedCategories = {
                                              'Only Campsites': false,
                                              'Self Catering': false,
                                              'Pet Friendly': false,
                                              'Braai Place': false,
                                              'Glamping': false,
                                              // Add more categories as needed
                                            };
                                          });
                                        },
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                            0xfff51957), // background color
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              15), // border radius
                                        ),
                                      ),
                                      child: const Text('Apply Filters',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      onPressed: () {
                                        List<String> selectedCategoryFilters =
                                            [];
                                        selectedCategories
                                            .forEach((key, value) {
                                          if (value) {
                                            selectedCategoryFilters.add(key);
                                          }
                                        });

                                        this.setState(() {
                                          minPriceController.text =
                                              minPrice?.toString() ?? '0';
                                          maxPriceController.text =
                                              maxPrice?.toString() ?? '';
                                          if (locationFilter == null &&
                                              selectedCategoryFilters.isEmpty &&
                                              receptionFilter == null) {
                                            // If all filters are cleared, perform a search with only the original query
                                            futureResults = performSearch(
                                              widget.query,
                                              null,
                                              null,
                                              null,
                                            );
                                          } else {
                                            futureResults = performSearch(
                                              widget.query,
                                              locationFilter,
                                              selectedCategoryFilters,
                                              // Pass the list of selected categories
                                              receptionFilter,
                                            );
                                          }
                                          futureResults.then((results) {
                                            currentResults =
                                                results; // Update currentResults with the latest results
                                            if (sortOption != null) {
                                              sortCurrentResults(
                                                  sortOption!); // Sort the results according to the current sort option
                                            }
                                          });
                                          Navigator.of(context).pop();
                                        });
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.filter_list, color: Colors.white),
                          Text('Filter', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            _showMap ? const Color(0xfff51957) : Colors.white,
                        backgroundColor: _showMap
                            ? Colors.pink.shade50
                            : const Color(0xfff51957),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _showMap = !_showMap;
                        });
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.map),
                          Text('Map'),
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
                      value: sortOption,
                      hint: Text(sortOption ?? 'Sort by'),
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
                      onChanged: _showMap
                          ? null
                          : (value) {
                              setState(() {
                                sortOption = value;
                                futureResults = sortCurrentResults(
                                    sortOption!); // Update futureResults with the sorted results
                              });
                            },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _showMap
                    ? _buildGoogleMap(snapshot.data!)
                    : ListView.builder(
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
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CampsiteDetailsPage(
                                                  snapshot.data![index]),
                                        ),
                                      );
                                    },
                                    child: Card(
                                      elevation: 5.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                            leading: const Icon(
                                                Icons.location_pin,
                                                color: Color(0xfff51957)),
                                            title: Text(
                                              snapshot.data![index]
                                                  ['main_fall_under'],
                                              style: GoogleFonts.montserrat(),
                                            ),
                                          ),
                                          ListTile(
                                            contentPadding:
                                                const EdgeInsets.only(left: 4),
                                            leading: const Icon(Icons.phone,
                                                color: Color(0xfff51957)),
                                            title: Text(
                                              snapshot.data![index]
                                                  ['telephone'],
                                              style: GoogleFonts.montserrat(),
                                            ),
                                          ),
                                          if (snapshot.data![index]['tags']
                                                  .contains('Pet Friendly') ||
                                              snapshot.data![index]['tags']
                                                  .contains(
                                                      'Pets With Arrangements'))
                                            ListTile(
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      left: 4),
                                              leading: const Icon(Icons.pets,
                                                  color: Color(0xfff51957)),
                                              title: Text(
                                                snapshot.data![index]['tags']
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
                                                      .contains(
                                                          'Only Campsites')
                                                  ? 'Only Campsites'
                                                  : snapshot.data![index]
                                                                  ['tags']
                                                              .contains(
                                                                  'Self Catering') &&
                                                          snapshot.data![index]
                                                                  ['tags']
                                                              .contains(
                                                                  'Campsites')
                                                      ? 'Campsites & Self Catering'
                                                      : 'Self Catering',
                                              style: GoogleFonts.montserrat(),
                                            ),
                                          ),
                                          const Divider(),
                                          _buildTagRow(
                                              snapshot.data![index]['tags'],
                                              snapshot.data![index]['price']),
                                        ],
                                      ),
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
    );
  }

  Future<List<DocumentSnapshot>> performSearch(
    String query,
    String? locationFilter,
    List<String>? categoryFilters,
    String? receptionFilter,
  ) async {
    query = query.toLowerCase();
    List<DocumentSnapshot> results = [];

    await FirebaseFirestore.instance
        .collection('sites')
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        var data = doc.data();
        bool matchesQuery = false;
        bool matchesFilters = true;

        // Check 'fall_under' field
        if (data['fall_under'] != null &&
            data['fall_under']
                .map((e) => e.toString().toLowerCase())
                .contains(query)) {
          matchesQuery = true;
        }

        // Check 'main_fall_under' field
        if (data['main_fall_under'] != null &&
            data['main_fall_under'].toLowerCase().contains(query)) {
          matchesQuery = true;
        }

        // Check 'name' field
        if (data['name'] != null &&
            data['name'].toLowerCase().contains(query)) {
          matchesQuery = true;
        }

        // Check 'province' field
        if (data['province'] != null &&
            data['province'].toLowerCase().contains(query)) {
          matchesQuery = true;
        }

        // Check 'tags' field
        if (data['tags'] != null &&
            data['tags']
                .map((e) => e.toString().toLowerCase())
                .contains(query)) {
          matchesQuery = true;
        }

        // Apply location filter
        if (locationFilter != null &&
            data['province'] != null &&
            data['province'].toLowerCase() != locationFilter.toLowerCase()) {
          matchesFilters = false;
        }

        // Apply category filter
        if (categoryFilters != null &&
            data['tags'] != null &&
            !categoryFilters.any((filter) => data['tags'].contains(filter))) {
          matchesFilters = false;
        }

        // Apply reception filter
        if (receptionFilter != null &&
            data['signal'] != null &&
            data['signal'].toLowerCase() != receptionFilter.toLowerCase()) {
          matchesFilters = false;
        }

        // Apply price filter
        if (minPrice != null || maxPrice != null) {
          int price = int.parse(data['price']);
          if ((minPrice != null && price < minPrice!) ||
              (maxPrice != null && price > maxPrice!)) {
            matchesFilters = false;
          }
        }

        if (matchesQuery && matchesFilters) {
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
                GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.query = firstTag; // Update the query
                      futureResults = performSearch(
                        widget.query,
                        locationFilter,
                        categoryFilter as List<String>?,
                        receptionFilter,
                      ); // Perform a new search
                    });
                  },
                  child: Container(
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
                            title: Text('Other Tags',
                                style: GoogleFonts.montserrat()),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: includedTags.skip(1).map((tag) {
                                  return ListTile(
                                    leading: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      // This will make the Row as small as possible
                                      children: [
                                        Icon(tagIcons[tag] ?? Icons.tag),
                                        // Use the corresponding icon
                                        const SizedBox(width: 5),
                                        // Adjust the space as needed
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            setState(() {
                                              widget.query =
                                                  tag; // Update the query
                                              futureResults = performSearch(
                                                widget.query,
                                                locationFilter,
                                                categoryFilter as List<String>?,
                                                receptionFilter,
                                              ); // Perform a new search
                                            });
                                          },
                                          child: Text(tag,
                                              style: GoogleFonts.montserrat(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      const Color(0xfff51957))),
                                        ),
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
                                child: Text('Close',
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xfff51957))),
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
