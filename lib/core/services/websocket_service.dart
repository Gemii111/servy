import 'dart:async';
import '../utils/logger.dart';

/// WebSocket message types
enum WebSocketMessageType {
  orderUpdate, // Order status changed
  newOrder, // New order available (for drivers)
  driverLocationUpdate, // Driver location updated (for customers)
  driverAssigned, // Driver assigned to order
  orderCancelled, // Order cancelled
  ping, // Keep-alive ping
  pong, // Keep-alive pong
}

/// WebSocket message model
class WebSocketMessage {
  final WebSocketMessageType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  WebSocketMessage({
    required this.type,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      type: WebSocketMessageType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'] as String,
        orElse: () => WebSocketMessageType.ping,
      ),
      data: json['data'] as Map<String, dynamic>,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// WebSocket service for real-time updates
class WebSocketService {
  static final WebSocketService instance = WebSocketService._();
  WebSocketService._();

  StreamController<WebSocketMessage>? _messageController;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  bool _isConnected = false;
  bool _shouldReconnect = true;
  String? _userId;
  String? _userType; // 'customer', 'driver', 'restaurant'

  /// Connection status stream
  Stream<bool> get connectionStatusStream async* {
    yield _isConnected;
    while (_messageController != null && !_messageController!.isClosed) {
      await Future.delayed(const Duration(seconds: 1));
      yield _isConnected;
    }
  }

  /// Messages stream
  Stream<WebSocketMessage>? get messagesStream => _messageController?.stream;

  /// Check if connected
  bool get isConnected => _isConnected;

  /// Connect to WebSocket server
  Future<void> connect({
    required String userId,
    required String userType,
    String? url,
  }) async {
    if (_isConnected && _userId == userId) {
      Logger.d('WebSocketService', 'Already connected for user: $userId');
      return;
    }

    _userId = userId;
    _userType = userType;

    // In a real app, this would connect to an actual WebSocket server
    // For now, we'll simulate it with a mock connection
    await _connectMock(url ?? 'wss://mock.websocket.servy.app/$userType/$userId');

    Logger.d(
      'WebSocketService',
      'Connected to WebSocket for $userType: $userId',
    );
  }

  /// Connect to mock WebSocket (simulated)
  Future<void> _connectMock(String url) async {
    _shouldReconnect = true;
    
    // If controller already exists, don't recreate it (to preserve messages)
    if (_messageController == null || _messageController!.isClosed) {
      _messageController = StreamController<WebSocketMessage>.broadcast();
    }

    // Simulate connection delay
    await Future.delayed(const Duration(milliseconds: 500));

    _isConnected = true;

    // Start ping timer to keep connection alive
    _startPingTimer();

    Logger.d('WebSocketService', 'Mock WebSocket connected: $url');
  }

  /// Start ping timer
  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected) {
        _sendPing();
      }
    });
  }

  /// Send ping message
  void _sendPing() {
    if (_isConnected && _messageController != null) {
      final message = WebSocketMessage(
        type: WebSocketMessageType.ping,
        data: {},
      );
      _messageController!.add(message);
    }
  }

  /// Send message through WebSocket
  void sendMessage(WebSocketMessage message) {
    if (!_isConnected || _messageController == null) {
      Logger.w('WebSocketService', 'Cannot send message: not connected');
      return;
    }

    try {
      // In a real app, this would send to the actual WebSocket channel
      // _channel?.sink.add(jsonEncode(message.toJson()));
      
      // For mock, just log it
      Logger.d('WebSocketService', 'Message sent: ${message.type}');
    } catch (e) {
      Logger.e('WebSocketService', 'Failed to send message: $e');
    }
  }

  /// Emit a mock message (for testing/simulation)
  void emitMockMessage(WebSocketMessage message) {
    if (_messageController != null && !_messageController!.isClosed) {
      _messageController!.add(message);
      Logger.d('WebSocketService', 'Mock message emitted: ${message.type}');
    } else {
      Logger.w('WebSocketService', 'Cannot emit message: controller is null or closed');
    }
  }

  /// Disconnect from WebSocket
  Future<void> disconnect() async {
    _shouldReconnect = false;
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();

    await _messageController?.close();

    _messageController = null;
    _isConnected = false;

    Logger.d('WebSocketService', 'Disconnected from WebSocket');
  }

  /// Reconnect to WebSocket
  Future<void> reconnect() async {
    if (!_shouldReconnect || _isConnected) return;

    Logger.d('WebSocketService', 'Attempting to reconnect...');

    await Future.delayed(const Duration(seconds: 2));

    if (_userId != null && _userType != null && _shouldReconnect) {
      await connect(userId: _userId!, userType: _userType!);
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    _shouldReconnect = false;
    await disconnect();
  }
}

