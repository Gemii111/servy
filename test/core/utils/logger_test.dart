import 'package:flutter_test/flutter_test.dart';
import 'package:servy/core/utils/logger.dart';

void main() {
  group('Logger', () {
    test('should not throw errors when logging', () {
      expect(() => Logger.d('Test', 'Debug message'), returnsNormally);
      expect(() => Logger.i('Test', 'Info message'), returnsNormally);
      expect(() => Logger.w('Test', 'Warning message'), returnsNormally);
      expect(() => Logger.e('Test', 'Error message'), returnsNormally);
    });

    test('should handle null messages', () {
      expect(() => Logger.d('Test', null), returnsNormally);
      expect(() => Logger.e('Test', null), returnsNormally);
    });
  });
}

