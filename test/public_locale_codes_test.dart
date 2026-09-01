import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/utils/public_locale_codes.dart';

void main() {
  test('public locale parser normalizes supported web language codes', () {
    expect(publicLocaleCode(publicLocaleFromCode('zh-Hant')), 'zh-Hant');
    expect(publicLocaleCode(publicLocaleFromCode('zh_TW')), 'zh-Hant');
    expect(publicLocaleCode(publicLocaleFromCode('zh-HK')), 'zh-Hant');
    expect(publicLocaleCode(publicLocaleFromCode('zh-Hans')), 'zh-Hans');
    expect(publicLocaleCode(publicLocaleFromCode('zh_CN')), 'zh-Hans');
    expect(publicLocaleCode(publicLocaleFromCode('zh')), 'zh-Hans');
    expect(publicLocaleCode(publicLocaleFromCode('th-TH')), 'th');
    expect(publicLocaleCode(publicLocaleFromCode('ko-KR')), 'ko');
    expect(publicLocaleCode(publicLocaleFromCode('ja-JP')), 'ja');
    expect(publicLocaleCode(publicLocaleFromCode('en-US')), 'en');
    expect(publicLocaleCode(publicLocaleFromCode('unsupported')), isNull);
  });

  test('public locale formatter preserves app locale variants', () {
    expect(
      publicLocaleCode(
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
      ),
      'zh-Hant',
    );
    expect(
      publicLocaleCode(
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
      ),
      'zh-Hans',
    );
    expect(publicLocaleCode(const Locale('zh', 'TW')), 'zh-Hant');
    expect(publicLocaleCode(const Locale('zh', 'CN')), 'zh-Hans');
    expect(publicLocaleCode(const Locale('th')), 'th');
    expect(publicLocaleCode(const Locale('en')), 'en');
  });
}
