import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/detection/authorship_delta.dart';
import 'package:truthlens/core/utils/text_stats.dart';

/// 換一個問題：不問「是不是 AI 寫的」，問「像不像這位作者平常的寫法」。
/// 前者會隨模型進步愈來愈難答；後者錨定在人身上，不隨模型世代失效。
StyleProfile _profile(String text) =>
    buildStyleProfile(PreprocessedText.from(text).allTokens);

/// 同一位「作者」的六篇樣本：長句、大量使用 the／of／which／that，
/// 題材各不相同——這正是功能詞剖面的重點，它反映習慣而非主題。
const _authorA = <String>[
  'The analysis of the boundary which follows from the linear theory of the '
      'problem is presented in the sections that follow, and the results of '
      'the comparison with the measurements of the earlier study are '
      'discussed in the light of the assumptions which underlie the model.',
  'The purpose of the present chapter is to set out the terms of the debate '
      'which has surrounded the interpretation of the sources, and to '
      'indicate the extent to which the conclusions of the earlier writers '
      'can be sustained in the light of the evidence that has since emerged.',
  'The design of the apparatus was governed by the need to maintain the '
      'temperature of the working fluid within the limits that the theory '
      'requires, and by the constraints which the geometry of the vessel '
      'imposes on the placement of the instruments that record the data.',
  'The account of the negotiations which appears in the official record is '
      'at variance with the recollections of the participants, and the task '
      'of the historian is to weigh the reliability of the documents against '
      'the testimony of those who were present at the meetings in question.',
  'The distribution of the observed values is consistent with the form of '
      'the model that was proposed in the preceding section, although the '
      'magnitude of the deviations at the upper end of the range suggests '
      'that the assumptions which govern the treatment may require revision.',
  'The character of the landscape in the region is determined by the nature '
      'of the underlying rock and by the pattern of the drainage which has '
      'developed over the course of the period that followed the retreat of '
      'the ice from the valleys of the northern part of the territory.',
];

/// 另一位「作者」：短句，少用 of／which，多用 we／but／it／can
const _authorB = <String>[
  'We looked at what happens near the edge. It was not clear at first. But '
      'we kept going and it started to make sense. We can say now that the '
      'pattern shows up when you push past a point. It is not a sharp line '
      'but it is close enough to one for what we need here.',
  'I tried it again with a smaller sample. Same thing. So it is not just '
      'noise. But I want to be careful here. We have seen this before and it '
      'turned out to be an artefact. This time we checked it twice and it '
      'still held up. That is good but it is not proof yet.',
  'The room was cold and nobody wanted to be there. We talked for an hour '
      'and got nowhere. Then somebody said the obvious thing and it all fell '
      'into place. It happens like that sometimes. You go round in circles '
      'and then one plain remark cuts through it all at once.',
  'You can set it up in about ten minutes. Plug it in, run the check, and '
      'wait. If the light stays green you are fine. If it blinks, stop and '
      'look at the log. Most of the time it is a loose cable. We have had it '
      'happen more than once and it is always something small.',
  'She said it would rain and it did. We had to move everything inside and '
      'it took ages. By the time we were done the sun was out again. That is '
      'how it goes here. You plan for one thing and get another. But we got '
      'it finished in the end and nobody seemed to mind the wait.',
  'It is not that the old way was wrong. It just does not fit what we do '
      'now. We kept it going far longer than we should have. Then one day it '
      'broke and we had to think again. What we have now is simpler and it '
      'does the job. I wish we had changed it sooner but there it is.',
];

/// 每份段落約 46 個詞元，需 5 份才達到 StyleProfile.minimumTokens（200）。
///
/// 以**留一法**組合：第 index 份樣本排除第 index 段。這讓各參考樣本
/// 真正互不相同——若每份都包含相同的段落集合（只是順序不同），
/// 每個功能詞的頻率會完全一致、變異數為 0，Delta 會正確地算出 NaN
/// （沒有變異就無從判斷偏離）。那是退化的 fixture，不是可用的測試。
String _text(List<String> samples, int index) => [
  for (var i = 0; i < samples.length; i++)
    if (i != index % samples.length) samples[i],
].join(' ');

void main() {
  group('剖面建立', () {
    test('只統計功能詞，且以總詞數為分母', () {
      final p = _profile(_text(_authorA, 0));
      expect(p.tokenCount, greaterThan(200));
      expect(p.frequencies['the'], greaterThan(0));
      // 內容詞不在剖面裡——它們反映主題，不反映習慣
      expect(p.frequencies.containsKey('boundary'), isFalse);
    });

    test('太短的樣本標記為不可用', () {
      expect(_profile('Short text here.').isUsable, isFalse);
    });

    test('剖面可序列化且不含原文', () {
      final p = _profile(_text(_authorA, 0));
      final json = p.toJson();
      expect(json.toString(), isNot(contains('boundary')));
      final restored = StyleProfile.fromJson(json);
      expect(restored, isNotNull);
      expect(restored!.tokenCount, p.tokenCount);
    });
  });

  group('比對', () {
    late List<StyleProfile> reference;

    setUp(() {
      reference = [for (var i = 0; i < 6; i++) _profile(_text(_authorA, i))];
    });

    test('同一位作者的新文章落在自身變異範圍內', () {
      final result = compareAuthorship(_profile(_text(_authorA, 2)), reference);
      expect(result, isNotNull);
      expect(result!.isOutlier, isFalse);
    });

    test('另一位作者的文章明顯偏離', () {
      final result = compareAuthorship(_profile(_text(_authorB, 0)), reference);
      expect(result, isNotNull);
      expect(
        result!.delta,
        greaterThan(
          compareAuthorship(_profile(_text(_authorA, 2)), reference)!.delta,
        ),
        reason: '不同作者的 Delta 應大於同一作者',
      );
    });
  });

  group('樣本不足時不下結論', () {
    test('參考樣本少於門檻時回傳 null', () {
      final few = [for (var i = 0; i < 3; i++) _profile(_text(_authorA, i))];
      expect(compareAuthorship(_profile(_text(_authorA, 1)), few), isNull);
    });

    test('待測文件太短時回傳 null', () {
      final reference = [
        for (var i = 0; i < 6; i++) _profile(_text(_authorA, i)),
      ];
      expect(compareAuthorship(_profile('Too short.'), reference), isNull);
    });

    test('沒有參考語料時 Delta 為 NaN，不是 0', () {
      // 回 0 會被誤讀成「完全相符」
      expect(
        burrowsDelta(_profile(_text(_authorA, 0)), const []).isNaN,
        isTrue,
      );
    });
  });

  test('Delta 只在同一組參考語料內可解讀，因此回報的是百分位', () {
    final reference = [
      for (var i = 0; i < 6; i++) _profile(_text(_authorA, i)),
    ];
    final result = compareAuthorship(_profile(_text(_authorA, 3)), reference);
    expect(result!.percentile, inInclusiveRange(0, 100));
    expect(result.referenceCount, 6);
  });
}
