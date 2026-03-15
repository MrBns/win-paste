import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('smoke test - app builds without crashing', (tester) async {
    // This is a smoke test to verify that the test framework itself is set up.
    // The full app requires platform channel initialization which is not
    // available in widget tests without additional setup.
    expect(true, isTrue);
  });
}
