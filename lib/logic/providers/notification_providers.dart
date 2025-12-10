import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/notification_service.dart';

/// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService.instance;
  
  // Initialize service when provider is first accessed
  service.initialize();
  
  // Dispose service when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

/// Notification stream provider
final notificationStreamProvider =
    StreamProvider<NotificationData>((ref) async* {
  final service = ref.watch(notificationServiceProvider);
  final notificationStream = service.notificationStream;
  
  if (notificationStream != null) {
    yield* notificationStream;
  } else {
    yield* const Stream<NotificationData>.empty();
  }
});

/// FCM token provider
final fcmTokenProvider = FutureProvider<String?>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  await service.initialize();
  return service.fcmToken;
});


