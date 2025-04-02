// lib/src/shared/widgets/cached_firebase_image.dart
import 'package:flutter/material.dart';
import 'dart:io';
import '../../core/services/image_cache_service.dart';

class CachedFirebaseImage extends StatefulWidget {
  final String firebaseUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedFirebaseImage({
    Key? key,
    required this.firebaseUrl,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  State<CachedFirebaseImage> createState() => _CachedFirebaseImageState();
}

class _CachedFirebaseImageState extends State<CachedFirebaseImage> {
  final ImageCacheService _cacheService = ImageCacheService();
  late Future<File?> _imageFuture;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(CachedFirebaseImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.firebaseUrl != widget.firebaseUrl) {
      _loadImage();
    }
  }

  void _loadImage() {
    _imageFuture = _getImage();
  }

  // Update the _getImage method in _CachedFirebaseImageState class
  Future<File?> _getImage() async {
    try {
      // First try to get from cache
      final cachedFile = await _cacheService.getCachedImage(widget.firebaseUrl);
      if (cachedFile != null) return cachedFile;

      // If not in cache, try to download and cache
      return await _cacheService.downloadAndCacheImage(widget.firebaseUrl);
    } catch (e) {
      print('Error getting image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.placeholder ?? const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          print('Image loading error: ${snapshot.error}');
          try {
            // Fallback to direct network image if caching fails
            return Image.network(
              widget.firebaseUrl,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return widget.placeholder ??
                    const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return widget.errorWidget ??
                    const Icon(Icons.error_outline, color: Colors.red);
              },
            );
          } catch (e) {
            return widget.errorWidget ??
                const Icon(Icons.broken_image, color: Colors.red);
          }
        }

        if (!snapshot.hasData || snapshot.data == null) {
          try {
            // Fallback to direct network image if file is null
            return Image.network(
              widget.firebaseUrl,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return widget.placeholder ??
                    const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return widget.errorWidget ??
                    const Icon(Icons.error_outline, color: Colors.red);
              },
            );
          } catch (e) {
            return widget.errorWidget ??
                const Icon(Icons.broken_image, color: Colors.red);
          }
        }

        return Image.file(
          snapshot.data!,
          width: widget.width,
          height: widget.height,
          fit: widget.fit ?? BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error displaying cached image: $error');
            return widget.errorWidget ??
                const Icon(Icons.image_not_supported, color: Colors.red);
          },
        );
      },
    );
  }
}
