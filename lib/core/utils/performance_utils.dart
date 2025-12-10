import 'package:flutter/material.dart';

/// Performance utility class for optimization
class PerformanceUtils {
  PerformanceUtils._();

  /// Optimized image cache configuration
  static void configureImageCache() {
    PaintingBinding.instance.imageCache.maximumSize = 100;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024; // 50MB
  }

  /// Clear image cache when needed (e.g., low memory)
  static void clearImageCache() {
    PaintingBinding.instance.imageCache.clear();
  }

  /// Clear image cache for a specific image
  static void evictImageCache(String url) {
    PaintingBinding.instance.imageCache.evict(
      NetworkImage(url),
    );
  }
}

