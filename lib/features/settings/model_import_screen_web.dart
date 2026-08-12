import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

/// 「匯入本機模型」在原生版仰賴 dart:io 檔案存取（見 model_import_screen_io.dart），
/// web 版尚未支援，顯示提示頁面取代。
class ModelImportScreen extends StatelessWidget {
  const ModelImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsCustomImportTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.modelImportWebUnsupported,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
