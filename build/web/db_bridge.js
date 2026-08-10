// TruthLens Web 歷史紀錄橋接：包裝瀏覽器 IndexedDB，供 Dart (dart:js_interop) 存取。
// 對應原生版的 SQLite（見 lib/core/services/history_repository.dart）。內容全部
// 留在瀏覽器本機儲存內，不經任何伺服器。刻意只用 JSON 字串跨越 JS 邊界（而非傳遞
// 複雜物件），降低 interop 型別對應出錯的風險，過濾/排序留在 Dart 端做（與原生版
// 呼叫端的資料量級一致，200 筆內，效能無虞）。
(function () {
  const DB_NAME = 'truthlens';
  const STORE = 'history';
  let dbPromise = null;

  function openDb() {
    if (dbPromise) return dbPromise;
    dbPromise = new Promise((resolve, reject) => {
      const req = indexedDB.open(DB_NAME, 1);
      req.onupgradeneeded = () => {
        const db = req.result;
        if (!db.objectStoreNames.contains(STORE)) {
          db.createObjectStore(STORE, { keyPath: 'id' });
        }
      };
      req.onsuccess = () => resolve(req.result);
      req.onerror = () => reject(req.error);
    });
    return dbPromise;
  }

  async function put(entryJson) {
    const db = await openDb();
    const entry = JSON.parse(entryJson);
    return new Promise((resolve, reject) => {
      const tx = db.transaction(STORE, 'readwrite');
      tx.objectStore(STORE).put(entry);
      tx.oncomplete = () => resolve();
      tx.onerror = () => reject(tx.error);
    });
  }

  async function getAllJson() {
    const db = await openDb();
    return new Promise((resolve, reject) => {
      const tx = db.transaction(STORE, 'readonly');
      const req = tx.objectStore(STORE).getAll();
      req.onsuccess = () => resolve(JSON.stringify(req.result));
      req.onerror = () => reject(req.error);
    });
  }

  async function deleteEntry(id) {
    const db = await openDb();
    return new Promise((resolve, reject) => {
      const tx = db.transaction(STORE, 'readwrite');
      tx.objectStore(STORE).delete(id);
      tx.oncomplete = () => resolve();
      tx.onerror = () => reject(tx.error);
    });
  }

  async function clear() {
    const db = await openDb();
    return new Promise((resolve, reject) => {
      const tx = db.transaction(STORE, 'readwrite');
      tx.objectStore(STORE).clear();
      tx.oncomplete = () => resolve();
      tx.onerror = () => reject(tx.error);
    });
  }

  window.truthlensDb = { put, getAllJson, deleteEntry, clear };
})();
