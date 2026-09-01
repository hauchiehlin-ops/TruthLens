import 'dart:ui';

import 'package:web/web.dart' as web;

import 'public_locale_codes.dart';

const _publicLocaleStorageKey = 'truthlens-public-lang';

Locale? readPublicLocaleOverride({bool explicitOnly = false}) {
  final queryLocale = publicLocaleFromCode(Uri.base.queryParameters['lang']);
  if (queryLocale != null) return queryLocale;
  if (explicitOnly) return null;
  return publicLocaleFromCode(
    web.window.localStorage.getItem(_publicLocaleStorageKey),
  );
}

Future<void> persistPublicLocale(Locale? locale) async {
  final code = publicLocaleCode(locale);
  if (code == null) {
    web.window.localStorage.removeItem(_publicLocaleStorageKey);
  } else {
    web.window.localStorage.setItem(_publicLocaleStorageKey, code);
  }
}
