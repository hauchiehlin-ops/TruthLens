(function () {
  const languages = [
    ['zh-Hant', '繁體中文'],
    ['zh-Hans', '简体中文'],
    ['en', 'English'],
    ['ja', '日本語'],
    ['ko', '한국어'],
    ['th', 'ไทย'],
    ['ms', 'Bahasa Melayu'],
    ['es', 'Español'],
    ['id', 'Bahasa Indonesia'],
    ['ru', 'Русский'],
    ['de', 'Deutsch'],
    ['fr', 'Français'],
    ['pt', 'Português'],
  ];

  const content = {
    en: {
      title: 'TruthLens AI Content Detection and Document Forensics',
      lead:
        'Analyze Traditional Chinese, English, and multilingual documents on-device with text models, statistical signals, stylometry, rewriting defense, and source evidence.',
      features: [
        'Core AI inference and document content stay on this device',
        'Multiple independent evidence families are cross-checked',
        'Supports PDF, DOCX, ODT, plain text, and OCR import',
        'Provides source evidence, citation checks, and exportable reports',
      ],
      introPrefix: 'Start with public resources:',
      introLinks: [
        'Traditional Chinese AI article detector',
        'Free short-text detector',
        'Local AI detection vs cloud upload',
      ],
      guideLabel: 'Public tools and guides',
      cards: [
        'Local AI detection vs cloud upload',
        'PDF AI detection limits',
        'DOCX editing history evidence',
        'Fake citations and reference checks',
        'What low burstiness means',
        'Traditional Chinese AI article detector',
        'Free short-text detector',
      ],
      status:
        'Public information stays on this page; open the local workspace only when you choose.',
      start: 'Open detection workspace',
      language: 'Language',
      noscript:
        'TruthLens needs JavaScript and WebAssembly to run local AI analysis in the browser.',
    },
    'zh-Hant': {
      title: 'TruthLens AI 內容檢測與文件鑑識',
      lead:
        '在裝置端分析繁體中文、英文與多語文件，整合文字模型、統計特徵、寫作風格、改寫防禦及文件來源證據。',
      features: [
        '核心 AI 推論與文件內容留在本機處理',
        '以多個獨立證據家族交叉檢查，不把單一分數當作定案',
        '支援 PDF、DOCX、ODT、純文字與 OCR 匯入',
        '提供來源紀錄、引用驗證與可匯出的分析報告',
      ],
      introPrefix: '先試用公開入口：',
      introLinks: [
        '免費 AI 文章檢測器',
        '免費短文檢測器',
        '本地 AI 檢測與雲端上傳比較',
      ],
      guideLabel: '公開工具與指南',
      cards: [
        '本地 AI 檢測與雲端上傳比較',
        'PDF AI 檢測限制',
        'DOCX 編輯紀錄證據',
        '假文獻與引用核實',
        'Low burstiness 是什麼',
        '免費繁中 AI 文章檢測器',
        '免費通用短文檢測器',
      ],
      status: '公開資訊會停留在此頁；按下按鈕後才進入本地檢測工作台。',
      start: '開啟檢測工作台',
      language: '語言',
      noscript: 'TruthLens 需要 JavaScript 與 WebAssembly 才能在瀏覽器內執行本地 AI 分析。',
    },
    'zh-Hans': {
      title: 'TruthLens AI 内容检测与文件鉴识',
      lead:
        '在设备端分析简体中文、英文与多语言文件，整合文字模型、统计特征、写作风格、改写防御及文件来源证据。',
      features: [
        '核心 AI 推理与文件内容留在本机处理',
        '以多个独立证据家族交叉检查，不把单一分数当作定案',
        '支持 PDF、DOCX、ODT、纯文本与 OCR 导入',
        '提供来源记录、引用验证与可导出的分析报告',
      ],
      introPrefix: '先试用公开入口：',
      introLinks: ['免费 AI 文章检测器', '免费短文检测器', '本地 AI 检测与云端上传比较'],
      guideLabel: '公开工具与指南',
      cards: [
        '本地 AI 检测与云端上传比较',
        'PDF AI 检测限制',
        'DOCX 编辑记录证据',
        '虚假文献与引用核实',
        'Low burstiness 是什么',
        '免费繁中 AI 文章检测器',
        '免费通用短文检测器',
      ],
      status: '公开信息会停留在此页；按下按钮后才进入本地检测工作台。',
      start: '打开检测工作台',
      language: '语言',
      noscript: 'TruthLens 需要 JavaScript 与 WebAssembly 才能在浏览器内运行本地 AI 分析。',
    },
    ja: {
      title: 'TruthLens AI コンテンツ検出と文書フォレンジック',
      lead:
        '繁体字中国語、英語、多言語文書を端末上で分析し、テキストモデル、統計、文体、書き換え防御、出所証拠を統合します。',
      features: [
        '主要な AI 推論と文書内容はこの端末に残ります',
        '複数の独立した証拠ファミリーを照合します',
        'PDF、DOCX、ODT、プレーンテキスト、OCR 取り込みに対応',
        '出所記録、引用確認、エクスポート可能なレポートを提供',
      ],
      introPrefix: '公開リソースから開始：',
      introLinks: ['無料 AI 文章検出ツール', '無料短文検出ツール', 'ローカル AI 検出とクラウドアップロードの比較'],
      guideLabel: '公開ツールとガイド',
      cards: [
        'ローカル AI 検出とクラウドアップロードの比較',
        'PDF の AI 検出の限界',
        'DOCX 編集履歴の証拠',
        '偽引用と参考文献チェック',
        'Low burstiness の意味',
        '繁体字中国語 AI 文章検出ツール',
        '汎用の無料短文検出ツール',
      ],
      status: '公開情報はこのページに残ります。選択した時だけローカルワークスペースを開きます。',
      start: '検出ワークスペースを開く',
      language: '言語',
      noscript: 'TruthLens のローカル AI 分析には JavaScript と WebAssembly が必要です。',
    },
    ko: {
      title: 'TruthLens AI 콘텐츠 감지 및 문서 포렌식',
      lead:
        '번체 중국어, 영어, 다국어 문서를 기기에서 분석하고 텍스트 모델, 통계, 문체, 재작성 방어, 출처 증거를 결합합니다.',
      features: [
        '핵심 AI 추론과 문서 내용은 이 기기에 남습니다',
        '여러 독립 증거군을 교차 확인합니다',
        'PDF, DOCX, ODT, 일반 텍스트, OCR 가져오기를 지원합니다',
        '출처 기록, 인용 검증, 내보낼 수 있는 보고서를 제공합니다',
      ],
      introPrefix: '공개 자료로 시작:',
      introLinks: ['무료 AI 글 감지기', '무료 짧은 글 감지기', '로컬 AI 감지와 클라우드 업로드 비교'],
      guideLabel: '공개 도구 및 가이드',
      cards: [
        '로컬 AI 감지와 클라우드 업로드 비교',
        'PDF AI 감지의 한계',
        'DOCX 편집 기록 증거',
        '가짜 인용 및 참고문헌 확인',
        'Low burstiness 의미',
        '번체 중국어 AI 글 감지기',
        '범용 무료 짧은 글 감지기',
      ],
      status: '공개 정보는 이 페이지에 머뭅니다. 선택할 때만 로컬 작업 공간을 엽니다.',
      start: '감지 작업 공간 열기',
      language: '언어',
      noscript: 'TruthLens가 브라우저에서 로컬 AI 분석을 실행하려면 JavaScript와 WebAssembly가 필요합니다.',
    },
    th: {
      title: 'TruthLens การตรวจเนื้อหา AI และนิติวิทยาศาสตร์เอกสาร',
      lead:
        'วิเคราะห์เอกสารจีนตัวเต็ม อังกฤษ และหลายภาษาในอุปกรณ์ ด้วยโมเดลข้อความ สถิติ สไตล์การเขียน การป้องกันการเขียนใหม่ และหลักฐานที่มา',
      features: [
        'การอนุมาน AI หลักและเนื้อหาเอกสารอยู่บนอุปกรณ์นี้',
        'ตรวจข้ามหลายกลุ่มหลักฐานอิสระ',
        'รองรับ PDF, DOCX, ODT, ข้อความล้วน และ OCR',
        'มีหลักฐานที่มา การตรวจอ้างอิง และรายงานที่ส่งออกได้',
      ],
      introPrefix: 'เริ่มจากแหล่งข้อมูลสาธารณะ:',
      introLinks: ['ตัวตรวจบทความ AI ฟรี', 'ตัวตรวจข้อความสั้นฟรี', 'การตรวจ AI ในเครื่องเทียบกับคลาวด์'],
      guideLabel: 'เครื่องมือและคู่มือสาธารณะ',
      cards: [
        'การตรวจ AI ในเครื่องเทียบกับคลาวด์',
        'ข้อจำกัดของการตรวจ AI ใน PDF',
        'หลักฐานประวัติการแก้ไข DOCX',
        'การอ้างอิงปลอมและการตรวจเอกสารอ้างอิง',
        'Low burstiness คืออะไร',
        'ตัวตรวจบทความ AI ภาษาจีนตัวเต็มฟรี',
        'ตัวตรวจข้อความสั้นทั่วไปฟรี',
      ],
      status: 'ข้อมูลสาธารณะจะอยู่ในหน้านี้ และจะเปิดพื้นที่ทำงานเมื่อคุณกดเท่านั้น',
      start: 'เปิดพื้นที่ทำงานตรวจจับ',
      language: 'ภาษา',
      noscript: 'TruthLens ต้องใช้ JavaScript และ WebAssembly เพื่อวิเคราะห์ AI ในเบราว์เซอร์',
    },
    ms: {
      title: 'TruthLens Pengesanan Kandungan AI dan Forensik Dokumen',
      lead:
        'Analisis dokumen Cina Tradisional, Inggeris dan pelbagai bahasa pada peranti dengan model teks, statistik, gaya, pertahanan tulis semula dan bukti sumber.',
      features: [
        'Inferens AI teras dan kandungan dokumen kekal pada peranti ini',
        'Beberapa keluarga bukti bebas disemak silang',
        'Menyokong import PDF, DOCX, ODT, teks biasa dan OCR',
        'Menyediakan bukti sumber, semakan petikan dan laporan boleh eksport',
      ],
      introPrefix: 'Mulakan dengan sumber awam:',
      introLinks: ['Pengesan artikel AI percuma', 'Pengesan teks pendek percuma', 'Pengesanan AI setempat berbanding awan'],
      guideLabel: 'Alat dan panduan awam',
      cards: [
        'Pengesanan AI setempat berbanding awan',
        'Had pengesanan AI untuk PDF',
        'Bukti sejarah suntingan DOCX',
        'Semakan petikan palsu dan rujukan',
        'Maksud low burstiness',
        'Pengesan artikel AI Cina Tradisional percuma',
        'Pengesan teks pendek umum percuma',
      ],
      status: 'Maklumat awam kekal pada halaman ini; ruang kerja setempat hanya dibuka apabila anda memilih.',
      start: 'Buka ruang kerja pengesanan',
      language: 'Bahasa',
      noscript: 'TruthLens memerlukan JavaScript dan WebAssembly untuk menjalankan analisis AI setempat dalam pelayar.',
    },
    es: {
      title: 'TruthLens Detección de Contenido IA y Forense Documental',
      lead:
        'Analiza documentos en chino tradicional, inglés y varios idiomas en el dispositivo con modelos de texto, estadísticas, estilo, defensa contra reescritura y evidencia de origen.',
      features: [
        'La inferencia principal y el contenido del documento permanecen en este dispositivo',
        'Se cruzan varias familias de evidencia independientes',
        'Admite PDF, DOCX, ODT, texto plano y OCR',
        'Ofrece evidencia de origen, verificación de citas e informes exportables',
      ],
      introPrefix: 'Empieza con recursos públicos:',
      introLinks: ['Detector gratuito de artículos IA', 'Detector gratuito de texto breve', 'Detección local de IA frente a la nube'],
      guideLabel: 'Herramientas y guías públicas',
      cards: [
        'Detección local de IA frente a la nube',
        'Límites de la detección de IA en PDF',
        'Evidencia del historial de edición DOCX',
        'Citas falsas y verificación de referencias',
        'Qué significa low burstiness',
        'Detector gratuito de artículos IA en chino tradicional',
        'Detector gratuito general de texto breve',
      ],
      status: 'La información pública permanece en esta página; el área local se abre solo cuando lo eliges.',
      start: 'Abrir área de detección',
      language: 'Idioma',
      noscript: 'TruthLens necesita JavaScript y WebAssembly para ejecutar análisis local de IA en el navegador.',
    },
    id: {
      title: 'TruthLens Deteksi Konten AI dan Forensik Dokumen',
      lead:
        'Analisis dokumen Tionghoa Tradisional, Inggris, dan multibahasa di perangkat dengan model teks, statistik, gaya, pertahanan penulisan ulang, dan bukti sumber.',
      features: [
        'Inferensi AI inti dan isi dokumen tetap di perangkat ini',
        'Beberapa keluarga bukti independen diperiksa silang',
        'Mendukung PDF, DOCX, ODT, teks biasa, dan OCR',
        'Menyediakan bukti sumber, pemeriksaan kutipan, dan laporan yang dapat diekspor',
      ],
      introPrefix: 'Mulai dari sumber publik:',
      introLinks: ['Detektor artikel AI gratis', 'Detektor teks pendek gratis', 'Deteksi AI lokal vs cloud'],
      guideLabel: 'Alat dan panduan publik',
      cards: [
        'Deteksi AI lokal vs cloud',
        'Batas deteksi AI pada PDF',
        'Bukti riwayat penyuntingan DOCX',
        'Kutipan palsu dan pemeriksaan referensi',
        'Arti low burstiness',
        'Detektor artikel AI Tionghoa Tradisional gratis',
        'Detektor teks pendek umum gratis',
      ],
      status: 'Informasi publik tetap di halaman ini; ruang kerja lokal dibuka hanya saat Anda memilih.',
      start: 'Buka ruang kerja deteksi',
      language: 'Bahasa',
      noscript: 'TruthLens membutuhkan JavaScript dan WebAssembly untuk menjalankan analisis AI lokal di browser.',
    },
    ru: {
      title: 'TruthLens: AI-проверка контента и экспертиза документов',
      lead:
        'Анализируйте документы на традиционном китайском, английском и других языках локально: текстовые модели, статистика, стиль, защита от перефразирования и доказательства источника.',
      features: [
        'Основная AI-проверка и текст документа остаются на этом устройстве',
        'Несколько независимых групп доказательств сверяются между собой',
        'Поддерживаются PDF, DOCX, ODT, обычный текст и OCR',
        'Есть данные об источнике, проверка ссылок и экспортируемые отчеты',
      ],
      introPrefix: 'Начните с открытых материалов:',
      introLinks: ['Бесплатный детектор AI-текстов', 'Бесплатный детектор короткого текста', 'Локальная AI-проверка и облако'],
      guideLabel: 'Открытые инструменты и руководства',
      cards: [
        'Локальная AI-проверка и облако',
        'Ограничения AI-проверки PDF',
        'История редактирования DOCX как доказательство',
        'Фальшивые цитаты и проверка источников',
        'Что означает low burstiness',
        'Бесплатный детектор AI-статей на традиционном китайском',
        'Бесплатный универсальный детектор короткого текста',
      ],
      status: 'Открытая информация остается на этой странице; локальная рабочая область открывается только по кнопке.',
      start: 'Открыть рабочую область',
      language: 'Язык',
      noscript: 'TruthLens требует JavaScript и WebAssembly для локального анализа AI в браузере.',
    },
    de: {
      title: 'TruthLens KI-Inhaltserkennung und Dokumentforensik',
      lead:
        'Analysieren Sie traditionell chinesische, englische und mehrsprachige Dokumente lokal mit Textmodellen, Statistik, Stilometrie, Umschreibschutz und Quellenbelegen.',
      features: [
        'Kern-Inferenz und Dokumentinhalt bleiben auf diesem Gerät',
        'Mehrere unabhängige Belegfamilien werden abgeglichen',
        'Unterstützt PDF, DOCX, ODT, Klartext und OCR-Import',
        'Bietet Quellenbelege, Zitatprüfung und exportierbare Berichte',
      ],
      introPrefix: 'Starten Sie mit öffentlichen Ressourcen:',
      introLinks: ['Kostenloser KI-Artikelprüfer', 'Kostenloser Kurztext-Detektor', 'Lokale KI-Erkennung statt Cloud'],
      guideLabel: 'Öffentliche Tools und Leitfäden',
      cards: [
        'Lokale KI-Erkennung statt Cloud',
        'Grenzen der KI-Erkennung bei PDF',
        'DOCX-Bearbeitungshistorie als Nachweis',
        'Falsche Zitate und Quellenprüfung',
        'Was low burstiness bedeutet',
        'Kostenloser KI-Artikelprüfer für traditionelles Chinesisch',
        'Kostenloser allgemeiner Kurztext-Detektor',
      ],
      status: 'Öffentliche Informationen bleiben auf dieser Seite; der lokale Arbeitsbereich öffnet sich erst per Klick.',
      start: 'Prüf-Arbeitsbereich öffnen',
      language: 'Sprache',
      noscript: 'TruthLens benötigt JavaScript und WebAssembly für lokale KI-Analyse im Browser.',
    },
    fr: {
      title: 'TruthLens Détection de Contenu IA et Analyse Documentaire',
      lead:
        'Analysez localement des documents en chinois traditionnel, anglais et autres langues avec modèles texte, statistiques, stylométrie, défense contre la réécriture et preuves d’origine.',
      features: [
        'L’inférence IA principale et le contenu restent sur cet appareil',
        'Plusieurs familles d’indices indépendantes sont croisées',
        'Prend en charge PDF, DOCX, ODT, texte brut et OCR',
        'Fournit origine, vérification des citations et rapports exportables',
      ],
      introPrefix: 'Commencez par les ressources publiques :',
      introLinks: ['Détecteur gratuit d’articles IA', 'Détecteur gratuit de texte court', 'Détection IA locale ou cloud'],
      guideLabel: 'Outils et guides publics',
      cards: [
        'Détection IA locale ou cloud',
        'Limites de la détection IA sur PDF',
        'Historique DOCX comme indice',
        'Fausses citations et vérification des références',
        'Ce que signifie low burstiness',
        'Détecteur gratuit d’articles IA en chinois traditionnel',
        'Détecteur général gratuit de texte court',
      ],
      status: 'Les informations publiques restent sur cette page ; l’espace local ne s’ouvre que lorsque vous le choisissez.',
      start: 'Ouvrir l’espace de détection',
      language: 'Langue',
      noscript: 'TruthLens nécessite JavaScript et WebAssembly pour l’analyse IA locale dans le navigateur.',
    },
    pt: {
      title: 'TruthLens Detecção de Conteúdo IA e Forense Documental',
      lead:
        'Analise documentos em chinês tradicional, inglês e vários idiomas no dispositivo com modelos de texto, estatísticas, estilo, defesa contra reescrita e evidências de origem.',
      features: [
        'A inferência principal e o conteúdo ficam neste dispositivo',
        'Várias famílias de evidência independentes são cruzadas',
        'Suporta PDF, DOCX, ODT, texto simples e OCR',
        'Oferece evidência de origem, verificação de citações e relatórios exportáveis',
      ],
      introPrefix: 'Comece pelos recursos públicos:',
      introLinks: ['Detector gratuito de artigos IA', 'Detector gratuito de texto curto', 'Detecção local de IA versus nuvem'],
      guideLabel: 'Ferramentas e guias públicos',
      cards: [
        'Detecção local de IA versus nuvem',
        'Limites da detecção de IA em PDF',
        'Histórico de edição DOCX como evidência',
        'Citações falsas e verificação de referências',
        'O que significa low burstiness',
        'Detector gratuito de artigos IA em chinês tradicional',
        'Detector geral gratuito de texto curto',
      ],
      status: 'As informações públicas ficam nesta página; o workspace local só abre quando você escolher.',
      start: 'Abrir workspace de detecção',
      language: 'Idioma',
      noscript: 'TruthLens precisa de JavaScript e WebAssembly para executar análise local de IA no navegador.',
    },
  };

  const routes = [
    '/privacy/local-ai-detector-vs-cloud-upload',
    '/formats/pdf-ai-detection-limitations',
    '/formats/docx-editing-history-ai-evidence',
    '/ai-writing-signs/fake-citations',
    '/ai-writing-signs/low-burstiness',
    '/zh/ai-article-detector',
    '/free-ai-detector',
  ];

  function normalize(value) {
    if (!value) return 'zh-Hant';
    const lower = value.replace('_', '-').toLowerCase();
    if (lower === 'zh-hant' || lower === 'zh-tw' || lower === 'zh-hk') return 'zh-Hant';
    if (lower === 'zh-hans' || lower === 'zh-cn' || lower === 'zh-sg') return 'zh-Hans';
    const base = lower.split('-')[0];
    return content[base] ? base : 'zh-Hant';
  }

  function selectedLanguage() {
    const params = new URLSearchParams(window.location.search || '');
    try {
      return normalize(
        params.get('lang') ||
          window.localStorage.getItem('truthlens-public-lang') ||
          navigator.language ||
          document.documentElement.lang,
      );
    } catch (_) {
      return normalize(params.get('lang') || navigator.language || document.documentElement.lang);
    }
  }

  function storeLanguage(lang) {
    try {
      window.localStorage.setItem('truthlens-public-lang', lang);
    } catch (_) {}
  }

  function setText(selector, value) {
    const node = document.querySelector(selector);
    if (node) node.textContent = value;
  }

  function applyLinks(pack, lang) {
    const introLinks = document.querySelectorAll('[data-home-intro-link]');
    introLinks.forEach((link, index) => {
      link.textContent = pack.introLinks[index];
      link.setAttribute('href', link.getAttribute('data-path') + '?lang=' + encodeURIComponent(lang));
      link.addEventListener('click', () => storeLanguage(lang), { once: true });
    });

    const cards = document.querySelectorAll('[data-home-card-link]');
    cards.forEach((link, index) => {
      link.textContent = pack.cards[index];
      link.setAttribute('href', routes[index] + '?lang=' + encodeURIComponent(lang));
      link.addEventListener('click', () => storeLanguage(lang), { once: true });
    });

    const start = document.getElementById('seo-shell-start');
    if (start) {
      start.setAttribute('href', '/?workspace=1&lang=' + encodeURIComponent(lang));
      start.addEventListener('click', () => storeLanguage(lang), { once: true });
    }
  }

  function renderLanguagePicker(lang, pack) {
    const host = document.querySelector('[data-home-language]');
    if (!host) return;
    host.replaceChildren();

    const label = document.createElement('label');
    label.setAttribute('for', 'seo-language');
    label.textContent = pack.language;

    const select = document.createElement('select');
    select.id = 'seo-language';
    languages.forEach(([code, name]) => {
      const option = document.createElement('option');
      option.value = code;
      option.textContent = name;
      option.selected = code === lang;
      select.appendChild(option);
    });
    select.value = lang;
    select.addEventListener('change', () => {
      const nextLang = normalize(select.value);
      select.value = nextLang;
      storeLanguage(nextLang);
      const url = new URL(window.location.href);
      url.searchParams.set('lang', nextLang);
      window.history.replaceState(null, '', url.pathname + url.search);
      applyHome(nextLang);
    });

    host.append(label, select);
    host.setAttribute('aria-label', pack.language);
    host.dataset.currentLang = lang;
  }

  function applyHome(lang) {
    const pack = content[normalize(lang)] || content['zh-Hant'];
    const normalized = pack === content['zh-Hant'] ? 'zh-Hant' : pack.lang;
    document.documentElement.lang = normalized;
    document.title = pack.title + ' | TruthLens';
    const description = document.querySelector('meta[name="description"]');
    if (description) description.setAttribute('content', pack.lead);
    setText('#seo-title', pack.title);
    setText('[data-home-lead]', pack.lead);
    setText('[data-home-intro-prefix]', pack.introPrefix);
    setText('[data-home-guide-label]', pack.guideLabel);
    setText('.seo-shell__status', pack.status);
    setText('#seo-shell-start', pack.start);
    setText('noscript', pack.noscript);

    document.querySelectorAll('[data-home-feature]').forEach((item, index) => {
      item.textContent = pack.features[index];
    });
    renderLanguagePicker(normalized, pack);
    applyLinks(pack, normalized);
    storeLanguage(normalized);
  }

  applyHome(selectedLanguage());
})();
