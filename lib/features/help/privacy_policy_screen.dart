import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 隱私權政策頁：依實際執行的作業系統顯示對應平台的政策內容。
/// 各平台內容描述的是同一套實際行為（見程式碼中列出的四項連線行為），
/// 只是依各平台商店／發行慣例調整措辭與揭露格式，並非分別實作不同的隱私作法。
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _lastUpdated = '2026-07-05';

  _PlatformPolicy _policyFor(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.iOS:
        return _iosPolicy;
      case TargetPlatform.android:
        return _androidPolicy;
      case TargetPlatform.macOS:
        return _macosPolicy;
      case TargetPlatform.windows:
        return _windowsPolicy;
      default:
        return _genericPolicy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final policy = _policyFor(defaultTargetPlatform);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('隱私權政策')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(policy.icon,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${policy.platformName}版隱私權政策',
                            style: textTheme.titleMedium),
                        Text('最後更新：$_lastUpdated', style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final section in policy.sections) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(section.title, style: textTheme.titleSmall),
                    const SizedBox(height: 8),
                    for (final p in section.paragraphs)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(p, style: const TextStyle(height: 1.5)),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '本頁內容為 TruthLens 依實際功能行為撰寫的隱私權說明，非律師審閱之正式法律'
              '文件；如需與您所在地區的法規進行正式合規審查，建議另行諮詢專業法律意見。',
              style: textTheme.bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.outline),
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicySection {
  final String title;
  final List<String> paragraphs;
  const _PolicySection(this.title, this.paragraphs);
}

class _PlatformPolicy {
  final String platformName;
  final IconData icon;
  final List<_PolicySection> sections;
  const _PlatformPolicy({
    required this.platformName,
    required this.icon,
    required this.sections,
  });
}

const _commonDataSection = _PolicySection('我們如何處理您的資料', [
  'TruthLens 沒有使用者帳號、不需登入，也沒有任何形式的廣告或第三方追蹤 SDK。',
  '您輸入、貼上或匯入的文件內容，皆在您的裝置上由本機 AI 模型完成分析，'
      '不會上傳到 TruthLens 或任何第三方伺服器。',
  '分析結果與歷史紀錄僅儲存在您裝置本機的資料庫中；解除安裝 App 或清除歷史紀錄'
      '即會一併移除，TruthLens 不持有任何副本。',
]);

const _commonNetworkSection = _PolicySection('必要的連線行為', [
  '本 App 的核心 AI 偵測完全在裝置端執行，但下列三項功能需要連線：',
  '1. 模型目錄與下載：連至 GitHub Releases／Hugging Face 下載您選擇的偵測模型檔案，'
      '僅為下載模型，不會上傳任何使用者資料。',
  '2. 模型更新偵測：App 啟動時會連線比對版本號，僅傳送版本資訊，用於提示是否有新版本。',
  '3. 超連結與參考文獻真實性驗證：預設開啟，可在「設定」關閉。開啟時，會將文件中'
      '偵測到的網址或參考文獻文字，直接送往該網址本身或 Crossref 公開 API 查詢，'
      '僅傳送網址／DOI／書目文字本身，不含文件中的其他內容。',
]);

final _iosPolicy = _PlatformPolicy(
  platformName: 'iOS',
  icon: Icons.phone_iphone,
  sections: [
    const _PolicySection('概要（對應 App Store 隱私權「營養標籤」）', [
      'TruthLens 不收集任何與您的身分連結的資料，也不將任何資料用於追蹤，'
          '因此不需要 App 追蹤透明度（ATT）權限。',
      '本 App 使用系統提供的檔案選擇器存取您主動選擇的文件或圖片；未經您選擇的檔案，'
          'App 無法存取（iOS App Sandbox 限制）。',
    ]),
    _commonDataSection,
    _commonNetworkSection,
    const _PolicySection('您的權利', [
      '您可隨時於「歷史紀錄」清除本機分析紀錄，或於「設定」關閉超連結／文獻驗證功能，'
          '或直接刪除 App 移除所有本機資料。',
    ]),
  ],
);

final _androidPolicy = _PlatformPolicy(
  platformName: 'Android',
  icon: Icons.android,
  sections: [
    const _PolicySection('概要（對應 Google Play「資料安全」揭露）', [
      'TruthLens 不收集個人資料，也不與任何第三方分享使用者資料。',
      '本 App 僅在您主動選擇匯入文件或圖片時存取對應的儲存權限，不會背景掃描或存取'
          '其他檔案。',
    ]),
    _commonDataSection,
    _commonNetworkSection,
    const _PolicySection('您的權利', [
      '您可隨時於「歷史紀錄」清除本機分析紀錄，或於「設定」關閉超連結／文獻驗證功能，'
          '或直接解除安裝 App 移除所有本機資料。',
    ]),
  ],
);

final _macosPolicy = _PlatformPolicy(
  platformName: 'macOS',
  icon: Icons.laptop_mac,
  sections: [
    const _PolicySection('概要（App Sandbox 權限說明）', [
      'TruthLens 在 macOS App Sandbox 下執行，僅能存取您透過系統檔案對話框主動選擇的'
          '檔案（files.user-selected.read-write），無法自行瀏覽或存取其他檔案或資料夾。',
      '網路存取權限（network.client）僅用於下方「必要的連線行為」所列的功能。',
    ]),
    _commonDataSection,
    _commonNetworkSection,
    const _PolicySection('您的權利', [
      '您可隨時於「歷史紀錄」清除本機分析紀錄，或於「設定」關閉超連結／文獻驗證功能，'
          '或直接將 App 移到垃圾桶移除所有本機資料。',
    ]),
  ],
);

final _windowsPolicy = _PlatformPolicy(
  platformName: 'Windows',
  icon: Icons.desktop_windows,
  sections: [
    const _PolicySection('概要', [
      'TruthLens 為單機桌面應用程式，資料儲存於您本機使用者資料夾內'
          '（如 AppData／Documents），不會同步至雲端。',
      '本 App 僅在您主動選擇匯入文件或圖片時存取對應檔案，不會背景掃描其他檔案。',
    ]),
    _commonDataSection,
    _commonNetworkSection,
    const _PolicySection('您的權利', [
      '您可隨時於「歷史紀錄」清除本機分析紀錄，或於「設定」關閉超連結／文獻驗證功能，'
          '或直接解除安裝 App 移除所有本機資料。',
    ]),
  ],
);

final _genericPolicy = _PlatformPolicy(
  platformName: '本平台',
  icon: Icons.devices_other,
  sections: [_commonDataSection, _commonNetworkSection],
);
