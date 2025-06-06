import 'package:cloud_firestore/cloud_firestore.dart';

class AutocompleteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _cachedLocations = [];

  Future<List<String>> getLocationSuggestions(String query) async {
    try {
      // Load locations if not cached
      if (_cachedLocations.isEmpty) {
        await _loadLocations();
      }

      if (query.isEmpty) return [];

      // Filter locations based on query (case insensitive)
      final suggestions = _cachedLocations
          .where((location) =>
          location.toLowerCase().contains(query.toLowerCase()))
          .take(3) // Limit to 3 suggestions
          .toList();

      return suggestions;
    } catch (e) {
      print('Error getting location suggestions: $e');
      return [];
    }
  }

  Future<void> _loadLocations() async {
    try {
      final doc = await _firestore
          .collection('fall_under')
          .doc('fall_under')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['location'] != null) {
          _cachedLocations = List<String>.from(data['location']);
        }
      }
    } catch (e) {
      print('Error loading locations: $e');
    }
  }
}