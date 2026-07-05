import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// 操作說明頁：產品定位與競品比較、完整操作流程、模型下載與調適教學。
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _officialLinks = [
    (
      role: '多語言 AI 分類器（Transformer，權重 40%）',
      name: 'onnx-community/chatgpt-detector-roberta-ONNX',
      url: 'https://huggingface.co/onnx-community/chatgpt-detector-roberta-ONNX',
    ),
    (
      role: '困惑度統計模型（Statistical，權重 25%）',
      name: 'Xenova/distilgpt2',
      url: 'https://huggingface.co/Xenova/distilgpt2',
    ),
    (
      role: '對抗式改寫偵測模型（Adversarial，權重 15%）',
      name: 'TruthLens GitHub Releases（models-v1）',
      url: 'https://github.com/hauchiehlin-ops/TruthLens/releases/tag/models-v1',
    ),
    (
      role: '報告生成 LLM（選用）',
      name: 'google/gemma-2-2b-it',
      url: 'https://huggingface.co/google/gemma-2-2b-it',
    ),
  ];

  Future<void> _openLink(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('操作說明')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('關於 TruthLens', style: textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text(
                    'TruthLens 是一款核心 AI 推論完全在裝置端執行的跨平台內容檢測'
                    '應用程式（iOS / Android / macOS / Windows）。透過四個獨立子模型'
                    '——Transformer 神經網路分類器、統計特徵分析、風格特徵分析、'
                    '對抗式改寫偵測——加權投票判定文字是否為 AI 生成，並提供逐句、'
                    '可解釋的分析理由：不是只給一個「像 AI」的百分比，而是說明「為什麼」。',
                    style: TextStyle(height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('與市面主流工具比較', style: textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            '以下比較依各工具官方公開資訊與一般市場認知整理，僅供功能定位參考，'
            '非第三方認證的效能實測數據。',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          _compareCard(
            context,
            title: 'vs GPTZero',
            points: const [
              'GPTZero 的運算主要在雲端進行、文件需上傳；TruthLens 四個偵測引擎皆在裝置端執行。',
              'GPTZero 首創的 Perplexity／Burstiness 指標與逐句高亮，TruthLens 已納入，'
                  '並疊加 Transformer 分類器、風格特徵分析與對抗式防禦，形成四模型集成投票，'
                  '而非單一指標判定。',
              'GPTZero 為訂閱制；TruthLens 無需訂閱、無使用次數限制。',
            ],
          ),
          _compareCard(
            context,
            title: 'vs Turnitin',
            points: const [
              'Turnitin 僅開放機構採購，個人無法直接購買；TruthLens 任何人皆可安裝使用。',
              'Turnitin 的判定過程接近黑箱；TruthLens 提供逐句 AI 機率、命中的寫作模式，'
                  '以及四引擎個別評分與理由明細。',
              'Turnitin 主要判斷二元「是否為 AI」；TruthLens 支援段落／句子級的'
                  '人類／AI／混合標示。',
            ],
          ),
          _compareCard(
            context,
            title: 'vs Originality.ai',
            points: const [
              'Originality.ai 為按篇計費的訂閱制，且需將文件上傳雲端；'
                  'TruthLens 核心運算在裝置端執行，無需持續付費使用偵測功能。',
              'Originality.ai 有事實查核與可讀性分析概念；TruthLens 以本地端風格特徵'
                  '模組呼應，且離線也能完成基礎分析。',
            ],
          ),
          _compareCard(
            context,
            title: 'vs Copyleaks',
            points: const [
              'Copyleaks 以雲端 API 為主，強項是低偽陽性率與多語系支援；'
                  'TruthLens 採用同樣理念的 XLM-RoBERTa 多語言基底模型與多模型集成投票，'
                  '但文件內容不會上傳至任何伺服器。',
              'Copyleaks 依方案而定有 API 用量限制；TruthLens 沒有用量限制。',
            ],
          ),
          _compareCard(
            context,
            title: 'vs Winston AI',
            points: const [
              'Winston AI 的 OCR 圖片辨識需上傳圖片至雲端；TruthLens 使用各平台原生框架'
                  '（iOS／macOS 的 Vision、Android 的 ML Kit、Windows 的 Windows.Media.Ocr）'
                  '在裝置端完成辨識。',
              'Winston AI 以報告排版精美著稱；TruthLens 提供 AI 動態生成排版報告'
                  '（未安裝 LLM 時自動退回模板），可匯出 PDF／CSV／JSON／PNG 四種格式。',
            ],
          ),
          const SizedBox(height: 8),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TruthLens 的獨有優勢', style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const _Bullet('超連結真實性驗證：自動偵測文件中的網址是否可連線存在；'
                      'DOI 格式的學術連結會進一步查詢 Crossref 公開登記資料，確認期刊目錄'
                      '是否確實收錄這筆文獻。'),
                  const _Bullet('文獻參考真實性核實：即使參考文獻沒有超連結（純作者—年份格式），'
                      '也能透過書目比對抓出可能虛構的引用——這正是 AI 幻覺內容常見的破綻。'),
                  const _Bullet('ESL（非母語寫作者）偏差修正：自動偵測非母語寫作特徵並降低統計'
                      '模型權重，避免將非母語人士的自然寫作誤判為 AI。'),
                  const _Bullet('自訂模型匯入：進階使用者可自行匯入本機 ONNX 模型，'
                      '取代或補充內建偵測引擎。'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('完整操作流程', style: textTheme.titleLarge),
          const SizedBox(height: 12),
          _stepCard(
            context,
            step: 1,
            title: '模型下載與更新',
            body: '首次啟動會引導安裝核心偵測模型；之後可隨時至「設定 → AI 模型管理」'
                '查看、下載、更新或移除。App 會在啟動時主動比對最新版本，若有更新，'
                '設定齒輪圖示與「AI 模型管理」項目會出現紅點提示。',
          ),
          _stepCard(
            context,
            step: 2,
            title: '如何選用模型（目的與效果）',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _Bullet('多語言 AI 分類器（權重 40%）：整體判定主力，句子級 AI 機率預測，'
                    '對準確度提升最明顯。'),
                _Bullet('統計分析引擎（權重 25%）：困惑度與 Burstiness 滑動窗口分析，'
                    '捕捉 AI 文本規律的節奏與用詞可預測性。'),
                _Bullet('風格特徵分析（權重 20%）：語意流暢度、重複句式、過渡詞使用，'
                    '可解釋性最高，最容易看懂「為什麼」。'),
                _Bullet('對抗式防禦（權重 15%）：辨識是否經改寫工具（如 QuillBot、'
                    'Undetectable.ai）洗過的文本。'),
                _Bullet('報告生成 LLM（選用）：安裝後報告文字由本地端 LLM 動態生成解說；'
                    '未安裝時自動退回固定模板，分析功能不受影響。'),
                _Bullet('可在「設定」個別啟用／停用引擎、調整 AI 判定信心閾值'
                    '（調高可降低誤判人類文章為 AI 的機率）。'),
              ],
            ),
          ),
          _stepCard(
            context,
            step: 3,
            title: '文檔上傳',
            body: '三種輸入方式：直接貼上文字、圖片辨識（OCR，各平台原生框架離線辨識）、'
                '匯入文件（txt / md / pdf / docx / doc）。文字需達 40 字元以上才能送出分析。',
          ),
          _stepCard(
            context,
            step: 4,
            title: '開始分析',
            body: '點擊「開始檢測」，四個引擎並行執行，畫面即時顯示各引擎完成進度。'
                '若偵測到非母語寫作特徵，會自動套用 ESL 偏差修正（可在設定關閉）。',
          ),
          _stepCard(
            context,
            step: 5,
            title: '查看與匯出結果',
            body: '報告頁包含：整體 AI 機率環狀圖、逐句熱力圖、四引擎明細評分與理由、'
                '超連結真實性、文獻參考真實性。可匯出 PDF 完整報告、CSV 逐句數據、'
                'JSON（供系統整合）、PNG 摘要卡（社群分享用）。每次分析結果自動保存於'
                '「歷史紀錄」，可隨時回顧。',
          ),
          const SizedBox(height: 24),
          Text('模型下載與調適教學（零基礎）', style: textTheme.titleLarge),
          const SizedBox(height: 12),
          _stepCard(
            context,
            step: 1,
            title: '開啟模型管理畫面',
            body: '從首頁點齒輪圖示進入「設定」，再點「AI 模型管理」旁的「開啟」。',
          ),
          _stepCard(
            context,
            step: 2,
            title: '依裝置能力挑選模型',
            body: '畫面會依你的裝置效能（RAM、處理器核心數）自動建議合適的模型層級，'
                '並列出每個角色（多語言分類器／統計分析／對抗式防禦／報告 LLM）的所有可用變體。',
          ),
          _stepCard(
            context,
            step: 3,
            title: '下載與套用',
            body: '點選想要的模型旁的「下載」，等待進度完成——下載完成的第一個模型會'
                '自動設為使用中。若已有多個變體，可點「設為使用中」隨時切換；'
                '點垃圾桶圖示可移除不需要的模型以釋放空間。',
          ),
          _stepCard(
            context,
            step: 4,
            title: '更新模型',
            body: '之後若有新版本，「AI 模型管理」與設定齒輪圖示會出現紅點提示，'
                '回到此畫面即可看到新版本並下載更新（會保留原本安裝的版本，除非手動移除）。',
          ),
          _stepCard(
            context,
            step: 5,
            title: '進階：匯入自訂模型',
            body: '若你已在其他地方取得或自行微調過相容的 .onnx 模型，可透過'
                '「設定 → 自訂 ONNX 模型匯入與測試」匯入——需提供模型檔、對應的 '
                'Tokenizer 設定（或選擇「不需要」）與 AI 類別索引；匯入前會自動偵測'
                '是否為重複匯入的相同檔案，避免不小心重複安裝。',
          ),
          const SizedBox(height: 16),
          Text('官方模型下載連結', style: textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('點擊項目會以系統瀏覽器開啟該模型的官方頁面。', style: textTheme.bodySmall),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (final link in _officialLinks)
                  ListTile(
                    leading: const Icon(Icons.open_in_new),
                    title: Text(link.role),
                    subtitle: Text(link.name),
                    onTap: () => _openLink(link.url),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _compareCard(BuildContext context,
      {required String title, required List<String> points}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final p in points) _Bullet(p),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepCard(
    BuildContext context, {
    required int step,
    required String title,
    String? body,
    Widget? child,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                child: Text('$step', style: const TextStyle(fontSize: 13)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 6),
                    if (body != null) Text(body, style: const TextStyle(height: 1.5)),
                    ?child,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text, style: const TextStyle(height: 1.4))),
        ],
      ),
    );
  }
}
