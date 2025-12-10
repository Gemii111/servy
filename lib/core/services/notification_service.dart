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
  final String? type; // 'order', 'driver', 'restaurant', 'general', etc.

  NotificationData({
    required this.id,
    required this.title,
    required this.body,
    this.data,
    DateTime? timestamp,
    this.imageUrl,
    this.type,
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
      type: json['type'] as String?,
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
      'type': type,
    };
  }
}

/// Notification service for handling push notifications
/// 
/// 🔄 للتحويل إلى Firebase:
/// 1. أضف في pubspec.yaml:
///    - firebase_core: ^2.24.2
///    - firebase_messaging: ^14.7.10
/// 2. قم بإعداد Firebase في Firebase Console
/// 3. أضف google-services.json (Android) و GoogleService-Info.plist (iOS)
/// 4. قم بإلغاء التعليق على كود Firebase في هذا الملف
/// 
/// 📱 الاستخدام:
/// ```dart
/// // Initialize في main()
/// await NotificationService.instance.initialize();
/// 
/// // Subscribe to topics
/// await NotificationService.instance.subscribeToTopic('customer_updates');
/// 
/// // Listen to notifications
/// NotificationService.instance.notificationStream?.listen((notification) {
///   // Handle notification
/// });
/// ```
class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  StreamController<NotificationData>? _notificationController;
  bool _isInitialized = false;
  String? _fcmToken;

  /// Notification stream - استمع له في app لتلقي الإشعارات
  Stream<NotificationData>? get notificationStream =>
      _notificationController?.stream;

  /// Check if initialized
  bool get isInitialized => _isInitialized;

  /// Get FCM token (for backend registration)
  String? get fcmToken => _fcmToken;

  /// Initialize notification service
  /// يجب استدعاءها في main() بعد Firebase initialization
  Future<void> initialize() async {
    if (_isInitialized) {
      Logger.d('NotificationService', 'Already initialized');
      return;
    }

    _notificationController = StreamController<NotificationData>.broadcast();

    // ==================== Firebase Implementation (Uncomment when ready) ====================
    /*
    // Initialize Firebase Messaging
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Get FCM token
    _fcmToken = await FirebaseMessaging.instance.getToken();
    Logger.d('NotificationService', 'FCM Token: $_fcmToken');

    // Handle foreground messages (when app is open)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Logger.d('NotificationService', 'Foreground notification: ${message.notification?.title}');
      final notification = NotificationData(
        id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
        data: message.data,
        imageUrl: message.notification?.android?.imageUrl,
        type: message.data['type'],
      );
      _notificationController?.add(notification);
    });

    // Handle notification tap (when app is in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Logger.d('NotificationService', 'Notification tapped: ${message.notification?.title}');
      final notification = NotificationData(
        id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
        data: message.data,
        type: message.data['type'],
      );
      _notificationController?.add(notification);
    });

    // Handle notification tap (when app is terminated)
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      Logger.d('NotificationService', 'Initial notification: ${initialMessage.notification?.title}');
      final notification = NotificationData(
        id: initialMessage.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: initialMessage.notification?.title ?? '',
        body: initialMessage.notification?.body ?? '',
        data: initialMessage.data,
        type: initialMessage.data['type'],
      );
      _notificationController?.add(notification);
    }

    // Handle token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      Logger.d('NotificationService', 'FCM Token refreshed: $newToken');
      // TODO: Send new token to backend
    });
    */

    // ==================== Mock Implementation (Current) ====================
    // Mock FCM token for development
    _fcmToken = 'mock_fcm_token_${DateTime.now().millisecondsSinceEpoch}';
    Logger.d('NotificationService', 'Mock FCM Token: $_fcmToken');

    _isInitialized = true;
    Logger.d('NotificationService', 'Notification service initialized');
  }

  /// Request notification permissions
  /// عادة يتم استدعاؤها تلقائياً في initialize()، لكن يمكن استدعاؤها يدوياً
  Future<bool> requestPermission() async {
    // ==================== Firebase Implementation ====================
    /*
    final status = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    return status.authorizationStatus == AuthorizationStatus.authorized;
    */

    // Mock: always return true
    Logger.d('NotificationService', 'Notification permission granted (mock)');
    return true;
  }

  /// Subscribe to a topic (e.g., 'driver_orders', 'customer_updates', 'restaurant_orders')
  /// يتم الاشتراك في topics مختلفة حسب نوع المستخدم
  /// 
  /// Examples:
  /// - 'customer_${userId}' - إشعارات خاصة بالعميل
  /// - 'driver_orders' - طلبات التوصيل المتاحة
  /// - 'restaurant_${restaurantId}_orders' - طلبات المطعم
  Future<void> subscribeToTopic(String topic) async {
    // ==================== Firebase Implementation ====================
    // await FirebaseMessaging.instance.subscribeToTopic(topic);
    
    Logger.d('NotificationService', 'Subscribed to topic: $topic (mock)');
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    // ==================== Firebase Implementation ====================
    // await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    
    Logger.d('NotificationService', 'Unsubscribed from topic: $topic (mock)');
  }

  /// Register FCM token with backend
  /// يجب استدعاؤها بعد login لتسجيل token في backend
  Future<void> registerTokenWithBackend(String userId) async {
    if (_fcmToken == null) {
      Logger.e('NotificationService', 'FCM token not available');
      return;
    }

    // TODO: Call backend API to register token
    // Example:
    // await ApiService.instance.post(
    //   ApiConstants.notificationsRegisterToken,
    //   data: {
    //     'userId': userId,
    //     'fcmToken': _fcmToken,
    //     'platform': Platform.isAndroid ? 'android' : 'ios',
    //   },
    // );

    Logger.d('NotificationService', 'FCM token registered with backend (mock)');
  }

  /// Emit a mock notification (for testing/simulation)
  void emitMockNotification(NotificationData notification) {
    if (_notificationController != null && !_notificationController!.isClosed) {
      _notificationController!.add(notification);
      Logger.d('NotificationService', 'Mock notification emitted: ${notification.title}');
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
