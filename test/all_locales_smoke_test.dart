import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/l10n/generated/app_localizations.dart';

void main() {
  test('every supported locale loads and produces distinct, non-empty strings', () {
    final samples = <String, String>{};
    for (final locale in AppLocalizations.supportedLocales) {
      final l10n = lookupAppLocalizations(locale);
      final tag = locale.toString();

      expect(l10n.verdictHuman, isNotEmpty, reason: '$tag verdictHuman empty');
      expect(l10n.settingsAppBarTitle, isNotEmpty, reason: '$tag settingsAppBarTitle empty');
      expect(l10n.inputStartButton, isNotEmpty, reason: '$tag inputStartButton empty');
      expect(
        l10n.inputOcrRecognized(5),
        contains('5'),
        reason: '$tag placeholder substitution failed',
      );
      expect(
        l10n.modelListSizeLangRam('1.2GB', '104', 4, '1.0'),
        allOf(contains('1.2GB'), contains('104'), contains('4'), contains('1.0')),
        reason: '$tag multi-placeholder substitution failed',
      );

      samples[tag] = l10n.verdictHuman;
    }

    expect(samples.length, AppLocalizations.supportedLocales.length);
    // Sanity: not all locales fall back to identical (untranslated) text.
    expect(samples.values.toSet().length, greaterThan(1));

    // Spot-check a few expected translations.
    expect(lookupAppLocalizations(const Locale('en')).verdictHuman, 'Human-written');
    expect(
      lookupAppLocalizations(const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'))
          .verdictHuman,
      contains('人類'),
    );
    expect(
      lookupAppLocalizations(const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'))
          .verdictHuman,
      contains('人类'),
    );
    expect(lookupAppLocalizations(const Locale('ja')).settingsAppBarTitle, isNotEmpty);
    expect(lookupAppLocalizations(const Locale('ko')).settingsAppBarTitle, isNotEmpty);
    expect(lookupAppLocalizations(const Locale('th')).settingsAppBarTitle, isNotEmpty);
    expect(lookupAppLocalizations(const Locale('ms')).settingsAppBarTitle, isNotEmpty);
    expect(lookupAppLocalizations(const Locale('es')).settingsAppBarTitle, isNotEmpty);
    expect(lookupAppLocalizations(const Locale('id')).settingsAppBarTitle, isNotEmpty);
    expect(lookupAppLocalizations(const Locale('ru')).settingsAppBarTitle, isNotEmpty);
    expect(lookupAppLocalizations(const Locale('de')).settingsAppBarTitle, isNotEmpty);
    expect(lookupAppLocalizations(const Locale('fr')).settingsAppBarTitle, isNotEmpty);
    expect(lookupAppLocalizations(const Locale('pt')).settingsAppBarTitle, isNotEmpty);
  });
}
