// lib/src/core/services/image_cache_service.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

class ImageCacheService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  static const String _cacheInfoKey = 'image_cache_info';

  void _logDebug(String message, {bool isError = false}) {
    final emoji = isError ? '❌' : '✅';
    developer.log('$emoji $message', name: 'ImageCacheService');
  }

  // Generate a unique filename based on the Firebase URL
  String _generateCacheFilename(String firebaseUrl) {
    final bytes = utf8.encode(firebaseUrl);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Get the local cache directory
  Future<Directory> get _cacheDir async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory cacheDir = Directory('${appDir.path}/image_cache');

    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    return cacheDir;
  }

  // Check if an image is cached and valid
  Future<File?> getCachedImage(String firebaseUrl) async {
    try {
      final filename = _generateCacheFilename(firebaseUrl);
      final cacheDirectory = await _cacheDir;
      final file = File('${cacheDirectory.path}/$filename');

      if (await file.exists()) {
        // Check cache validity from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final cacheInfo = prefs.getString(_cacheInfoKey);

        if (cacheInfo != null) {
          final cacheData = json.decode(cacheInfo) as Map<String, dynamic>;
          final urlData = cacheData[firebaseUrl];

          if (urlData != null) {
            final cacheTime = DateTime.parse(urlData['timestamp']);
            final cacheExpiration = cacheTime.add(const Duration(days: 7)); // Cache for 7 days

            if (DateTime.now().isBefore(cacheExpiration)) {
              _logDebug('✅ Using cached image for: $firebaseUrl');
              return file;
            }
          }
        }
      }

      return null;
    } catch (e) {
      _logDebug('Error checking cached image: $e', isError: true);
      return null;
    }
  }

  // Download and cache an image
  Future<File?> downloadAndCacheImage(String firebaseUrl) async {
    try {
      _logDebug('🔄 Downloading image from: $firebaseUrl');

      // Check if already cached
      final cachedFile = await getCachedImage(firebaseUrl);
      if (cachedFile != null) return cachedFile;

      // Download from Firebase
      final ref = _storage.refFromURL(firebaseUrl);
      final filename = _generateCacheFilename(firebaseUrl);
      final cacheDirectory = await _cacheDir;
      final file = File('${cacheDirectory.path}/$filename');

      // Download the file
      await ref.writeToFile(file);

      // Update cache information in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final cacheInfo = prefs.getString(_cacheInfoKey);
      final cacheData = cacheInfo != null
          ? json.decode(cacheInfo) as Map<String, dynamic>
          : <String, dynamic>{};

      cacheData[firebaseUrl] = {
        'filename': filename,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await prefs.setString(_cacheInfoKey, json.encode(cacheData));

      _logDebug('✅ Successfully cached image: $firebaseUrl');
      return file;
    } catch (e) {
      _logDebug('Error downloading and caching image: $e', isError: true);
      return null;
    }
  }

  // Clear expired cache entries
  Future<void> clearExpiredCache() async {
    try {
      _logDebug('🧹 Cleaning expired cache entries');

      final prefs = await SharedPreferences.getInstance();
      final cacheInfo = prefs.getString(_cacheInfoKey);

      if (cacheInfo != null) {
        final cacheData = json.decode(cacheInfo) as Map<String, dynamic>;
        final cacheDirectory = await _cacheDir;
        final expiredUrls = <String>[];

        cacheData.forEach((url, data) {
          final cacheTime = DateTime.parse(data['timestamp']);
          final cacheExpiration = cacheTime.add(const Duration(days: 7));

          if (DateTime.now().isAfter(cacheExpiration)) {
            final file = File('${cacheDirectory.path}/${data['filename']}');
            if (file.existsSync()) {
              file.deleteSync();
            }
            expiredUrls.add(url);
          }
        });

        // Remove expired entries from cache info
        expiredUrls.forEach(cacheData.remove);
        await prefs.setString(_cacheInfoKey, json.encode(cacheData));
      }

      _logDebug('✅ Cache cleanup completed');
    } catch (e) {
      _logDebug('Error clearing expired cache: $e', isError: true);
    }
  }

  // Get the total size of cached images
  Future<int> getCacheSize() async {
    try {
      final cacheDirectory = await _cacheDir;
      int totalSize = 0;

      await for (final file in cacheDirectory.list()) {
        if (file is File) {
          totalSize += await file.length();
        }
      }

      return totalSize;
    } catch (e) {
      _logDebug('Error calculating cache size: $e', isError: true);
      return 0;
    }
  }

  // Clear all cached images
  Future<void> clearAllCache() async {
    try {
      _logDebug('🗑️ Clearing all cached images');

      final cacheDirectory = await _cacheDir;
      if (await cacheDirectory.exists()) {
        await cacheDirectory.delete(recursive: true);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheInfoKey);

      _logDebug('✅ Cache cleared successfully');
    } catch (e) {
      _logDebug('Error clearing cache: $e', isError: true);
    }
  }
}