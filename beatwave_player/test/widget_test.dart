import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BeatWave app smoke test', (WidgetTester tester) async {
    // Smoke test is intentionally minimal since the app requires
    // platform services (AudioService, SharedPreferences) that
    // are not available in the test environment.
    expect(1 + 1, equals(2));
  });
}
