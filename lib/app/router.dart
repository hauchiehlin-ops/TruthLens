import 'package:go_router/go_router.dart';

import '../core/models/detection_result.dart';
import '../features/analysis/analysis_screen.dart';
import '../features/history/history_screen.dart';
import '../features/input/input_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/report/report_screen.dart';
import '../features/settings/settings_screen.dart';

GoRouter createRouter({required String initialLocation}) => GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(path: '/', builder: (_, _) => const InputScreen()),
        GoRoute(
            path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
        GoRoute(
          path: '/analysis',
          builder: (_, state) => AnalysisScreen(text: state.extra as String),
        ),
        GoRoute(
          path: '/report',
          builder: (_, state) =>
              ReportScreen(result: state.extra as DetectionResult),
        ),
        GoRoute(path: '/history', builder: (_, _) => const HistoryScreen()),
        GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
        GoRoute(
            path: '/models', builder: (_, _) => const ModelManagerScreen()),
      ],
    );
