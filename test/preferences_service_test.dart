import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truthlens/core/services/preferences_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('new installations default AI confidence threshold to 50%', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = PreferencesService();

    await preferences.load();

    expect(preferences.confidenceThreshold, 0.5);
  });

  test('an existing saved threshold is preserved', () async {
    SharedPreferences.setMockInitialValues({'confidence_threshold': 0.75});
    final preferences = PreferencesService();

    await preferences.load();

    expect(preferences.confidenceThreshold, 0.75);
  });
}
