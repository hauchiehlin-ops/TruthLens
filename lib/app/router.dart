import 'package:go_router/go_router.dart';

import '../core/models/detection_result.dart';
import '../features/analysis/analysis_screen.dart';
import '../features/history/history_screen.dart';
import '../features/input/input_screen.dart';
import '../features/report/report_screen.dart';
import '../features/settings/settings_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, state) => const InputScreen()),
    GoRoute(
      path: '/analysis',
      builder: (_, state) => AnalysisScreen(text: state.extra as String),
    ),
    GoRoute(
      path: '/report',
      builder: (_, state) =>
          ReportScreen(result: state.extra as DetectionResult),
    ),
    GoRoute(path: '/history', builder: (_, state) => const HistoryScreen()),
    GoRoute(path: '/settings', builder: (_, state) => const SettingsScreen()),
  ],
);
