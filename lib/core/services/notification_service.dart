import 'dart:async';
import '../utils/logger.dart';

/// Notification data model
class NotificationData {
  final String id;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  final String? imageUrl;

  NotificationData({
    required this.id,
    required this.title,
    required this.body,
    this.data,
    DateTime? timestamp,
    this.imageUrl,
  }) : timestamp = timestamp ?? DateTime.now();

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      data: json['data'] as Map<String, dynamic>?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'image_url': imageUrl,
    };
  }
}

/// Notification service for handling push notifications
/// Currently uses Mock implementation. To enable Firebase:
/// 1. Uncomment firebase_core and firebase_messaging in pubspec.yaml
/// 2. Initialize Firebase in main.dart
/// 3. Replace MockNotificationService with FirebaseNotificationService
class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  StreamController<NotificationData>? _notificationController;
  bool _isInitialized = false;
  String? _fcmToken;

  /// Notification stream
  Stream<NotificationData>? get notificationStream =>
      _notificationController?.stream;

  /// Check if initialized
  bool get isInitialized => _isInitialized;

  /// Get FCM token (for backend registration)
  String? get fcmToken => _fcmToken;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) {
      Logger.d('NotificationService', 'Already initialized');
      return;
    }

    _notificationController = StreamController<NotificationData>.broadcast();

    // In a real app, this would initialize Firebase Messaging
    // await FirebaseMessaging.instance.requestPermission();
    // final token = await FirebaseMessaging.instance.getToken();
    // _fcmToken = token;

    // Mock FCM token
    _fcmToken = 'mock_fcm_token_${DateTime.now().millisecondsSinceEpoch}';

    // Setup notification handlers
    // FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    // FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    // FirebaseMessaging.instance.getInitialMessage().then(_handleNotificationTap);

    _isInitialized = true;
    Logger.d('NotificationService', 'Notification service initialized');
  }

  /// Request notification permissions
  Future<bool> requestPermission() async {
    // In a real app, this would request Firebase Messaging permissions
    // final status = await FirebaseMessaging.instance.requestPermission();
    // return status.authorizationStatus == AuthorizationStatus.authorized;

    // Mock: always return true
    Logger.d('NotificationService', 'Notification permission granted (mock)');
    return true;
  }

  /// Subscribe to a topic (e.g., 'driver_orders', 'customer_updates')
  Future<void> subscribeToTopic(String topic) async {
    // In a real app: await FirebaseMessaging.instance.subscribeToTopic(topic);
    Logger.d('NotificationService', 'Subscribed to topic: $topic (mock)');
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    // In a real app: await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    Logger.d('NotificationService', 'Unsubscribed from topic: $topic (mock)');
  }

  /// Handle foreground notification (when app is open)
  // In a real app, this would be called by Firebase Messaging
  // void _handleForegroundMessage(NotificationData notification) {
  //   Logger.d('NotificationService', 'Foreground notification: ${notification.title}');
  //   _notificationController?.add(notification);
  // }

  /// Handle notification tap (when user taps notification)
  // In a real app, this would be called by Firebase Messaging
  // void _handleNotificationTap(NotificationData? notification) {
  //   if (notification != null) {
  //     Logger.d('NotificationService', 'Notification tapped: ${notification.title}');
  //     _notificationController?.add(notification);
  //   }
  // }

  /// Emit a mock notification (for testing/simulation)
  void emitMockNotification(NotificationData notification) {
    if (_notificationController != null && !_notificationController!.isClosed) {
      _notificationController!.add(notification);
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _notificationController?.close();
    _notificationController = null;
    _isInitialized = false;
    Logger.d('NotificationService', 'Notification service disposed');
  }
}

