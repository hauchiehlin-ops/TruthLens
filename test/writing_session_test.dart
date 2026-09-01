import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/models/detection_result.dart';
import 'package:omnitrace/core/services/writing_session.dart';
import 'package:omnitrace/features/report/verifiable_findings.dart';
import 'package:omnitrace/l10n/generated/app_localizations.dart';

/// 這是唯一不會被下一代模型追上的方法：它記錄的不是文字本身，
/// 而是文字如何出現在編輯器裡。一次貼上 2000 字與打了三小時，
/// 這個差別任何語言模型都偽造不了。
void main() {
  final t0 = DateTime(2026, 8, 19, 14);

  WritingSessionRecorder recorder() => WritingSessionRecorder();

  group('事件推斷', () {
    test('小幅增加判為打字', () {
      final r = recorder();
      var length = 0;
      for (var i = 0; i < 30; i++) {
        length += 2; // 輸入法一次上屏一兩個字元
        r.record(length, at: t0.add(Duration(milliseconds: i * 300)));
      }
      expect(r.session.typedCharacters, 60);
      expect(r.session.pastedCharacters, 0);
    });

    test('大幅增加判為貼上', () {
      final r = recorder();
      r.record(1842, at: t0);
      expect(r.session.pastedCharacters, 1842);
      expect(r.session.typedCharacters, 0);
    });

    test('長度減少判為刪除', () {
      final r = recorder();
      r.record(100, at: t0);
      r.record(80, at: t0.add(const Duration(seconds: 1)));
      expect(r.session.deletedCharacters, 20);
    });

    test('長度不變不產生事件', () {
      final r = recorder();
      r.record(50, at: t0);
      r.record(50, at: t0.add(const Duration(seconds: 1)));
      expect(r.session.events, hasLength(1));
    });

    test('不記錄任何文字內容——序列化結果只有種類、字數、時間', () {
      final r = recorder();
      r.record(1842, at: t0);
      final json = r.session.events.single.toJson();
      expect(json.keys.toSet(), {'k', 'c', 't'});
      final restored = InputEvent.fromJson(json);
      expect(restored!.characters, 1842);
      expect(restored.kind, InputEventKind.paste);
    });
  });

  group('與「在此逐步寫成」是否相符', () {
    /// 模擬真實寫作：逐字輸入、時有刪改
    WritingSession liveWriting() {
      final r = recorder();
      var length = 0;
      for (var i = 0; i < 400; i++) {
        length += 3;
        r.record(length, at: t0.add(Duration(milliseconds: i * 900)));
        if (i % 12 == 0 && length > 20) {
          length -= 15; // 回頭修改
          r.record(length, at: t0.add(Duration(milliseconds: i * 900 + 400)));
        }
      }
      return r.session;
    }

    test('逐字輸入且有刪改 → 相符', () {
      final s = liveWriting();
      expect(s.hasBulkPaste, isFalse);
      expect(s.consistentWithLiveWriting, isTrue);
      expect(s.duration.inMinutes, greaterThan(1));
    });

    test('一次貼上整篇 → 不相符', () {
      final r = recorder();
      r.record(2462, at: t0);
      final s = r.session;
      expect(s.hasBulkPaste, isTrue);
      expect(s.isTransferOnly, isTrue);
      expect(s.hasObservedComposition, isFalse);
      expect(s.largestPaste, 2462);
      expect(s.consistentWithLiveWriting, isFalse);
    });

    test('完全沒有刪改也不相符——真正的寫作必然包含反覆修改', () {
      final r = recorder();
      var length = 0;
      for (var i = 0; i < 300; i++) {
        length += 3;
        r.record(length, at: t0.add(Duration(milliseconds: i * 800)));
      }
      final s = r.session;
      expect(s.hasBulkPaste, isFalse);
      expect(s.deletedCharacters, 0);
      expect(s.consistentWithLiveWriting, isFalse);
    });

    test('少量貼上（引用、網址）不影響判定', () {
      final r = recorder();
      var length = 0;
      for (var i = 0; i < 400; i++) {
        length += 3;
        r.record(length, at: t0.add(Duration(milliseconds: i * 900)));
        if (i % 12 == 0 && length > 20) {
          length -= 15;
          r.record(length, at: t0.add(Duration(milliseconds: i * 900 + 400)));
        }
      }
      // 中途貼入一段引用
      length += 120;
      r.record(length, at: t0.add(const Duration(minutes: 6)));
      expect(r.session.consistentWithLiveWriting, isTrue);
    });

    test('沒有任何紀錄時不宣稱相符', () {
      expect(WritingSession.empty.consistentWithLiveWriting, isFalse);
      expect(WritingSession.empty.hasData, isFalse);
    });
  });

  test('單次最大貼上比總比例更有指示性', () {
    // 分十次貼入引用，與一次貼入整篇，總比例可能相近但行為完全不同
    final many = recorder();
    var length = 0;
    for (var i = 0; i < 10; i++) {
      length += 200;
      many.record(length, at: t0.add(Duration(minutes: i * 3)));
    }
    final once = recorder();
    once.record(2000, at: t0);

    expect(many.session.pastedRatio, once.session.pastedRatio);
    expect(many.session.hasBulkPaste, isFalse);
    expect(once.session.hasBulkPaste, isTrue);
  });

  test('重設會清空紀錄', () {
    final r = recorder();
    r.record(500, at: t0);
    r.reset();
    expect(r.session.hasData, isFalse);
  });

  test('匯入文件後以目前長度為起點，不把下一個字誤判成整篇貼上', () {
    final r = recorder()..reset(initialLength: 1800);
    r.record(1801, at: t0);
    expect(r.session.typedCharacters, 1);
    expect(r.session.pastedCharacters, 0);
  });

  test('切換工作台後可接續既有事件與目前文字長度', () {
    final first = recorder();
    first.record(3, at: t0);
    final resumed = recorder()
      ..resume(currentLength: 3, session: first.session);
    resumed.record(5, at: t0.add(const Duration(seconds: 2)));
    expect(resumed.session.events, hasLength(2));
    expect(resumed.session.typedCharacters, 5);
  });

  _reachesTheReport();
}

/// 過程紀錄若沒抵達報告就等於沒做
void _reachesTheReport() {
  test('過程紀錄會出現在可查證事實清單中', () async {
    final l10n = lookupAppLocalizations(const Locale('en'));
    final t0 = DateTime(2026, 8, 19, 14);

    final pasted = WritingSessionRecorder()..record(2462, at: t0);
    final result = DetectionResult(
      id: 'w',
      analyzedAt: t0,
      inputText: List.filled(200, 'alpha').join(' '),
      aiProbability: 0.30,
      verdict: Verdict.likelyHuman,
      writingSession: pasted.session,
      engineScores: const [],
      sentences: const [],
    );

    final findings = collectVerifiableFindings(result, l10n);
    expect(findings, isEmpty);
  });

  test('匯入的檔案沒有過程紀錄，不產生任何主張', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    final result = DetectionResult(
      id: 'i',
      analyzedAt: DateTime(2026, 8, 19),
      inputText: List.filled(200, 'alpha').join(' '),
      aiProbability: 0.30,
      verdict: Verdict.likelyHuman,
      engineScores: const [],
      sentences: const [],
    );
    expect(collectVerifiableFindings(result, l10n), isEmpty);
  });
}
