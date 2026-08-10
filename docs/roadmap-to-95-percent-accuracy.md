# 達成 95% 精度的完整實施路線圖（8 月-12 月）

## 現狀基線（2026 年 8 月 10 日）

```
當前精度：~85-88%（Dart Fallback 引擎）
目標精度：95%+（金融級）
時間線：4 個月
難度：⭐⭐⭐⭐⭐（極高）

差距分析：
├─ 缺失的對抗防禦層（-4%）
├─ 未優化的中文支援（-2%）
├─ 場景不適配的閾值（-1%）
└─ 訓練數據不足（-2%）
```

---

## 第一階段：基礎建設（8 月中-8 月底，2 週）

### 1.1 建立評估基礎設施

**任務 1：準備測試數據集**

```bash
# training/prepare_benchmarks.py
準備 3 份標準測試集：

測試集 A：HC3 原始（官方基準）
  ├─ 英文：50,000 樣本（AI:人類 = 1:1）
  ├─ 中文：10,000 樣本
  └─ 其他語言：5,000 樣本

測試集 B：改寫變體（對抗魯棒性）
  ├─ Quillbot 改寫：10,000
  ├─ Spinbot 改寫：5,000
  ├─ 手工改寫：3,000
  └─ GPT-4 改寫：2,000

測試集 C：真實教育文本（應用場景）
  ├─ 高中作業：2,000 樣本（已標記 AI/人類）
  ├─ 大學論文：2,000 樣本
  └─ 簡答題：1,000 樣本
```

**任務 2：建立基準評估腳本**

```bash
# training/benchmark.py
自動化評估流程：
  1. 載入所有測試集
  2. 執行推論（current_model）
  3. 計算混淆矩陣
  4. 生成報告（精度/精確率/召回率/F1）
  5. 與歷史基準對比
  
執行：
  python training/benchmark.py \
    --model models/model-v3.0.0.onnx \
    --output benchmark_results/2026-08-10.json
```

**時間投入：**
- 數據集收集/整理：3 天
- 評估腳本開發：2 天
- 基準測試：1 天

**預期產出：**
- ✅ 標準化評估框架
- ✅ 基準報告（當前精度 baseline）
- ✅ 自動化評估管線

---

## 第二階段：對抗防禦層實裝（8 月底-9 月中，2.5 週）

### 2.1 改寫工具檢測引擎

**任務 1：開發 AdversarialEngine v2**

```dart
// lib/core/detection/engines/adversarial_engine_v2.dart

class AdversarialEngineV2 extends DetectionEngine {
  /// 對抗防禦策略：檢測改寫軌跡
  @override
  Future<EngineScore> analyze(PreprocessedText text, AppLocalizations l10n) async {
    final score = _detectRewritingArtifacts(text);
    
    return EngineScore(
      engineId: 'adversarial_v2',
      engineName: '改寫防禦（v2）',
      aiProbability: score,
      weight: 0.15,
      reasons: _explainRewritingSignals(text),
      available: true,
    );
  }

  /// 改寫檢測策略（3 層）
  double _detectRewritingArtifacts(PreprocessedText text) {
    var score = 0.0;
    
    // 策略 1：替換詞檢測（同義詞替換跡象）
    score += _detectSynonymSubstitution(text) * 0.4;
    
    // 策略 2：語法規律性（改寫工具傾向規律化）
    score += _detectUnusualGrammarPatterns(text) * 0.3;
    
    // 策略 3：詞彙豐富度異常（改寫工具過度同義）
    score += _detectVocabularyAnomaly(text) * 0.3;
    
    return score.clamp(0, 1);
  }

  /// 同義詞替換檢測
  double _detectSynonymSubstitution(PreprocessedText text) {
    // 改寫工具替換特徵：
    // 1. 相同語義的低頻同義詞連續出現
    // 2. 詞距小於 5 的重複
    // 3. 冷門詞彙突然出現
    
    final suspiciousWords = <String>[];
    for (int i = 0; i < text.allTokens.length - 1; i++) {
      final word1 = text.allTokens[i];
      final word2 = text.allTokens[i + 1];
      
      if (_areSynonyms(word1, word2) && 
          _isWordFrequencyAnomaly(word1, word2)) {
        suspiciousWords.add('$word1→$word2');
      }
    }
    
    return (suspiciousWords.length / text.allTokens.length).clamp(0, 1);
  }

  /// 檢查是否為同義詞
  bool _areSynonyms(String word1, String word2) {
    // 使用預構建的同義詞典（或 BERT embedding 相似度）
    const synonymPairs = {
      'good': ['excellent', 'great', 'fine'],
      'bad': ['terrible', 'awful', 'poor'],
      // ... 擴展至 1000+ 對
    };
    
    return synonymPairs[word1]?.contains(word2) ?? false;
  }

  /// 詞彙豐富度異常
  double _detectVocabularyAnomaly(PreprocessedText text) {
    // 改寫工具特徵：
    // - Type-Token Ratio 突然升高（同義詞堆砌）
    // - 詞彙複雜度異常（Flesch-Kincaid 跳躍）
    
    final expectedTTR = _getExpectedTTRForLength(text.allTokens.length);
    final actualTTR = text.typeTokenRatio;
    
    // 如果實際 TTR 比預期高 30%，可能是改寫
    return ((actualTTR - expectedTTR) / expectedTTR).clamp(0, 1);
  }
}
```

