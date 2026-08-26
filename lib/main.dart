import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/semantics.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:provider/provider.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'core/detection/model_catalog_service.dart';
import 'core/detection/model_manager.dart';
import 'core/detection/llm_manager.dart';
import 'core/detection/model_provisioner.dart';
import 'core/detection/orchestrator.dart';
import 'core/detection/report_llm_service.dart';
import 'core/services/history_repository.dart';
import 'core/services/ocr_config_notifier.dart';
import 'core/services/ocr_service.dart';
import 'core/services/calibration_service.dart';
import 'core/services/preferences_service.dart';
import 'core/utils/app_version.dart';
import 'l10n/generated/app_localizations.dart';

import 'core/detection/llama_ffi.dart';

const _webPreferenceStartupTimeout = Duration(seconds: 5);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  pdfrxFlutterInitialize();
  AppLifecycleListener(
    onExitRequested: () async {
      try {
        LlamaFfi.backendFree();
      } catch (_) {}
      return AppExitResponse.exit;
    },
  );
  final prefs = PreferencesService();
  final calibration = CalibrationService();
  final modelManager = ModelManager();
  final catalogService = ModelCatalogService();
  final provisioner = ModelProvisioner(
    catalogService: catalogService,
    modelManager: modelManager,
  );

  var webPreferencesReady = true;
  if (kIsWeb) {
    // Android Chrome may need a long time to reopen OPFS when large local
    // models are installed. Only the small preference payload is allowed to
    // delay the first frame, and even that wait is bounded.
    try {
      await prefs.load().timeout(_webPreferenceStartupTimeout);
    } catch (error) {
      webPreferencesReady = false;
      debugPrint('[Startup] Web preferences deferred: $error');
    }
  } else {
    await Future.wait([AppVersion.init(), prefs.load(), calibration.load()]);
    await OcrService.hydrate();
    await modelManager.refreshInstallStates();
  }

  // 首次啟動且核心偵測模型未安裝 → 進引導頁；否則直接進首頁。
  final needsOnboarding =
      webPreferencesReady &&
      !prefs.firstRunHandled &&
      !modelManager.isInstalled('transformer');

  runApp(
    TruthLensApp(
      prefs: prefs,
      modelManager: modelManager,
      provisioner: provisioner,
      calibration: calibration,
      initialLocation: needsOnboarding ? '/onboarding' : '/',
    ),
  );
  if (kIsWeb) SemanticsBinding.instance.ensureSemantics();

  if (kIsWeb) {
    // Restore non-essential browser state after runApp. Model health checks can
    // touch hundreds of megabytes in OPFS and must never hold the HTML startup
    // shell hostage during an Android refresh.
    unawaited(
      Future.wait([
        _runStartupTask('app version', AppVersion.init),
        _runStartupTask('calibration', calibration.load),
        _runStartupTask('OCR settings', OcrService.hydrate),
        _runStartupTask('model inventory', modelManager.refreshInstallStates),
      ]),
    );
  }
}

Future<void> _runStartupTask(
  String label,
  Future<void> Function() operation,
) async {
  try {
    await operation();
  } catch (error) {
    debugPrint('[Startup] Unable to restore $label: $error');
  }
}

class TruthLensApp extends StatelessWidget {
  final PreferencesService prefs;
  final ModelManager modelManager;
  final ModelProvisioner provisioner;
  final CalibrationService calibration;
  final String initialLocation;
  const TruthLensApp({
    super.key,
    required this.prefs,
    required this.modelManager,
    required this.provisioner,
    required this.calibration,
    required this.initialLocation,
  });

  @override
  Widget build(BuildContext context) {
    final router = createRouter(initialLocation: initialLocation);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: prefs),
        ChangeNotifierProvider.value(value: modelManager),
        ChangeNotifierProvider.value(value: calibration),
        Provider.value(value: provisioner),
        Provider.value(value: provisioner.catalogService),
        ChangeNotifierProvider(
          create: (_) => LlmManager(modelManager: modelManager),
        ),
        Provider(
          create: (_) => EnsembleOrchestrator(modelManager: modelManager),
        ),
        Provider(
          create: (ctx) => ReportLlmService(llmManager: ctx.read<LlmManager>()),
        ),
        Provider(create: (_) => OcrService()),
        ChangeNotifierProvider(create: (_) => OcrConfigNotifier()),
        Provider(create: (_) => HistoryRepository()),
      ],
      child: Consumer<PreferencesService>(
        builder: (context, prefs, _) => MaterialApp.router(
          title: 'TruthLens',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: prefs.themeMode,
          locale: prefs.locale ?? const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (deviceLocale, supportedLocales) {
            if (deviceLocale == null) return supportedLocales.first;
            for (final l in supportedLocales) {
              if (l.languageCode == deviceLocale.languageCode &&
                  l.scriptCode == deviceLocale.scriptCode) {
                return l;
              }
            }
            for (final l in supportedLocales) {
              if (l.languageCode == deviceLocale.languageCode) return l;
            }
            // 裝置語系不在支援清單內時，回退至英文（專案預設介面語系）。
            return supportedLocales.firstWhere(
              (l) => l.languageCode == 'en',
              orElse: () => supportedLocales.first,
            );
          },
          routerConfig: router,
        ),
      ),
    );
  }
}
