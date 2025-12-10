import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/websocket_service.dart';

/// WebSocket service provider
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService.instance;
  
  // Dispose service when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

/// WebSocket connection status provider
final webSocketConnectionStatusProvider =
    StreamProvider<bool>((ref) async* {
  final service = ref.watch(webSocketServiceProvider);
  yield* service.connectionStatusStream;
});

/// WebSocket messages stream provider
final webSocketMessagesProvider = StreamProvider<WebSocketMessage>((ref) async* {
  final service = ref.watch(webSocketServiceProvider);
  final messagesStream = service.messagesStream;
  
  if (messagesStream != null) {
    yield* messagesStream;
  } else {
    // Return empty stream if not connected
    yield* const Stream<WebSocketMessage>.empty();
  }
});

