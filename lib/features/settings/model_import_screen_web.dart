import 'package:flutter/material.dart';

/// 「匯入本機模型」在原生版仰賴 dart:io 檔案存取（見 model_import_screen_io.dart），
/// web 版尚未支援，顯示提示頁面取代。
class ModelImportScreen extends StatelessWidget {
  const ModelImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('匯入自訂模型')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            '匯入自訂模型尚未支援於網頁版，請使用 App 版本。',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
