import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';

class DetectRlZhScore {
  final double probability;
  final double decision;
  final double aiDecisionCut;
  final bool supportsAi;

  const DetectRlZhScore({
    required this.probability,
    required this.decision,
    required this.aiDecisionCut,
    required this.supportsAi,
  });
}

/// Compact, local Chinese authorship fingerprint trained on DetectRL-ZH.
///
/// Character n-grams avoid the whitespace-tokenisation bias that made the
/// English lexical detector inapplicable to Chinese. A low score is not a
/// human vote: only scores crossing the conservative development-set gate are
/// exposed as directional evidence.
class DetectRlZhCharScorer {
  static const assetPath = 'assets/models/detectrl_zh_char_svm.json';
  static Future<DetectRlZhCharScorer>? _shared;

  final Map<String, int> _termIndex;
  final List<double> _idf;
  final List<double> _coefficients;
  final int _minimumCharacters;
  final double _intercept;
  final double _aiDecisionCut;
  final double _plattScale;
  final double _plattIntercept;

  const DetectRlZhCharScorer._({
    required Map<String, int> termIndex,
    required List<double> idf,
    required List<double> coefficients,
    required int minimumCharacters,
    required double intercept,
    required double aiDecisionCut,
    required double plattScale,
    required double plattIntercept,
  }) : _termIndex = termIndex,
       _idf = idf,
       _coefficients = coefficients,
       _minimumCharacters = minimumCharacters,
       _intercept = intercept,
       _aiDecisionCut = aiDecisionCut,
       _plattScale = plattScale,
       _plattIntercept = plattIntercept;

  static Future<DetectRlZhCharScorer> load() => _shared ??= _load();

  static Future<DetectRlZhCharScorer> _load() async {
    final decoded = jsonDecode(await rootBundle.loadString(assetPath));
    if (decoded is! Map<String, dynamic> ||
        decoded['format'] != 'truthlens-detectrl-zh-char-svm-v1') {
      throw const FormatException('Unsupported DetectRL-ZH model asset');
    }
    final terms = (decoded['terms'] as List).cast<String>();
    final idf = (decoded['idf'] as List)
        .map((value) => (value as num).toDouble())
        .toList(growable: false);
    final coefficients = (decoded['coefficients'] as List)
        .map((value) => (value as num).toDouble())
        .toList(growable: false);
    if (terms.length != idf.length || terms.length != coefficients.length) {
      throw const FormatException('DetectRL-ZH model dimensions do not match');
    }
    return DetectRlZhCharScorer._(
      termIndex: {for (var i = 0; i < terms.length; i++) terms[i]: i},
      idf: idf,
      coefficients: coefficients,
      minimumCharacters: (decoded['minimum_characters'] as num).toInt(),
      intercept: (decoded['intercept'] as num).toDouble(),
      aiDecisionCut: (decoded['ai_decision_cut'] as num).toDouble(),
      plattScale: (decoded['platt_scale'] as num).toDouble(),
      plattIntercept: (decoded['platt_intercept'] as num).toDouble(),
    );
  }

  DetectRlZhScore? score(String raw) {
    final normalized = raw.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
    final characters = normalized.runes.toList(growable: false);
    if (characters.length < _minimumCharacters) return null;

    final counts = <int, double>{};
    for (var n = 2; n <= 5; n++) {
      for (var start = 0; start + n <= characters.length; start++) {
        final term = String.fromCharCodes(characters, start, start + n);
        final index = _termIndex[term];
        if (index != null) {
          counts.update(index, (value) => value + 1, ifAbsent: () => 1);
        }
      }
    }
    if (counts.isEmpty) return null;

    var squaredNorm = 0.0;
    for (final entry in counts.entries.toList(growable: false)) {
      final termFrequency = 1 + math.log(entry.value);
      final value = termFrequency * _idf[entry.key];
      counts[entry.key] = value;
      squaredNorm += value * value;
    }
    if (squaredNorm <= 0) return null;

    final norm = math.sqrt(squaredNorm);
    var decision = _intercept;
    for (final entry in counts.entries) {
      decision += entry.value / norm * _coefficients[entry.key];
    }
    final logit = (_plattScale * decision + _plattIntercept).clamp(-30.0, 30.0);
    final probability = 1 / (1 + math.exp(-logit));
    return DetectRlZhScore(
      probability: probability,
      decision: decision,
      aiDecisionCut: _aiDecisionCut,
      supportsAi: decision >= _aiDecisionCut,
    );
  }

  static void resetForTesting() => _shared = null;
}
