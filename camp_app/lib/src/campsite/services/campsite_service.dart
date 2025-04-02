// lib/src/campsite/services/campsite_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../core/services/image_cache_service.dart';
import '../models/campsite_model.dart';

class CampsiteService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CampsiteService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) :
        _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  Future<List<CampsiteModel>> searchCampsites(String query, {
    String? locationFilter,
    List<String>? categoryFilters,
    String? receptionFilter,
    int? minPrice,
    int? maxPrice,
  }) async {
    query = query.toLowerCase();
    List<CampsiteModel> results = [];

    try {
      final querySnapshot = await _firestore.collection('sites').get();

      for (var doc in querySnapshot.docs) {
        var data = doc.data();
        bool matchesQuery = false;
        bool matchesFilters = true;

        // Check 'fall_under' field
        if (data['fall_under'] != null &&
            data['fall_under'].map((e) => e.toString().toLowerCase()).contains(query)) {
          matchesQuery = true;
        }

        // Check 'main_fall_under' field
        if (data['main_fall_under'] != null &&
            data['main_fall_under'].toLowerCase().contains(query)) {
          matchesQuery = true;
        }

        // Check 'name' field
        if (data['name'] != null && data['name'].toLowerCase().contains(query)) {
          matchesQuery = true;
        }

        // Check 'province' field
        if (data['province'] != null && data['province'].toLowerCase().contains(query)) {
          matchesQuery = true;
        }

        // Check 'tags' field
        if (data['tags'] != null &&
            data['tags'].map((e) => e.toString().toLowerCase()).contains(query)) {
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
            categoryFilters.isNotEmpty &&
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
        if ((minPrice != null || maxPrice != null) && data['price'] != null) {
          int price = int.parse(data['price']);
          if ((minPrice != null && price < minPrice) ||
              (maxPrice != null && price > maxPrice)) {
            matchesFilters = false;
          }
        }

        if (matchesQuery && matchesFilters) {
          results.add(CampsiteModel.fromFirestore(doc));
        }
      }

      return results;
    } catch (e) {
      throw Exception('Failed to search campsites: $e');
    }
  }

  Future<List<String>> getCampsiteImages(String campsiteId) async {
    try {
      final sitesFolderRef = _storage.ref().child('sites');
      final campsiteFolderRef = sitesFolderRef.child(campsiteId);

      List<String> imageUrls = [];
      try {
        final result = await campsiteFolderRef.listAll();

        final imageItems = result.items.where((item) =>
        item.name.toLowerCase().endsWith('.jpg') ||
            item.name.toLowerCase().endsWith('.jpeg') ||
            item.name.toLowerCase().endsWith('.webp') ||
            item.name.toLowerCase().endsWith('.png')).toList();

        for (var item in imageItems) {
          try {
            String url = await item.getDownloadURL();
            imageUrls.add(url);
          } catch (e) {
            print('Error getting download URL for ${item.name}: $e');
            continue;
          }
        }

        if (imageUrls.isEmpty && imageItems.isNotEmpty) {
          print('Warning: Found ${imageItems.length} images but couldn\'t get URLs');
        }
      } catch (e) {
        print('Error listing images in storage: $e');
        return [];
      }

      return imageUrls;
    } catch (e) {
      print('Failed to fetch campsite images: $e');
      throw Exception('Failed to fetch campsite images: $e');
    }
  }

  Future<CampsiteModel> getCampsiteById(String id) async {
    try {
      final doc = await _firestore.collection('sites').doc(id).get();
      if (!doc.exists) {
        throw Exception('Campsite not found');
      }
      return CampsiteModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch campsite: $e');
    }
  }

  // In campsite_service.dart
  Future<List<CampsiteModel>> getPopularCampsites() async {
    try {

      final QuerySnapshot querySnapshot = await _firestore
          .collection('sites')
          .limit(7)
          .get();

      return querySnapshot.docs
          .map((doc) => CampsiteModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}