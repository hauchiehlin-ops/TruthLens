import 'package:flutter/material.dart';

/// Material Design 3，深色模式優先。字體：Inter + Noto Sans TC（本地內嵌）
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
      textTheme: _buildTextTheme(baseText),
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

  /// 建立文字主題（使用本地 Inter 字體）
  static TextTheme _buildTextTheme(TextTheme baseText) {
    const fontFamily = 'Inter';
    return baseText.copyWith(
      displayLarge: baseText.displayLarge?.copyWith(fontFamily: fontFamily),
      displayMedium: baseText.displayMedium?.copyWith(fontFamily: fontFamily),
      displaySmall: baseText.displaySmall?.copyWith(fontFamily: fontFamily),
      headlineLarge: baseText.headlineLarge?.copyWith(fontFamily: fontFamily),
      headlineMedium: baseText.headlineMedium?.copyWith(fontFamily: fontFamily),
      headlineSmall: baseText.headlineSmall?.copyWith(fontFamily: fontFamily),
      titleLarge: baseText.titleLarge?.copyWith(fontFamily: fontFamily),
      titleMedium: baseText.titleMedium?.copyWith(fontFamily: fontFamily),
      titleSmall: baseText.titleSmall?.copyWith(fontFamily: fontFamily),
      bodyLarge: baseText.bodyLarge?.copyWith(fontFamily: fontFamily),
      bodyMedium: baseText.bodyMedium?.copyWith(fontFamily: fontFamily),
      bodySmall: baseText.bodySmall?.copyWith(fontFamily: fontFamily),
      labelLarge: baseText.labelLarge?.copyWith(fontFamily: fontFamily),
      labelMedium: baseText.labelMedium?.copyWith(fontFamily: fontFamily),
      labelSmall: baseText.labelSmall?.copyWith(fontFamily: fontFamily),
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
