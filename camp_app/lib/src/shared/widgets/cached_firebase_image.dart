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

  Future<File?> _getImage() async {
    // First try to get from cache
    final cachedFile = await _cacheService.getCachedImage(widget.firebaseUrl);
    if (cachedFile != null) return cachedFile;

    // If not in cache, download and cache
    return _cacheService.downloadAndCacheImage(widget.firebaseUrl);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.placeholder ?? const CircularProgressIndicator();
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return widget.errorWidget ??
              const Icon(Icons.error_outline, color: Colors.red);
        }

        return Image.file(
          snapshot.data!,
          width: widget.width,
          height: widget.height,
          fit: widget.fit ?? BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return widget.errorWidget ??
                const Icon(Icons.error_outline, color: Colors.red);
          },
        );
      },
    );
  }
}