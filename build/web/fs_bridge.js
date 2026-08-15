// TruthLens Web 儲存橋接：包裝瀏覽器 OPFS（Origin Private File System），
// 供 Dart (dart:js_interop) 存取已下載的模型檔案與設定清單。
// 全部內容留在瀏覽器沙盒儲存內，不經任何伺服器——對應原生版的 App 內
// models/ 目錄（見 lib/core/detection/model_manager.dart 的原生實作）。
(function () {
  async function root() {
    return navigator.storage.getDirectory();
  }

  async function readBytes(fileName) {
    try {
      const dir = await root();
      const handle = await dir.getFileHandle(fileName);
      const file = await handle.getFile();
      const buf = await file.arrayBuffer();
      return new Uint8Array(buf);
    } catch (e) {
      return null;
    }
  }

  async function writeBytes(fileName, bytes) {
    const dir = await root();
    const handle = await dir.getFileHandle(fileName, { create: true });
    const writable = await handle.createWritable();
    await writable.write(bytes);
    await writable.close();
  }

  // 串流寫入：供大型模型檔案下載時逐塊直接落地 OPFS，避免整份先在記憶體堆積
  // （模型檔常達數十~百餘 MB，疊加 CanvasKit／ONNX WASM 堆在行動裝置上容易見底）。
  async function openWritable(fileName) {
    const dir = await root();
    const handle = await dir.getFileHandle(fileName, { create: true });
    return handle.createWritable();
  }

  async function writeChunk(writable, bytes) {
    await writable.write(bytes);
  }

  async function closeWritable(writable) {
    await writable.close();
  }

  async function abortWritable(writable) {
    try {
      await writable.abort();
    } catch (e) {
      // 已關閉或已中止，忽略
    }
  }

  async function exists(fileName) {
    try {
      const dir = await root();
      await dir.getFileHandle(fileName);
      return true;
    } catch (e) {
      return false;
    }
  }

  async function size(fileName) {
    try {
      const dir = await root();
      const handle = await dir.getFileHandle(fileName);
      const file = await handle.getFile();
      return file.size;
    } catch (e) {
      return -1;
    }
  }

  async function deleteFile(fileName) {
    try {
      const dir = await root();
      await dir.removeEntry(fileName);
    } catch (e) {
      // 本就不存在，忽略
    }
  }

  async function readText(fileName) {
    const bytes = await readBytes(fileName);
    if (!bytes) return null;
    return new TextDecoder('utf-8').decode(bytes);
  }

  async function writeText(fileName, text) {
    await writeBytes(fileName, new TextEncoder().encode(text));
  }

  window.truthlensFs = {
    readBytes,
    writeBytes,
    exists,
    size,
    deleteFile,
    readText,
    writeText,
    openWritable,
    writeChunk,
    closeWritable,
    abortWritable,
  };
})();
