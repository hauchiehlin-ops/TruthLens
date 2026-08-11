# 版本控制工作流程

## 快速開始

提交代碼並遞增版本號，使用交互式腳本：

```bash
./scripts/commit_with_version.sh "功能描述"
```

## 工作流程

### 1️⃣ 準備代碼變更
```bash
# 編輯代碼...
# 不需要執行 git add
```

### 2️⃣ 使用腳本提交
```bash
./scripts/commit_with_version.sh "功能：新增雷達圖報告"
```

### 3️⃣ 選擇版本遞增類型
腳本會提示你選擇版本號遞增類型：

```
🔢 選擇版本號遞增類型：
  [1] Patch (patch) - 錯誤修復、小改進 (推薦)
  [2] Minor (minor) - 新功能
  [3] Major (major) - 重大變更

請選擇 [1-3] (預設: 1): 
```

### 4️⃣ 完成
腳本會：
- ✅ 提交你的代碼
- ✅ 遞增版本號
- ✅ 創建版本更新 commit
- ✅ 推送到遠端

## 版本遞增規則（語義化版本 SemVer）

### 📌 Patch 版本
**場景**：錯誤修復、小改進、文檔更新

**何時使用**：
- 修復 bug
- 性能優化
- 內部重構（無 API 變更）
- 文檔改進

**示例**：
```
3.0.1313 → 3.0.1314
```

### 🆕 Minor 版本
**場景**：新功能（向後相容）

**何時使用**：
- 新增功能特性
- 新增 API（向後相容）
- 棄用警告

**示例**：
```
3.0.1313 → 3.1.0
```

### 💥 Major 版本
**場景**：重大變更（不向後相容）

**何時使用**：
- 重大架構重構
- API 破壞性變更
- 移除已棄用功能
- 完整重設

**示例**：
```
3.1.0 → 4.0.0
```

## 版本號格式

```
X.Y.Z+B

X = Major 版本
Y = Minor 版本
Z = Patch 版本
B = Build 編號（自動遞增）
```

**示例**：`3.1.0+1314`

## 常見情境

### 修復 bug
```bash
$ ./scripts/commit_with_version.sh "修復：解決雷達圖渲染問題"
# 選擇：1 (Patch)
```

### 添加新功能
```bash
$ ./scripts/commit_with_version.sh "功能：新增文獻驗證"
# 選擇：2 (Minor)
```

### 架構重構
```bash
$ ./scripts/commit_with_version.sh "重構：簡化引擎層架構"
# 選擇：3 (Major) 或 1 (Patch)
# （取決於是否破壞性變更）
```

## 提示

✅ **推薦做法**
- 默認使用 Patch（大多數情況下）
- 仔細選擇 Minor 版本（新功能）
- 謹慎使用 Major 版本（重大變更）

❌ **避免**
- 不要手動編輯 pubspec.yaml 版本號
- 不要使用 `git commit` 跳過腳本
- 不要混合使用舊腳本（commit_and_bump.sh）

## 查看版本號

```bash
# 查看當前版本
grep "^version:" pubspec.yaml

# 查看版本歷史
git log --oneline | grep "版本號更新"
```

## 故障排除

### 腳本無執行權限
```bash
chmod +x ./scripts/commit_with_version.sh
```

### 推送失敗
```bash
# 檢查遠端連接
git remote -v

# 重試推送
git push origin main
```

---

**最後更新**：2026-08-12
