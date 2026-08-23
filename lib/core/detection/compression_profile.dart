import 'dart:convert';
import 'dart:math' as math;

import 'package:archive/archive.dart';

/// Compression-based cross-boundary coherence (CBC).
///
/// This independent, one-sided screening signal is calibrated on the PAN 2025
/// English corpus. Crossing the human 95th percentile can support an AI
/// direction, while a low score never proves human authorship.
class CompressionProfile {
  static const double pan25Human95thPercentile = 0.18321132475578705;

  final double coherence;

  const CompressionProfile({required this.coherence});

  static CompressionProfile? analyze(String raw) {
    final words = RegExp(r'\b[a-zA-Z0-9_]{2,}\b').allMatches(raw).length;
    if (words < 100) return null;
    final bytes = utf8.encode(raw);
    if (bytes.length < 500) return null;

    final split = bytes.length ~/ 2;
    final encoder = ZLibEncoder();
    final cx = encoder.encode(bytes.sublist(0, split)).length.toDouble();
    final cy = encoder.encode(bytes.sublist(split)).length.toDouble();
    final cxy = encoder.encode(bytes).length.toDouble();
    final denominator = math.sqrt(cx * cy);
    if (denominator == 0) return null;
    return CompressionProfile(coherence: (cx + cy - cxy) / denominator);
  }

  bool get supportsAi => coherence >= pan25Human95thPercentile;

  double get aiRatio {
    if (!supportsAi) return 0.5;
    final distance = ((coherence - pan25Human95thPercentile) / 0.10).clamp(
      0.0,
      1.0,
    );
    return 0.62 + distance * 0.28;
  }
}
