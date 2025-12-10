import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

/// Service for managing authentication tokens
/// يحفظ ويسترد Access Token و Refresh Token من SharedPreferences
class TokenService {
  TokenService._();
  
  static final TokenService instance = TokenService._();

  // Keys for SharedPreferences
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyTokenExpiresAt = 'token_expires_at';
  static const String _keyUserId = 'user_id';

  SharedPreferences? _prefs;

  /// Initialize TokenService - يجب استدعاءها في main() أو app initialization
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    Logger.d('TokenService', 'TokenService initialized');
  }

  // ==================== Access Token ====================

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    await _prefs?.setString(_keyAccessToken, token);
    Logger.d('TokenService', 'Access token saved');
  }

  /// Get access token
  String? getAccessToken() {
    return _prefs?.getString(_keyAccessToken);
  }

  /// Check if access token exists
  bool hasAccessToken() {
    return getAccessToken() != null;
  }

  // ==================== Refresh Token ====================

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await _prefs?.setString(_keyRefreshToken, token);
    Logger.d('TokenService', 'Refresh token saved');
  }

  /// Get refresh token
  String? getRefreshToken() {
    return _prefs?.getString(_keyRefreshToken);
  }

  // ==================== Token Expiry ====================

  /// Save token expiry time
  Future<void> saveTokenExpiresAt(DateTime expiresAt) async {
    await _prefs?.setString(_keyTokenExpiresAt, expiresAt.toIso8601String());
  }

  /// Get token expiry time
  DateTime? getTokenExpiresAt() {
    final expiresAtString = _prefs?.getString(_keyTokenExpiresAt);
    if (expiresAtString == null) return null;
    try {
      return DateTime.parse(expiresAtString);
    } catch (e) {
      Logger.e('TokenService', 'Error parsing token expiry: $e');
      return null;
    }
  }

  /// Check if token is expired
  bool isTokenExpired() {
    final expiresAt = getTokenExpiresAt();
    if (expiresAt == null) return true;
    return DateTime.now().isAfter(expiresAt);
  }

  /// Check if token will expire soon (within 5 minutes)
  bool isTokenExpiringSoon() {
    final expiresAt = getTokenExpiresAt();
    if (expiresAt == null) return true;
    final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));
    return fiveMinutesFromNow.isAfter(expiresAt);
  }

  // ==================== User ID ====================

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    await _prefs?.setString(_keyUserId, userId);
  }

  /// Get user ID
  String? getUserId() {
    return _prefs?.getString(_keyUserId);
  }

  // ==================== Clear All Tokens ====================

  /// Clear all tokens (for logout)
  Future<void> clearAllTokens() async {
    await _prefs?.remove(_keyAccessToken);
    await _prefs?.remove(_keyRefreshToken);
    await _prefs?.remove(_keyTokenExpiresAt);
    await _prefs?.remove(_keyUserId);
    Logger.d('TokenService', 'All tokens cleared');
  }

  // ==================== Save Auth Data ====================

  /// Save all authentication data at once
  Future<void> saveAuthData({
    required String accessToken,
    required String refreshToken,
    DateTime? expiresAt,
    String? userId,
  }) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
    if (expiresAt != null) {
      await saveTokenExpiresAt(expiresAt);
    }
    if (userId != null) {
      await saveUserId(userId);
    }
    Logger.d('TokenService', 'Auth data saved successfully');
  }
}

