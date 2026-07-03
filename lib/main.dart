import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'core/detection/model_catalog_service.dart';
import 'core/detection/model_manager.dart';
import 'core/detection/model_provisioner.dart';
import 'core/detection/native_inference_service.dart';
import 'core/detection/orchestrator.dart';
import 'core/detection/report_llm_service.dart';
import 'core/services/history_repository.dart';
import 'core/services/ocr_service.dart';
import 'core/services/preferences_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = PreferencesService();
  await prefs.load();

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
        Provider(
          create: (_) => EnsembleOrchestrator(
            modelManager: modelManager,
            native: native,
          ),
        ),
        Provider(create: (_) => ReportLlmService(modelManager: modelManager)),
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
          routerConfig: router,
        ),
      ),
    );
  }
}
