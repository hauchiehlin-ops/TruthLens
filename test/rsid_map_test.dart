import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/services/document_provenance.dart';
import 'package:truthlens/core/services/rsid_map.dart';

/// 只數全文有幾個相異 RSID，得到的是整份文件一個結論。
/// 逐段展開之後，能指出**哪幾段**屬於同一批——這把「這份文件可疑」
/// 變成「這三段是一次寫入的」，可指認到具體位置。
String _paragraph(String rsid, String text) =>
    '<w:p w:rsidR="$rsid" w:rsidRDefault="$rsid">'
    '<w:r w:rsidR="$rsid"><w:t>$text</w:t></w:r></w:p>';

int _countWords(String s) => DocumentProvenance.countWords(s);

void main() {
  test('逐段歸入各自的編輯批次', () {
    final xml = [
      _paragraph('AAAA1111', 'The first paragraph was written early on.'),
      _paragraph('BBBB2222', 'The second paragraph came in a later session.'),
      _paragraph('AAAA1111', 'This one belongs with the first batch again.'),
    ].join();

    final map = buildRsidMap(xml, _countWords);
    expect(map.paragraphCount, 3);
    expect(map.batches.length, 2);
    // 依字數排序，最大的批次涵蓋兩段
    expect(map.batches.first.paragraphIndices, [0, 2]);
    expect(map.batches.last.paragraphIndices, [1]);
  });

  test('空段落不計入，不影響段落序號以外的統計', () {
    final xml =
        '<w:p w:rsidR="AAAA1111"><w:r><w:t></w:t></w:r></w:p>'
        '${_paragraph('AAAA1111', 'Only this paragraph carries text.')}';
    final map = buildRsidMap(xml, _countWords);
    expect(map.batches.single.paragraphIndices.length, 1);
  });

  test('沒有 RSID 屬性時回傳空結果，不猜測', () {
    const xml = '<w:p><w:r><w:t>No revision identifiers here at all.</w:t></w:r></w:p>';
    expect(buildRsidMap(xml, _countWords).hasData, isFalse);
    expect(buildRsidMap('', _countWords).hasData, isFalse);
  });

  group('集中度判定', () {
    test('內容平均散在多個批次時不示警——這是逐步寫成的形態', () {
      // RSID 是十六進位值，fixture 必須用合法的十六進位字元
      final xml = List.generate(
        8,
        (i) => _paragraph(
          '00AB${(0x1000 + i).toRadixString(16).toUpperCase()}',
          'Paragraph number $i contains a comparable amount of text here.',
        ),
      ).join();

      final map = buildRsidMap(xml, _countWords);
      expect(map.paragraphCount, 8);
      expect(map.isHighlyConcentrated, isFalse);
      expect(map.largestBatchShare, lessThan(0.30));
    });

    test('字數高度集中於單一批次時示警', () {
      // 一份有正常編輯歷程的文件，但其中一大段是一次貼進來的
      final long = List.filled(40, 'word').join(' ');
      final xml = [
        _paragraph('AAAA0001', 'A short opening line.'),
        _paragraph('BBBB0002', 'Another short line here.'),
        _paragraph('CCCC0003', 'And a third short line.'),
        for (var i = 0; i < 5; i++) _paragraph('DDDD9999', long),
      ].join();

      final map = buildRsidMap(xml, _countWords);
      expect(map.paragraphCount, greaterThanOrEqualTo(RsidMap.minimumParagraphs));
      expect(map.largestBatchShare, greaterThan(RsidMap.concentrationThreshold));
      expect(map.isHighlyConcentrated, isTrue);
      expect(map.batches.first.paragraphIndices.length, 5);
    });

    test('段落太少時不下結論——短文件本來就只有一兩個批次', () {
      final xml = [
        _paragraph('AAAA0001', 'One paragraph with a reasonable amount of text.'),
        _paragraph('AAAA0001', 'A second paragraph in the very same batch.'),
      ].join();

      final map = buildRsidMap(xml, _countWords);
      expect(map.largestBatchShare, 1.0);
      expect(map.isHighlyConcentrated, isFalse, reason: '段落數不足，集中度沒有意義');
    });
  });

  test('段落內多個 RSID 時取多數決，比取第一個穩定', () {
    const xml =
        '<w:p w:rsidR="AAAA1111" w:rsidRDefault="BBBB2222">'
        '<w:r w:rsidR="BBBB2222"><w:t>Some text here.</w:t></w:r>'
        '<w:r w:rsidR="BBBB2222"><w:t>And more text.</w:t></w:r></w:p>';
    final map = buildRsidMap(xml, _countWords);
    expect(map.batches.single.rsid, 'BBBB2222');
  });
}
