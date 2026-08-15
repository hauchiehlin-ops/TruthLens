import 'package:flutter/material.dart';
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

  test(
    'appearance defaults to system brightness and handles unknown values',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = PreferencesService();
      await preferences.load();
      expect(preferences.themeMode, ThemeMode.system);

      SharedPreferences.setMockInitialValues({'theme_mode': 'retiredTheme'});
      final reloaded = PreferencesService();
      await reloaded.load();
      expect(reloaded.themeMode, ThemeMode.system);
    },
  );

  test('an existing saved threshold is preserved', () async {
    SharedPreferences.setMockInitialValues({'confidence_threshold': 0.75});
    final preferences = PreferencesService();

    await preferences.load();

    expect(preferences.confidenceThreshold, 0.75);
  });

  test(
    'AI confidence threshold is clamped to the 20 percent minimum',
    () async {
      SharedPreferences.setMockInitialValues({'confidence_threshold': 0.1});
      final preferences = PreferencesService();

      await preferences.load();

      expect(preferences.confidenceThreshold, 0.2);

      await preferences.setThreshold(0.1);

      expect(preferences.confidenceThreshold, 0.2);
    },
  );

  test('engine weights default to 40/25/20/15 and persist locally', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = PreferencesService();
    await preferences.load();

    expect(preferences.engineWeight('transformer'), 0.40);
    expect(preferences.engineWeight('statistical'), 0.25);
    expect(preferences.engineWeight('stylometry'), 0.20);
    expect(preferences.engineWeight('adversarial'), 0.15);

    await preferences.setEngineWeights(const {
      'transformer': 0.10,
      'statistical': 0.20,
      'stylometry': 0.30,
      'adversarial': 0.40,
    });
    final reloaded = PreferencesService();
    await reloaded.load();

    expect(reloaded.engineWeight('transformer'), 0.10);
    expect(reloaded.engineWeight('adversarial'), 0.40);
  });

  test('engine weights cannot be saved unless they total 100%', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = PreferencesService();
    await preferences.load();

    await expectLater(
      preferences.setEngineWeights(const {
        'transformer': 0.40,
        'statistical': 0.25,
        'stylometry': 0.20,
        'adversarial': 0.20,
      }),
      throwsArgumentError,
    );
  });

  test('removed bibliography credentials are deleted during load', () async {
    SharedPreferences.setMockInitialValues({
      'web_of_science_api_key': 'wos-key',
      'engineering_village_api_key': 'ei-key',
      'engineering_village_institution_token': 'inst-token',
    });

    final preferences = PreferencesService();
    await preferences.load();

    final storage = await SharedPreferences.getInstance();
    expect(storage.containsKey('web_of_science_api_key'), isFalse);
    expect(storage.containsKey('engineering_village_api_key'), isFalse);
    expect(
      storage.containsKey('engineering_village_institution_token'),
      isFalse,
    );
  });

  test('workspace mode defaults to original and persists locally', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = PreferencesService();
    await preferences.load();

    expect(preferences.workspaceMode, WorkspaceMode.original);
    await preferences.setWorkspaceMode(WorkspaceMode.evidenceCanvas);

    final reloaded = PreferencesService();
    await reloaded.load();
    expect(reloaded.workspaceMode, WorkspaceMode.evidenceCanvas);
  });

  test('unknown saved workspace mode falls back to original', () async {
    SharedPreferences.setMockInitialValues({'workspace_mode': 'retiredMode'});
    final preferences = PreferencesService();

    await preferences.load();

    expect(preferences.workspaceMode, WorkspaceMode.original);
  });
}