**任務 2：整合到 Ensemble**

```dart
// lib/core/detection/orchestrator.dart 修改

static List<DetectionEngine> _defaultEngines(ModelManager mm) {
  final discovered = <DetectionEngine>[];

  // 1. Transformer (40%)
  discovered.add(TransformerEngine(modelManager: mm));

  // 2. Statistical (25%)
  discovered.add(StatisticalEngine(modelManager: mm));

  // 3. Stylometry (20%)
  discovered.add(StylometryEngine());

  // 4. Adversarial v2 (15%) ← 新增強版本
  discovered.add(AdversarialEngineV2());  // 無需模型檔案
  
  return discovered;
}
```

**任務 3：測試與驗證**

```bash
# training/test_adversarial_v2.py
對改寫工具測試：

測試項目：
  1. Quillbot 改寫：檢測率目標 92%+
  2. Spinbot 改寫：檢測率目標 90%+
  3. 手工改寫：檢測率目標 85%+
  4. GPT-4 改寫：檢測率目標 80%+

執行：
  python training/test_adversarial_v2.py \
    --test-set data/rewriting_variants.jsonl \
    --engine adversarial_v2 \
    --output results/adversarial_v2_test.json
```

**預期精度提升：+3-4%**

**時間投入：**
- AdversarialEngineV2 開發：5 天
- 同義詞典構建：3 天
- 測試與調整：4 天

---

## 第三階段：多語言優化（9 月中-9 月底，2 週）

### 3.1 中文特化

```dart
// lib/core/detection/engines/transformer_engine_zh.dart

class TransformerEngineZH extends TransformerEngine {
  /// 中文特化推論（詞級調整）
  
  @override
  Future<EngineScore> analyze(PreprocessedText text, AppLocalizations l10n) async {
    // 中文特點：
    // 1. 詞序與英文不同 → 需要中文 tokenizer
    // 2. AI 生成特徵：過度規律化、罕用詞低
    // 3. 改寫工具少 → 對抗防禦權重可降低
    
    // 使用中文特化 tokenizer
    final tokens = _tokenizeZH(text.originalText);
    
    // 調整權重配置
    final weights = {
      'transformer': 0.45,  // 提升（中文 XLM-RoBERTa 效果好）
      'statistical': 0.20,
      'stylometry': 0.20,
      'adversarial': 0.15,  // 維持（改寫工具不普遍）
    };
    
    // ... 推論邏輯
  }

  /// 中文分詞（使用 jieba 或類似）
  List<String> _tokenizeZH(String text) {
    // 實作或調用 jieba 中文分詞
    // 重要：保留 CJK 字符特性
  }
}
```

