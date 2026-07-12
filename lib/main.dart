import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'core/detection/model_catalog_service.dart';
import 'core/detection/model_manager.dart';
import 'core/detection/llm_manager.dart';
import 'core/detection/model_provisioner.dart';
import 'core/detection/native_inference_service.dart';
import 'core/detection/orchestrator.dart';
import 'core/detection/report_llm_service.dart';
import 'core/services/history_repository.dart';
import 'core/services/ocr_service.dart';
import 'core/services/preferences_service.dart';
import 'l10n/generated/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = PreferencesService();
  await prefs.load();
  await OcrService.hydrate();

  final modelManager = ModelManager();
  await modelManager.refreshInstallStates();
  final native = NativeInferenceService();
  final catalogService = ModelCatalogService();
  final provisioner = ModelProvisioner(
    catalogService: catalogService,
    modelManager: modelManager,
  );

  // 首次啟動且核心偵測模型未安裝 → 進引導頁；否則直接進首頁。
  final needsOnboarding =
      !prefs.firstRunHandled && !modelManager.isInstalled('transformer');

  runApp(TruthLensApp(
    prefs: prefs,
    modelManager: modelManager,
    native: native,
    provisioner: provisioner,
    initialLocation: needsOnboarding ? '/onboarding' : '/',
  ));
}

class TruthLensApp extends StatelessWidget {
  final PreferencesService prefs;
  final ModelManager modelManager;
  final NativeInferenceService native;
  final ModelProvisioner provisioner;
  final String initialLocation;
  const TruthLensApp({
    super.key,
    required this.prefs,
    required this.modelManager,
    required this.native,
    required this.provisioner,
    required this.initialLocation,
  });

  @override
  Widget build(BuildContext context) {
    final router = createRouter(initialLocation: initialLocation);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: prefs),
        ChangeNotifierProvider.value(value: modelManager),
        Provider.value(value: native),
        Provider.value(value: provisioner),
        Provider.value(value: provisioner.catalogService),
        ChangeNotifierProvider(create: (_) => LlmManager(modelManager: modelManager)),
        Provider(
          create: (_) => EnsembleOrchestrator(
            modelManager: modelManager,
            native: native,
          ),
        ),
        Provider(
          create: (ctx) => ReportLlmService(
            llmManager: ctx.read<LlmManager>(),
          ),
        ),
        Provider(create: (_) => OcrService()),
        Provider(create: (_) => HistoryRepository()),
      ],
      child: Consumer<PreferencesService>(
        builder: (context, prefs, _) => MaterialApp.router(
          title: 'TruthLens',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: prefs.themeMode,
          locale: prefs.locale,
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
            // 裝置語系不在支援清單內時，回退至繁體中文（本 App 的原生預設語言）。
            return supportedLocales.firstWhere(
              (l) => l.languageCode == 'zh' && l.scriptCode == 'Hant',
              orElse: () => supportedLocales.first,
            );
          },
          routerConfig: router,
        ),
      ),
    );
  }
}
