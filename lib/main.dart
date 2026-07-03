import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'core/detection/model_manager.dart';
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

  runApp(TruthLensApp(
    prefs: prefs,
    modelManager: modelManager,
    native: native,
  ));
}

class TruthLensApp extends StatelessWidget {
  final PreferencesService prefs;
  final ModelManager modelManager;
  final NativeInferenceService native;
  const TruthLensApp({
    super.key,
    required this.prefs,
    required this.modelManager,
    required this.native,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: prefs),
        ChangeNotifierProvider.value(value: modelManager),
        Provider.value(value: native),
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
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