### 3.2 場景特化權重

```dart
// lib/core/detection/scenario_adapter.dart 擴展

class ScenarioAdapterZH extends ScenarioAdapter {
  @override
  void adaptToScenario(DocumentType docType, String language) {
    if (language != 'zh') return;  // 只針對中文
    
    switch (docType) {
      case DocumentType.highSchoolEssay:
        // 高中作文：AI 使用率 45%（假設）
        // 特徵：模板化、詞彙簡單
        weights = {
          'transformer': 0.40,
          'statistical': 0.25,   // 對中文作文效果佳
          'stylometry': 0.25,    // 提升
          'adversarial': 0.10,   // 降低
        };
        threshold = 0.52;
        
      case DocumentType.researchPaper:
        // 學位論文：少數 AI，多數正常
        weights = {
          'transformer': 0.45,   // 提升
          'statistical': 0.20,
          'stylometry': 0.20,
          'adversarial': 0.15,
        };
        threshold = 0.65;  // 嚴格
    }
  }
}
```

**預期精度提升：+1.5-2%（針對中文內容）**

---

## 第四階段：模型微調（9 月底-10 月中，3 週）

### 4.1 使用真實教育數據微調

```bash
# training/fine_tune_education.py

微調流程：
  1. 收集 5000+ 教育真實標籤文本
  2. 使用 LoRA 微調 XLM-RoBERTa（只調 2-3% 參數）
  3. 評估精度提升
  4. 如果精度 >0.5% 改進，則導出新模型

執行：
  python training/fine_tune_education.py \
    --base-model xlm-roberta-base \
    --train-data data/education_labeled_5k.jsonl \
    --lora-rank 16 \
    --learning-rate 1e-4 \
    --epochs 3
```

### 4.2 集成新模型

```bash
# 新模型導出
python training/export_onnx.py \
  --model output/xlm-roberta-education-finetuned \
  --quantize int8 \
  --output models/model-education-v3.1.onnx

# 版本更新
# pubspec.yaml: 3.1.0+31 → 3.2.0+32
./scripts/commit_and_bump.sh "新增：教育微調模型 v3.1"
```

**預期精度提升：+1-2%**

---

## 第五階段：整合與驗證（10 月中-10 月底，2 週）

### 5.1 完整集成測試

```dart
// test/accuracy_integration_test.dart

void main() {
  test('95% accuracy on mixed education benchmarks', () async {
    final orchestrator = EnsembleOrchestrator();
    
    // 在所有 3 份測試集上運行
    final results = await runBenchmarks(orchestrator, [
      BenchmarkSet.hc3Original,      // 基準
      BenchmarkSet.rewritingVariants, // 對抗
      BenchmarkSet.educationReal,     // 場景
    ]);
    
    expect(results.accuracy, greaterThanOrEqualTo(0.95));
    expect(results.falsePositiveRate, lessThan(0.02));
    expect(results.falseNegativeRate, lessThan(0.03));
  });
}
```

### 5.2 教育機構試用（Beta）

```
招募 5-10 所教育機構：
  ├─ 高中：2 所（作業檢測）
  ├─ 大學：3 所（論文檢測）
  └─ 線上教育：2-3 所（混合）

試用期限：2 週
試用數量：200+ 份文本（已標記）
期望反饋：
  ├─ 精度驗證
  ├─ 誤判案例
  ├─ UI/UX 反饋
  └─ 集成需求
```

---

## 第六階段：上線與持續改進（11 月-12 月）

### 6.1 生產部署（11 月 1 日）

