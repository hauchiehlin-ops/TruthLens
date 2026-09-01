import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/detection/model_display_names.dart';
import 'package:omnitrace/features/onboarding/model_options_list.dart';
import 'package:omnitrace/core/services/ocr_failure.dart';
import 'package:omnitrace/l10n/generated/app_localizations.dart';

void main() {
  test('所有語系的鍵齊備，缺漏會靜默回退英文而不報錯', () {
    final en =
        jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync())
            as Map<String, dynamic>;
    final expected = en.keys.where((k) => !k.startsWith('@')).toSet();

    for (final file in Directory('lib/l10n').listSync()) {
      if (!file.path.endsWith('.arb')) continue;
      final data =
          jsonDecode(File(file.path).readAsStringSync())
              as Map<String, dynamic>;
      final actual = data.keys.where((k) => !k.startsWith('@')).toSet();
      expect(
        expected.difference(actual),
        isEmpty,
        reason: '${file.path} 缺少鍵——gen-l10n 會回退英文，介面因此中英混雜',
      );
    }
  });

  test('介面程式碼不得用手動雙語三元式取代 l10n', () {
    // 曾經的實際問題：web_ocr_settings.dart 有 22 對
    // `_isZh(l10n) ? '中文' : 'English'`，其餘 12 個語系一律拿到英文。
    // 這種寫法在 analyzer 與 gen-l10n 都不會報錯，只能靠測試擋。
    final offenders = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.path.contains('l10n/generated')) continue;
      final source = entity.readAsStringSync();
      if (RegExp(r"_isZh\s*\(").hasMatch(source) ||
          RegExp(r"localeName[^\n]*startsWith\(\s*'zh'").hasMatch(source)) {
        offenders.add(entity.path);
      }
    }
    expect(
      offenders,
      isEmpty,
      reason: '請改用 l10n 鍵，否則只有中英兩個語系拿得到正確文字',
    );
  });

  test('每一種 OCR 失敗都能在所有語系產生非空描述', () async {
    // OCR 錯誤過去是服務層寫死的中文字串，直接進 snackbar。這條守的是
    // 「每個成因都有翻譯」——少一條就會在該語系拋 noSuchMethod 或顯示空白。
    for (final locale in AppLocalizations.supportedLocales) {
      final l10n = await AppLocalizations.delegate.load(locale);
      for (final kind in OcrFailureKind.values) {
        final message = OcrFailure(
          kind,
          detail: 'detail',
          statusCode: 500,
        ).localize(l10n);
        expect(
          message.trim(),
          isNotEmpty,
          reason: '$locale 缺少 $kind 的描述',
        );
      }
    }
  });

  test('catalog 的每個角色與變體都有在地化名稱，不落回中文 catalog 字串', () async {
    // 漏網的實例：`roleLabel` 涵蓋 4 個角色但漏了 'llm'，`localizedModelName`
    // 涵蓋 7 個變體但漏了 gemma——兩者都靜默落回 catalog 的中文原文，於是
    // 英文介面出現「報告生成 LLM」。逐 id 手寫 switch 一定會跟不上 catalog，
    // 所以改由測試以 catalog 為準源反查。
    final catalog =
        jsonDecode(File('assets/model_catalog.json').readAsStringSync())
            as Map<String, dynamic>;
    final models = catalog['models'] as List<dynamic>;
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final cjk = RegExp(r'[\u4e00-\u9fff]');

    for (final entry in models) {
      final role = entry as Map<String, dynamic>;
      final roleId = role['role'] as String;
      final roleName = role['name'] as String;

      expect(
        cjk.hasMatch(ModelOptionsList.roleLabel(roleId, roleName, en)),
        isFalse,
        reason: '角色 $roleId 沒有 l10n 對應，英文介面會顯示 catalog 的「$roleName」',
      );

      for (final v in (role['variants'] as List<dynamic>? ?? const [])) {
        final variant = v as Map<String, dynamic>;
        final id = variant['id'] as String;
        final name = variant['name'] as String;
        expect(
          cjk.hasMatch(localizedModelName(id, name, en)),
          isFalse,
          reason: '變體 $id 沒有 l10n 對應，英文介面會顯示 catalog 的「$name」',
        );
      }
    }
  });
}
