import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Material Design 3，深色模式優先。字體：Inter + Noto Sans TC。
class AppTheme {
  static const _seed = Color(0xFF4F8FFF);

  static ThemeData dark() => _base(Brightness.dark);
  static ThemeData light() => _base(Brightness.light);

  static ThemeData _base(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    final baseText = brightness == Brightness.dark
        ? Typography.material2021().white
        : Typography.material2021().black;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: GoogleFonts.interTextTheme(baseText),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        filled: true,
      ),
    );
  }

  /// 依 AI 機率取得語意色（綠 → 黃 → 橘 → 紅）
  static Color verdictColor(double aiProbability) {
    if (aiProbability < 0.2) return const Color(0xFF4CAF50);
    if (aiProbability < 0.4) return const Color(0xFFCDDC39);
    if (aiProbability < 0.6) return const Color(0xFFFF9800);
    if (aiProbability < 0.8) return const Color(0xFFFF5722);
    return const Color(0xFFF44336);
  }
}
