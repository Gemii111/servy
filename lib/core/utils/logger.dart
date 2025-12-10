import 'package:flutter/foundation.dart';

/// Simple logger utility for debugging
class Logger {
  Logger._();

  static void d(String tag, dynamic message) {
    if (kDebugMode) {
      debugPrint('[$tag] $message');
    }
  }

  static void e(String tag, dynamic error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[$tag] ERROR: $error');
      if (stackTrace != null) {
        debugPrint('[$tag] StackTrace: $stackTrace');
      }
    }
  }

  static void i(String tag, dynamic message) {
    if (kDebugMode) {
      debugPrint('[$tag] INFO: $message');
    }
  }

  static void w(String tag, dynamic message) {
    if (kDebugMode) {
      debugPrint('[$tag] WARNING: $message');
    }
  }
}
