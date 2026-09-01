// OmniTrace PWA 安裝橋接。
//
// 存在的理由：已下載的模型放在 OPFS，預設是「盡力而為」等級，瀏覽器在磁碟壓力下
// 可以直接回收，使用者下次開啟就得重載數百 MB。navigator.storage.persist() 是唯一
// 的豁免途徑，但 Chromium 依網站互動程度自行決定給不給——實測在未安裝的站上會被
// 拒絕。把網站裝成應用程式是最能翻轉那個判斷的一步。
//
// beforeinstallprompt 只會派送一次，而且早於 Flutter 啟動，因此必須在這裡先攔下來
// 存好；事件本身也只能用一次，prompt() 後即失效。
(function () {
  let deferredPrompt = null;
  let installed =
    window.matchMedia('(display-mode: standalone)').matches ||
    window.navigator.standalone === true;

  window.addEventListener('beforeinstallprompt', function (event) {
    // 擋掉瀏覽器自己的迷你提示列，改由 App 在說明得清楚的位置詢問。
    event.preventDefault();
    deferredPrompt = event;
  });

  window.addEventListener('appinstalled', function () {
    installed = true;
    deferredPrompt = null;
  });

  window.omnitracePwa = {
    canInstall: function () {
      return deferredPrompt !== null && !installed;
    },
    isInstalled: function () {
      return installed;
    },
    // 回傳 'accepted' / 'dismissed' / 'unavailable'
    promptInstall: async function () {
      if (deferredPrompt === null) return 'unavailable';
      const event = deferredPrompt;
      deferredPrompt = null; // 事件用過即失效，先清掉避免重複觸發
      try {
        await event.prompt();
        const choice = await event.userChoice;
        return choice && choice.outcome ? choice.outcome : 'dismissed';
      } catch (error) {
        return 'unavailable';
      }
    },
  };
})();
