import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Haptic feedback utility for better user interactions
class HapticFeedbackUtil {
  HapticFeedbackUtil._();

  /// Light impact haptic feedback
  /// Use for button taps, toggles, selection changes
  static Future<void> lightImpact() async {
    if (kDebugMode) return; // Disable in debug mode to avoid excessive vibrations
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Silently fail if haptic feedback is not available
      if (kDebugMode) {
        print('HapticFeedback error: $e');
      }
    }
  }

  /// Medium impact haptic feedback
  /// Use for important actions like adding to cart, successful operations
  static Future<void> mediumImpact() async {
    if (kDebugMode) return;
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      if (kDebugMode) {
        print('HapticFeedback error: $e');
      }
    }
  }

  /// Heavy impact haptic feedback
  /// Use for critical actions like order placement, errors
  static Future<void> heavyImpact() async {
    if (kDebugMode) return;
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      if (kDebugMode) {
        print('HapticFeedback error: $e');
      }
    }
  }

  /// Selection change haptic feedback
  /// Use for switches, checkboxes, radio buttons
  static Future<void> selectionClick() async {
    if (kDebugMode) return;
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      if (kDebugMode) {
        print('HapticFeedback error: $e');
      }
    }
  }

  /// Vibrate feedback
  /// Use for notifications, alerts
  static Future<void> vibrate() async {
    if (kDebugMode) return;
    try {
      await HapticFeedback.vibrate();
    } catch (e) {
      if (kDebugMode) {
        print('HapticFeedback error: $e');
      }
    }
  }
}

