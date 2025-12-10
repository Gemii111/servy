import 'package:flutter_test/flutter_test.dart';
import 'package:servy/core/constants/app_constants.dart';
import 'package:servy/core/constants/api_constants.dart';

void main() {
  group('AppConstants', () {
    test('should have correct default values', () {
      expect(AppConstants.defaultLatitude, equals(24.7136));
      expect(AppConstants.defaultLongitude, equals(46.6753));
      expect(AppConstants.defaultDeliveryTime, equals(25));
      expect(AppConstants.defaultPageSize, equals(20));
    });

    test('should have correct storage keys', () {
      expect(AppConstants.hiveBoxName, equals('servy_customer_box'));
      expect(AppConstants.authTokenKey, equals('auth_token'));
      expect(AppConstants.userIdKey, equals('user_id'));
    });
  });

  group('ApiConstants', () {
    test('should have correct base URL', () {
      expect(ApiConstants.baseUrl, equals('http://localhost:8080'));
    });

    test('should have all required endpoints', () {
      expect(ApiConstants.login, equals('/auth/login'));
      expect(ApiConstants.register, equals('/auth/register'));
      expect(ApiConstants.restaurants, equals('/restaurants'));
      expect(ApiConstants.orders, equals('/orders'));
    });

    test('should have correct timeouts', () {
      expect(ApiConstants.connectTimeout, equals(const Duration(seconds: 30)));
      expect(ApiConstants.receiveTimeout, equals(const Duration(seconds: 30)));
    });
  });
}