```
前置條件檢查：
  ☐ 精度驗證 ≥95% （所有測試集）
  ☐ 誤判率 <2%
  ☐ 5-10 家機構試用無重大問題
  ☐ 法律/合規審核完成
  ☐ 透明度報告準備完成

上線步驟：
  1. Vercel 生產部署
  2. GitHub Actions CI/CD 啟動
  3. 監控系統上線
  4. 公開發佈 SLA 承諾
  5. 月度報告發佈
```

### 6.2 持續改進迴路（11 月-12 月）

```
每週任務：
  ├─ 監控精度指標（>94% 警告）
  ├─ 收集教育機構反饋
  ├─ 分析誤判案例
  └─ 更新特徵工程

每月任務：
  ├─ 自動重訓練（誤判 >50 例）
  ├─ 發佈透明報告
  ├─ A/B 測試新引擎變體
  └─ 與競爭者對標

季度目標：
  ├─ 11 月底：精度 95.2%
  ├─ 12 月底：精度 95.5%+
  └─ 2027 年 Q1：精度 96%+
```

---

## 成功指標與里程碑

```
🎯 里程碑 1（8 月底）
  ✅ 評估框架完成
  ✅ 基準測試 85-88%
  ✅ 對抗防禦層開發完成

🎯 里程碑 2（9 月中）
  ✅ 對抗防禦精度 +3-4%
  ✅ 改寫工具檢測率 90%+
  ✅ 精度達到 ~91-92%

🎯 里程碑 3（9 月底）
  ✅ 中文特化完成
  ✅ 多語言測試通過
  ✅ 精度達到 ~92-93%

🎯 里程碑 4（10 月中）
  ✅ 教育模型微調完成
  ✅ 真實測試精度 ~93-94%
  ✅ 準備 Beta 試用

🎯 里程碑 5（10 月底）
  ✅ Beta 試用完成（200+ 樣本）
  ✅ 誤判率確認 <2%
  ✅ 教師 NPS ≥8/10

🎯 里程碑 6（11 月 1 日）
  ✅ 生產上線
  ✅ 精度 ≥95%（驗證）
  ✅ SLA 承諾簽署
  ✅ 月度報告發佈
```

---

## 風險與應對

| 風險 | 機率 | 影響 | 應對方案 |
|------|------|------|---------|
| 對抗防禦層效果不如預期 | 中 | 高 | 備用增強 Statistical 權重 |
| 中文微調過擬合 | 低 | 中 | 保留英文基準，只微調中文子模型 |
| 教育機構試用反饋差 | 低 | 高 | 延長試用期，快速迭代 |
| 真實精度 <95% | 低 | 極高 | 推遲上線，額外 2 週優化 |

---

## 預算與資源

```
開發資源（團隊）：
  ├─ ML 工程師：1 人（全職，4 個月）
  ├─ 後端工程師：1 人（兼職，監控系統）
  └─ QA：1 人（兼職，測試管理）

計算資源（估計）：
  ├─ 訓練：A100 × 1 週 ≈ $200-300
  ├─ 測試：GPU × 2 週 ≈ $300-400
  └─ 部署：Vercel 邊際成本 <$50/月

總預算：
  開發：~$5,000-8,000（人工成本高，機器成本低）
  運營：~$50-100/月（持續監控）
```

---

## 關鍵成功因素

1. **數據質量** → 真實教育文本標籤必須準確（>95%）
2. **迭代速度** → 每週評估和微調，不能等整月才測試
3. **教育機構反饋** → Beta 試用的誤判案例是金礦
4. **透明度** → 公開報告 = 市場信任基礎
5. **對標分析** → 定期對比競爭者，確保領先地位

---

## 成功後的願景

```
2026 年 12 月
├─ TruthLens 精度 95%+ ✓
├─ 教育市場採用率 TOP 3 ✓
├─ 全球 50+ 教育機構使用 ✓
└─ 年度淨推薦值 NPS 9/10 ✓

2027 年願景
├─ 精度 96%+（領先 Turnitin 4 個百分點）
├─ 全球 500+ 教育機構
├─ 多語言市場佔有率 30%+
└─ 企業/內容平台擴展市場
```
