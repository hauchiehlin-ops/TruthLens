import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truthlens/core/services/preferences_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  test(
    'legacy disabled engine preferences are reset on schema migration',
    () async {
      SharedPreferences.setMockInitialValues({
        'disabled_engines': ['transformer', 'statistical'],
        'engine_preferences_schema': 1,
      });
      final preferences = PreferencesService();

      await preferences.load();

      expect(preferences.isEngineEnabled('transformer'), isTrue);
      expect(preferences.isEngineEnabled('statistical'), isTrue);
      final storage = await SharedPreferences.getInstance();
      expect(storage.getStringList('disabled_engines'), isNull);
      expect(storage.getInt('engine_preferences_schema'), 2);
    },
  );

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

  test(
    'workspace mode defaults to command grid and persists locally',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = PreferencesService();
      await preferences.load();

      expect(preferences.workspaceMode, WorkspaceMode.commandGrid);
      await preferences.setWorkspaceMode(WorkspaceMode.evidenceCanvas);

      final reloaded = PreferencesService();
      await reloaded.load();
      expect(reloaded.workspaceMode, WorkspaceMode.evidenceCanvas);
    },
  );

  test('unknown saved workspace mode falls back to command grid', () async {
    SharedPreferences.setMockInitialValues({'workspace_mode': 'retiredMode'});
    final preferences = PreferencesService();

    await preferences.load();

    expect(preferences.workspaceMode, WorkspaceMode.commandGrid);
  });

  test('workspace mode notifies the UI before persistence completes', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = PreferencesService();
    await preferences.load();
    var notifications = 0;
    preferences.addListener(() => notifications++);

    final persistence = preferences.setWorkspaceMode(
      WorkspaceMode.missionTimeline,
    );

    expect(preferences.workspaceMode, WorkspaceMode.missionTimeline);
    expect(notifications, 1);
    await persistence;
  });
}
