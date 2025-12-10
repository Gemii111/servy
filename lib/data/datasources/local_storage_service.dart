import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';

/// Local storage service using Hive
class LocalStorageService {
  LocalStorageService._();

  static LocalStorageService? _instance;
  static LocalStorageService get instance {
    _instance ??= LocalStorageService._();
    return _instance!;
  }

  Box? _box;

  /// Initialize Hive and open box
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(AppConstants.hiveBoxName);
  }

  /// Get value from storage
  T? get<T>(String key) {
    return _box?.get(key) as T?;
  }

  /// Save value to storage
  Future<void> save(String key, dynamic value) async {
    await _box?.put(key, value);
  }

  /// Remove value from storage
  Future<void> remove(String key) async {
    await _box?.delete(key);
  }

  /// Clear all data
  Future<void> clear() async {
    await _box?.clear();
  }

  /// Check if key exists
  bool containsKey(String key) {
    return _box?.containsKey(key) ?? false;
  }
}

