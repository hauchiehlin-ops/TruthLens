# 模型自動激活集成指南

**目標**：確保「下載模型 = 自動加入評判隊列」

**狀態**：✅ 核心框架已完成 | ⚠️ 需集成至 UI 層

---

## 架構概述

```
用戶點擊「下載」按鈕
  ↓
ModelManager.downloadVariant()（已實裝）
  ↓
下載完成 → ModelManager.notifyListeners()（已實裝）
  ↓
ModelAutoActivationManager 監聽變化（✅ 新增）
  ↓
自動呼叫 _orchestrator.refreshEngines()（✅ 新增）
  ↓
下次分析使用新模型參與投票（✅ 自動）
```

---

## 集成步驟

### 步驟 1：初始化 ModelAutoActivationManager（main.dart）

**位置**：`lib/main.dart` > `_MyHomePageState.initState()` 或 `main()` 函數

**修改**：
```dart
// 在 MultiProvider 的 providers 清單中添加：

MultiProvider(
  providers: [
    // ... 現有 providers ...
    ChangeNotifierProvider(
      create: (_) => EnsembleOrchestrator(modelManager: _modelManager),
    ),
    // ✅ 新增：初始化自動激活管理器
    ChangeNotifierProvider<ModelAutoActivationManager>(
      create: (_) {
        final manager = ModelAutoActivationManager();
        manager.init(
          orchestrator: _.read<EnsembleOrchestrator>(),
          modelManager: _.read<ModelManager>(),
        );
        return manager;
      },
    ),
  ],
  child: const MyApp(),
)
```

### 步驟 2：在 UI 層顯示激活狀態

**位置**：`lib/features/input/input_screen.dart` （或模型下載相關 UI）

**修改**：
```dart
// 在 Widget build() 中監聽激活事件

@override
Widget build(BuildContext context) {
  final activationManager = context.read<ModelAutoActivationManager>();
  
  // 監聽模型激活事件
  activationManager.activationEvent.addListener(() {
    final event = activationManager.activationEvent.value;
    if (event != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ 新模型已激活：${event.activatedModels.join(", ")}'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green[700],
        ),
      );
    }
  });
  
  // 其他 UI 代碼...
}
```

### 步驟 3：模型下載完成時觸發刷新（model_download_screen.dart）

**位置**：模型下載完成的回調

**修改**：
```dart
// 在 downloadVariant 完成後

if (success) {
  // ✅ 下載成功 → 自動激活
  notifyModelDownloadComplete(
    role: model.role,
    variantId: variant.id,
    orchestrator: context.read<EnsembleOrchestrator>(),
  );
  
  // 提示用戶（可選）
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('✅ 下載完成，已自動加入評判隊列')),
  );
}
```

---

## 驗證自動激活

### 確認激活發生

**在 DevTools 中檢查**：
```
I/flutter: [ModelAutoActivation] Activated transformer:multilingual_distil_int8
I/Orchestrator: Engines refreshed - new models will be used in next analysis
```

### 測試流程

1. **開啟應用程式**
2. **下載 1 個模型**（e.g., RoBERTa）
3. **進行分析** → 應該使用該模型 ✅
4. **下載第 2 個模型**（e.g., DistilGPT2）
5. **進行分析** → 應該使用 2 個模型一起投票 ✅
6. **移除模型**
7. **進行分析** → 應該自動使用剩餘可用模型 ✅

---

## 已實裝的自動機制

### ✅ ModelManager 中已有

- `downloadVariant()` — 下載並安裝模型
- `notifyListeners()` — 觸發狀態變化通知
- `setActive()` — 設置活躍模型
- 首個模型自動激活（第 214 行）

### ✅ EnsembleOrchestrator 中已有

- `_defaultEngines()` — 自動掃描已安裝模型（第 30-68 行）
- `installedVariants()` — 查詢已安裝變體列表
- 引擎自動權重計算（基於可用性）

### ✅ 新增的自動激活系統

- `ModelAutoActivationManager` — 全局監聽器
- `activationEvent` — 事件流（UI 訂閱）
- `refreshEngines()` — 通知刷新引擎

---

## 常見問題

### Q: 如果我禁用某引擎會怎樣？
**A**: 禁用邏輯在 `StylometryEngine.isAvailable()` 檢查。模型仍會下載，但不會參與分析。

### Q: 下載後馬上分析會用到新模型嗎？
**A**: 是的。`_defaultEngines()` 會動態掃描已安裝模型，無需重啟應用。

### Q: 如果下載失敗會怎樣？
**A**: 模型不會被添加到已安裝列表，下次分析自動跳過。用戶可重試下載。

### Q: 可以手動觸發刷新嗎？
**A**: 可以。呼叫 `orchestrator.refreshEngines()` 即可。

---

## 集成檢查清單

- [ ] 在 main.dart 初始化 ModelAutoActivationManager
- [ ] 在模型下載 UI 監聽 activationEvent
- [ ] 在下載完成時呼叫 notifyModelDownloadComplete()
- [ ] 驗證：下載模型 → 進行分析 → 日誌中看到「Activated」消息
- [ ] 測試移除模型後分析是否自動調整
- [ ] 測試不同模型組合的投票結果
- [ ] 確認隱私：本地自動激活，不涉及網路

---

## 文件參考

- 核心實裝：`lib/core/detection/model_auto_activation.dart`（✅ 新增）
- 模型管理器：`lib/core/detection/model_manager_web.dart`（已有）
- Orchestrator：`lib/core/detection/orchestrator.dart`（已有）
- 模型類型：`lib/core/detection/model_manager_types.dart`

---

**集成完成後**，確保測試以下場景：
1. ✅ 多模型投票
2. ✅ 模型移除後降級
3. ✅ ESL 調整應用（Statistical 權重減半）
4. ✅ 快速連續下載多個模型
