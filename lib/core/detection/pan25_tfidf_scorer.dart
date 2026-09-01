import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';

/// Compact local implementation of the official PAN 2025 TF-IDF/LinearSVC
/// baseline. The asset contains only vocabulary, IDF and linear coefficients;
/// no document text leaves the device.
class Pan25TfidfScorer {
  static const assetPath = 'assets/models/pan25_tfidf_svm.json';
  static Future<Pan25TfidfScorer>? _shared;

  final Map<String, int> _vocabulary;
  final List<double> _idf;
  final List<double> _coefficients;
  final double _intercept;

  const Pan25TfidfScorer._(
    this._vocabulary,
    this._idf,
    this._coefficients,
    this._intercept,
  );

  static Future<Pan25TfidfScorer> load() => _shared ??= _load();

  static Future<Pan25TfidfScorer> _load() async {
    final decoded = jsonDecode(await rootBundle.loadString(assetPath));
    if (decoded is! Map<String, dynamic> ||
        decoded['format'] != 'omnitrace-pan25-tfidf-svm-v1') {
      throw const FormatException('Unsupported PAN 2025 model asset');
    }
    final vocabulary = (decoded['vocabulary'] as Map<String, dynamic>).map(
      (term, index) => MapEntry(term, (index as num).toInt()),
    );
    final idf = (decoded['idf'] as List)
        .map((value) => (value as num).toDouble())
        .toList(growable: false);
    final coefficients = (decoded['coefficients'] as List)
        .map((value) => (value as num).toDouble())
        .toList(growable: false);
    if (idf.length != coefficients.length || vocabulary.length != idf.length) {
      throw const FormatException('PAN 2025 model dimensions do not match');
    }
    return Pan25TfidfScorer._(
      vocabulary,
      idf,
      coefficients,
      (decoded['intercept'] as num).toDouble(),
    );
  }

  /// Returns the same logistic decision score as LinearSVC._predict_proba_lr.
  double score(String raw) {
    final tokens = RegExp(
      r'\b[a-z0-9_]{2,}\b',
      caseSensitive: false,
    ).allMatches(raw.toLowerCase()).map((match) => match.group(0)!).toList();
    if (tokens.isEmpty) return 0.5;

    final counts = <int, double>{};
    for (var n = 1; n <= 4; n++) {
      for (var start = 0; start + n <= tokens.length; start++) {
        final term = tokens.sublist(start, start + n).join(' ');
        final index = _vocabulary[term];
        if (index != null) {
          counts.update(index, (value) => value + 1, ifAbsent: () => 1);
        }
      }
    }
    if (counts.isEmpty) return 0.5;

    var squaredNorm = 0.0;
    for (final entry in counts.entries.toList(growable: false)) {
      final value = entry.value * _idf[entry.key];
      counts[entry.key] = value;
      squaredNorm += value * value;
    }
    final norm = math.sqrt(squaredNorm);
    if (norm == 0) return 0.5;

    var decision = _intercept;
    for (final entry in counts.entries) {
      decision += entry.value / norm * _coefficients[entry.key];
    }
    return 1 / (1 + math.exp(-decision));
  }

  static void resetForTesting() => _shared = null;
}
