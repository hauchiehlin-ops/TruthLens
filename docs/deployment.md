# TruthLens 部署指南

## 概述
TruthLens 是 Flutter Web 應用，靜態資源可部署至任何 HTTP 伺服器。推薦使用 Vercel 以獲得自動 CI/CD、邊緣計算、環境管理等功能。

## 部署方式

### 1. Vercel 部署（推薦）

#### 先置條件
- Vercel 帳號（[vercel.com](https://vercel.com) 免費註冊）
- GitHub 帳號（授權 Vercel 存取 repo）
- 項目中已有 `vercel.json` 配置

#### 步驟 1：連接 GitHub

1. 登入 [Vercel Dashboard](https://vercel.com/dashboard)
2. 點擊 **"Add New"** → **"Project"**
3. 選擇 **"Import Git Repository"**
4. 搜尋並選擇 `truthlens` repo
5. 點擊 **"Import"**

#### 步驟 2：設定環境變數

在 Vercel 項目設定中添加以下變數（如需要）：

```
FLUTTER_VERSION=3.24.1
```

#### 步驟 3：設定 GitHub Secrets（用於自動部署）

在 GitHub repo 的 **Settings** → **Secrets and variables** → **Actions** 中添加：

```
VERCEL_TOKEN=<從 Vercel Account Settings 取得>
VERCEL_ORG_ID=<組織 ID>
VERCEL_PROJECT_ID=<項目 ID>
```

獲取方式：
- **VERCEL_TOKEN**：Vercel Settings → Tokens → Create
- **VERCEL_ORG_ID** 和 **VERCEL_PROJECT_ID**：部署後在 Vercel Dashboard 查看

#### 步驟 4：自動部署

- 推送至 `main` 分支 → 自動部署至生產環境
- 創建 Pull Request → 自動部署預覽環境

### 2. GitHub Pages 部署

#### 步驟

1. 構建 web 版本：
   ```bash
   flutter build web
   ```

2. 配置 GitHub Pages：
   - 進入 repo **Settings** → **Pages**
   - **Source** 選擇 **Deploy from a branch**
   - **Branch** 選擇 `main`，目錄選擇 `/build/web`

3. 推送至 GitHub：
   ```bash
   git add build/web
   git commit -m "Build: production web build"
   git push origin main
   ```

4. 檢查部署狀態：
   - **Settings** → **Pages** → 查看網址

#### 優缺點
- ✅ 完全免費
- ✅ 無需配置
- ✅ 自動更新
- ❌ 無 CI/CD 自動化
- ❌ 無環境變數管理

### 3. 自託管部署（Docker）

#### Dockerfile

```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
RUN npm install -g flutter
COPY . .
RUN flutter pub get
RUN flutter build web

FROM nginx:alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

#### 部署

```bash
docker build -t truthlens:latest .
docker run -p 80:80 truthlens:latest
```

---

## 本地構建驗證

部署前，務必在本地驗證生產構建：

```bash
# 清空舊構建
rm -rf build/web

# 構建生產版本
flutter build web --release

# 本地預覽（需要安裝 http-server）
npx http-server build/web -p 8080
```

訪問 `http://localhost:8080` 驗證功能。

---

## 構建優化

### 檔案大小
```bash
flutter build web --release --no-tree-shake-icons
# 預期：~20-30MB（初次加載）
```

### 性能檢查
```bash
flutter build web --release --analyze-size
```

---

## 故障排除

### Vercel 部署失敗

**症狀**：構建超時或找不到 Flutter

**解決**：
1. 確認 `vercel.json` 中 `buildCommand` 正確
2. 增加構建超時時間（Vercel Settings → Build & Development Settings）
3. 檢查 Flutter 版本相容性

### GitHub Pages 空白頁

**症狀**：部署成功但頁面顯示空白

**解決**：
1. 檢查 `build/web/index.html` 是否存在
2. 確認 base href 設定：`<base href="/">`
3. 檢查瀏覽器控制台錯誤訊息

### 模型下載失敗

**症狀**：部署成功但模型載入失敗

**原因**：HTTP CORS 或模型伺服器連線問題

**解決**：
1. 檢查模型下載 URL 是否可訪問
2. 確認伺服器允許 CORS（設定 `Access-Control-Allow-Origin` header）
3. 使用 HTTPS（生產環境必須）

---

## 後續優化

- [ ] 啟用 CDN 加速（Vercel 邊緣功能）
- [ ] 配置 API 路由（如需要服務端支援）
- [ ] 設定 環境特定配置（開發/測試/生產）
- [ ] 監控構建時間和檔案大小
- [ ] 設定自動化效能測試

---

## 相關資源

- [Vercel 文檔](https://vercel.com/docs)
- [Flutter Web 部署指南](https://docs.flutter.dev/deployment/web)
- [GitHub Pages 文檔](https://docs.github.com/en/pages)
