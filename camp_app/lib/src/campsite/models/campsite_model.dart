// lib/src/campsite/models/campsite_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CampsiteModel {
  final String id;
  final String name;
  final String description;
  final String mainFallUnder;
  final GeoPoint location;
  final String price;
  final List<String> tags;
  final String telephone;
  final String province;
  final List<String> fallUnder;
  final String signal;
  final int views;

  CampsiteModel({
    required this.id,
    required this.name,
    required this.description,
    required this.mainFallUnder,
    required this.location,
    required this.price,
    required this.tags,
    required this.telephone,
    required this.province,
    required this.fallUnder,
    required this.signal,
    required this.views,
  });

  factory CampsiteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CampsiteModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      mainFallUnder: data['main_fall_under'] ?? '',
      location: data['location'] ?? const GeoPoint(0, 0),
      price: data['price']?.toString() ?? '0',
      tags: List<String>.from(data['tags'] ?? []),
      telephone: data['telephone'] ?? '',
      province: data['province'] ?? '',
      fallUnder: List<String>.from(data['fall_under'] ?? []),
      signal: data['signal'] ?? '',
      views: data['views'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'main_fall_under': mainFallUnder,
      'location': location,
      'price': price,
      'tags': tags,
      'telephone': telephone,
      'province': province,
      'fall_under': fallUnder,
      'signal': signal,
      'views': views,
    };
  }

  CampsiteModel copyWith({
    String? name,
    String? description,
    String? mainFallUnder,
    GeoPoint? location,
    String? price,
    List<String>? tags,
    String? telephone,
    String? province,
    List<String>? fallUnder,
    String? signal,
    int? views,
  }) {
    return CampsiteModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      mainFallUnder: mainFallUnder ?? this.mainFallUnder,
      location: location ?? this.location,
      price: price ?? this.price,
      tags: tags ?? this.tags,
      telephone: telephone ?? this.telephone,
      province: province ?? this.province,
      fallUnder: fallUnder ?? this.fallUnder,
      signal: signal ?? this.signal,
      views: views ?? this.views,
    );
  }
}