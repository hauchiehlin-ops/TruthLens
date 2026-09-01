import 'dart:ui';

const supportedPublicLocaleCodes = <String>[
  'zh-Hant',
  'zh-Hans',
  'en',
  'ja',
  'ko',
  'th',
  'ms',
  'es',
  'id',
  'ru',
  'de',
  'fr',
  'pt',
];

Locale? publicLocaleFromCode(String? value) {
  final normalized = value?.trim().replaceAll('_', '-').toLowerCase();
  if (normalized == null || normalized.isEmpty) return null;
  if (normalized == 'zh-hant' ||
      normalized == 'zh-tw' ||
      normalized == 'zh-hk' ||
      normalized == 'zh-mo') {
    return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
  }
  if (normalized == 'zh' ||
      normalized == 'zh-hans' ||
      normalized == 'zh-cn' ||
      normalized == 'zh-sg') {
    return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');
  }
  final languageCode = normalized.split('-').first;
  return supportedPublicLocaleCodes.contains(languageCode)
      ? Locale(languageCode)
      : null;
}

String? publicLocaleCode(Locale? locale) {
  if (locale == null) return null;
  if (locale.languageCode == 'zh') {
    final scriptCode = locale.scriptCode;
    if (scriptCode == 'Hant' || scriptCode == 'Hans') {
      return 'zh-$scriptCode';
    }
    final countryCode = locale.countryCode?.toUpperCase();
    if (countryCode == 'TW' || countryCode == 'HK' || countryCode == 'MO') {
      return 'zh-Hant';
    }
    return 'zh-Hans';
  }
  return supportedPublicLocaleCodes.contains(locale.languageCode)
      ? locale.languageCode
      : null;
}

String publicLocaleCodeFromTag(String tag) =>
    publicLocaleCode(publicLocaleFromCode(tag)) ?? 'en';

bool samePublicLocale(Locale? a, Locale? b) =>
    publicLocaleCode(a) == publicLocaleCode(b);
