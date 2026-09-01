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

  const languageLabels = {
    en: 'Language',
    'zh-Hant': '語言',
    'zh-Hans': '语言',
    ja: '言語',
    ko: '언어',
    th: 'ภาษา',
    ms: 'Bahasa',
    es: 'Idioma',
    id: 'Bahasa',
    ru: 'Язык',
    de: 'Sprache',
    fr: 'Langue',
    pt: 'Idioma',
  };

  const navLabels = {
    en: 'Main navigation',
    'zh-Hant': '主要導覽',
    'zh-Hans': '主要导航',
    ja: 'メインナビゲーション',
    ko: '기본 탐색',
    th: 'การนำทางหลัก',
    ms: 'Navigasi utama',
    es: 'Navegación principal',
    id: 'Navigasi utama',
    ru: 'Основная навигация',
    de: 'Hauptnavigation',
    fr: 'Navigation principale',
    pt: 'Navegação principal',
  };

  const common = {
    en: {
      lang: 'en', nav: ['Free detector', 'Privacy guide', 'PDF limits', 'DOCX evidence', 'Open workspace'],
      detectorLabel: 'Text sample', detectorButton: 'Analyze preview', detectorPlaceholder: 'Paste up to about 220 words. The preview checks local statistical patterns only.', detectorInitial: 'Results will appear here. Your text stays in this browser.',
      pages: {
        free: ['Free AI Detector', 'Free browser preview', 'Paste a short writing sample and get instant local signals before opening the full OmniTrace workspace. No login and no upload are required.'],
        zhFree: ['Traditional Chinese AI Detector', 'Free browser preview', 'Use the same no-upload short text preview with Traditional Chinese entry text.'],
        localVsCloud: ['Local AI Detector vs Cloud Upload Tools', 'Privacy guide', 'Compare local AI detection with tools that require uploading confidential drafts.'],
        pdfLimits: ['PDF AI Detection Limitations', 'File forensics', 'PDF files are useful for visible text extraction, but weak for proving how a document was written.'],
        docxEvidence: ['DOCX Editing History as AI Evidence', 'Source evidence', 'Original editable files can preserve drafting clues that a pasted PDF or copied text cannot show.'],
        lowBurstiness: ['Low Burstiness in AI Writing', 'Writing signal', 'Sentence rhythm can be an AI signal, but it must be interpreted with other evidence.'],
        fakeCitations: ['Fake Citations and Reference Checks', 'Reference checks', 'Plausible references still need DOI, journal, author, and title verification.']
      },
      article: {
        body: ['What to know', 'OmniTrace separates text signals, file-source evidence, and reference verification so that one weak signal does not become a verdict.', 'How to use it', 'Start with the public guide or short-text preview, then open the full local workspace when you need sentence-level reasons, file import, history, and PDF export.']
      }
    },
    'zh-Hant': {
      lang: 'zh-Hant', nav: ['免費檢測器', '隱私指南', 'PDF 限制', 'DOCX 證據', '開啟工作台'],
      detectorLabel: '文字樣本', detectorButton: '開始預覽', detectorPlaceholder: '建議貼上 220 字以內。預覽只檢查輕量本機統計特徵。', detectorInitial: '結果會顯示在這裡。文字只留在這個瀏覽器。',
      pages: {
        free: ['免費通用短文檢測器', '多語短文預覽', '貼上一小段任意語言文章，先在瀏覽器本機取得初步訊號；不需登入，也不會上傳文字。'],
        zhFree: ['繁中 AI 文章檢測器', '繁體中文入口', '這是繁體中文文章入口，針對繁中使用者提供不需上傳的短文初步檢測。'],
        localVsCloud: ['本地 AI 檢測與雲端上傳比較', '隱私指南', '比較本地檢測與需要上傳機密草稿的雲端工具。'],
        pdfLimits: ['PDF AI 檢測限制', '文件鑑識', 'PDF 適合抽取可見文字，但通常不適合證明文件實際如何被撰寫。'],
        docxEvidence: ['DOCX 編輯紀錄證據', '來源證據', '原始可編輯檔可能保留 PDF 或複製文字看不到的撰寫過程線索。'],
        lowBurstiness: ['AI 寫作的低突發性', '寫作訊號', '句長和節奏過度整齊可能是 AI 訊號，但必須和其他證據一起判讀。'],
        fakeCitations: ['假文獻與引用核實', '引用檢查', '看起來合理的參考文獻仍需核對 DOI、期刊、作者與篇名。']
      },
      article: { body: ['你需要知道的事', 'OmniTrace 會拆開文字訊號、文件來源證據與文獻核實，避免把單一薄弱訊號誤當成結論。', '如何使用', '可先閱讀公開指南或試用短文預覽；需要逐句理由、文件匯入、歷史紀錄與 PDF 匯出時，再開啟完整本地工作台。'] }
    },
    'zh-Hans': {
      lang: 'zh-Hans', nav: ['免费检测器', '隐私指南', 'PDF 限制', 'DOCX 证据', '打开工作台'], detectorLabel: '文字样本', detectorButton: '开始预览', detectorPlaceholder: '建议粘贴 220 字以内。预览只检查轻量本地统计特征。', detectorInitial: '结果会显示在这里。文字只留在这个浏览器。',
      pages: { free: ['免费通用短文检测器','多语短文预览','粘贴一小段任意语言文章，在浏览器本地取得初步信号；无需登录，也不会上传文字。'], zhFree: ['繁中 AI 文章检测器','繁体中文入口','这是繁体中文文章入口，针对繁中使用者提供无需上传的短文初步检测。'], localVsCloud: ['本地 AI 检测与云端上传比较','隐私指南','比较本地检测与需要上传机密草稿的云端工具。'], pdfLimits: ['PDF AI 检测限制','文件鉴识','PDF 适合提取可见文字，但通常不适合证明文件实际如何被撰写。'], docxEvidence: ['DOCX 编辑记录证据','来源证据','原始可编辑文件可能保留 PDF 或复制文字看不到的写作过程线索。'], lowBurstiness: ['AI 写作的低突发性','写作信号','句长和节奏过度整齐可能是 AI 信号，但必须和其他证据一起解读。'], fakeCitations: ['虚假文献与引用核实','引用检查','看似合理的参考文献仍需核对 DOI、期刊、作者与题名。'] }, article: { body: ['需要了解的事','OmniTrace 会拆分文字信号、文件来源证据与文献核实，避免把单一薄弱信号误当成结论。','如何使用','可先阅读公开指南或试用短文预览；需要逐句理由、文件导入、历史记录与 PDF 导出时，再打开完整本地工作台。'] }
    },
    ja: { lang: 'ja', nav: ['無料検出', 'プライバシー', 'PDF の限界', 'DOCX 証拠', 'ワークスペースを開く'], detectorLabel: 'テキストサンプル', detectorButton: 'プレビュー分析', detectorPlaceholder: '約 220 語以内を貼り付けてください。軽量なローカル統計だけを確認します。', detectorInitial: '結果はここに表示されます。テキストはこのブラウザ内に残ります。', pages: { free: ['無料 AI 文章検出ツール','無料ブラウザプレビュー','短い文章を貼り付けるだけで、アップロードなしにローカルの初期シグナルを確認できます。'], zhFree: ['繁体字中国語 AI 検出ツール','無料ブラウザプレビュー','繁体字中国語向けの短文プレビュー入口です。'], localVsCloud: ['ローカル AI 検出とクラウドアップロードの比較','プライバシーガイド','機密草稿をアップロードするツールとローカル検出を比較します。'], pdfLimits: ['PDF の AI 検出の限界','ファイル鑑識','PDF は表示テキストの抽出には有用ですが、執筆過程の証明には弱い形式です。'], docxEvidence: ['DOCX 編集履歴の証拠','出所証拠','編集可能な元ファイルには、PDF やコピー文では見えない執筆履歴が残る場合があります。'], lowBurstiness: ['AI 文章における低バースト性','文章シグナル','文の長さやリズムが整いすぎる場合、AI の兆候になり得ますが単独では判断できません。'], fakeCitations: ['偽引用と参考文献チェック','参考文献チェック','もっともらしい参考文献でも DOI、雑誌、著者、題名の確認が必要です。'] }, article: { body: ['知っておくこと','OmniTrace は文章シグナル、ファイル出所、参考文献確認を分けて表示し、弱いシグナルを結論にしません。','使い方','公開ガイドや短文プレビューから始め、逐文理由、ファイル取り込み、履歴、PDF 出力が必要なときに完全なローカルワークスペースを開きます。'] } },
    ko: { lang: 'ko', nav: ['무료 감지기','개인정보 가이드','PDF 한계','DOCX 증거','작업 공간 열기'], detectorLabel: '텍스트 샘플', detectorButton: '미리 분석', detectorPlaceholder: '약 220단어 이내를 붙여넣으세요. 가벼운 로컬 통계만 확인합니다.', detectorInitial: '결과가 여기에 표시됩니다. 텍스트는 이 브라우저에만 남습니다.', pages: { free: ['무료 AI 글 감지기','무료 브라우저 미리보기','짧은 글을 붙여넣고 업로드 없이 로컬 초기 신호를 확인합니다.'], zhFree: ['번체 중국어 AI 감지기','무료 브라우저 미리보기','번체 중국어용 짧은 글 미리보기 입구입니다.'], localVsCloud: ['로컬 AI 감지와 클라우드 업로드 비교','개인정보 가이드','기밀 초안을 업로드해야 하는 도구와 로컬 감지를 비교합니다.'], pdfLimits: ['PDF AI 감지의 한계','파일 포렌식','PDF는 보이는 텍스트 추출에는 유용하지만 작성 과정을 증명하기에는 약합니다.'], docxEvidence: ['DOCX 편집 기록 증거','출처 증거','원본 편집 파일은 PDF나 복사 텍스트에 없는 작성 과정 단서를 보존할 수 있습니다.'], lowBurstiness: ['AI 글쓰기의 낮은 버스티니스','쓰기 신호','문장 길이와 리듬이 지나치게 일정하면 AI 신호일 수 있지만 단독 판단은 위험합니다.'], fakeCitations: ['가짜 인용 및 참고문헌 확인','참고문헌 확인','그럴듯한 참고문헌도 DOI, 저널, 저자, 제목 확인이 필요합니다.'] }, article: { body: ['알아둘 점','OmniTrace는 텍스트 신호, 파일 출처 증거, 참고문헌 검증을 분리해 약한 신호 하나가 결론이 되지 않도록 합니다.','사용 방법','공개 가이드나 짧은 글 미리보기로 시작하고, 문장별 이유, 파일 가져오기, 기록, PDF 내보내기가 필요할 때 전체 로컬 작업 공간을 엽니다.'] } },
    de: { lang: 'de', nav: ['Kostenloser Detektor','Datenschutz','PDF-Grenzen','DOCX-Nachweis','Arbeitsbereich öffnen'], detectorLabel: 'Textprobe', detectorButton: 'Vorschau analysieren', detectorPlaceholder: 'Fügen Sie bis etwa 220 Wörter ein. Die Vorschau prüft nur lokale statistische Muster.', detectorInitial: 'Ergebnisse erscheinen hier. Ihr Text bleibt in diesem Browser.', pages: { free: ['Kostenloser KI-Textdetektor','Kostenlose Browser-Vorschau','Fügen Sie einen kurzen Text ein und prüfen Sie lokale Signale ohne Login und ohne Upload.'], zhFree: ['Detektor für traditionelles Chinesisch','Kostenlose Browser-Vorschau','Kurztext-Vorschau für traditionelles Chinesisch ohne Upload.'], localVsCloud: ['Lokale KI-Erkennung statt Cloud-Upload','Datenschutzleitfaden','Vergleichen Sie lokale Erkennung mit Diensten, die vertrauliche Entwürfe hochladen müssen.'], pdfLimits: ['Grenzen der KI-Erkennung bei PDF','Dateiforensik','PDFs eignen sich für sichtbaren Text, aber kaum als Nachweis des Schreibprozesses.'], docxEvidence: ['DOCX-Bearbeitungshistorie als Nachweis','Quelldatei-Nachweis','Bearbeitbare Originaldateien können Entstehungshinweise enthalten, die PDF oder kopierter Text nicht zeigen.'], lowBurstiness: ['Niedrige Burstiness in KI-Texten','Schreibsignal','Zu gleichmäßige Satzlängen und Rhythmen können ein KI-Signal sein, müssen aber mit weiteren Belegen gelesen werden.'], fakeCitations: ['Falsche Zitate und Quellenprüfung','Referenzprüfung','Plausible Literaturangaben brauchen DOI-, Journal-, Autoren- und Titelprüfung.'] }, article: { body: ['Wichtig zu wissen','OmniTrace trennt Textsignale, Dateiquellen und Referenzprüfung, damit ein schwaches Signal nicht zum Urteil wird.','So nutzen Sie es','Beginnen Sie mit dem öffentlichen Leitfaden oder der Kurztext-Vorschau und öffnen Sie den lokalen Arbeitsbereich für Satzbelege, Dateiimport, Verlauf und PDF-Export.'] } },
    fr: { lang: 'fr', nav: ['Détecteur gratuit','Confidentialité','Limites PDF','Indice DOCX','Ouvrir l’espace'], detectorLabel: 'Extrait de texte', detectorButton: 'Analyser l’aperçu', detectorPlaceholder: 'Collez jusqu’à environ 220 mots. L’aperçu vérifie seulement des signaux statistiques locaux.', detectorInitial: 'Les résultats apparaîtront ici. Votre texte reste dans ce navigateur.', pages: { free: ['Détecteur IA gratuit','Aperçu gratuit dans le navigateur','Collez un court texte et obtenez des signaux locaux sans compte ni envoi.'], zhFree: ['Détecteur chinois traditionnel','Aperçu gratuit dans le navigateur','Entrée de prévisualisation pour courts textes en chinois traditionnel, sans envoi.'], localVsCloud: ['Détection IA locale ou envoi vers le cloud','Guide de confidentialité','Comparez la détection locale avec les outils qui exigent l’envoi de brouillons confidentiels.'], pdfLimits: ['Limites de la détection IA sur PDF','Analyse de fichier','Le PDF aide à extraire le texte visible, mais prouve mal le processus d’écriture.'], docxEvidence: ['Historique DOCX comme indice','Indice de source','Un fichier éditable original peut conserver des traces invisibles dans un PDF ou un texte copié.'], lowBurstiness: ['Faible burstiness dans l’écriture IA','Signal d’écriture','Un rythme trop régulier peut être un signal IA, mais doit être lu avec d’autres indices.'], fakeCitations: ['Fausses citations et vérification des références','Vérification bibliographique','Une référence plausible doit quand même être vérifiée par DOI, revue, auteur et titre.'] }, article: { body: ['À savoir','OmniTrace sépare signaux textuels, origine du fichier et vérification bibliographique afin qu’un indice faible ne devienne pas un verdict.','Comment l’utiliser','Commencez par le guide public ou l’aperçu de texte court, puis ouvrez l’espace local complet pour les raisons phrase par phrase, l’import de fichiers, l’historique et l’export PDF.'] } },
    es: { lang: 'es', nav: ['Detector gratuito','Privacidad','Límites PDF','Evidencia DOCX','Abrir área'], detectorLabel: 'Muestra de texto', detectorButton: 'Analizar vista previa', detectorPlaceholder: 'Pega hasta unas 220 palabras. La vista previa solo revisa señales estadísticas locales.', detectorInitial: 'Los resultados aparecerán aquí. El texto queda en este navegador.', pages: { free: ['Detector gratuito de IA','Vista previa gratuita en el navegador','Pega un texto breve y obtén señales locales sin cuenta ni subida.'], zhFree: ['Detector de chino tradicional','Vista previa gratuita en el navegador','Entrada para textos breves en chino tradicional sin subir contenido.'], localVsCloud: ['Detección local de IA frente a subida a la nube','Guía de privacidad','Compara la detección local con herramientas que exigen subir borradores confidenciales.'], pdfLimits: ['Límites de la detección de IA en PDF','Análisis forense de archivos','El PDF sirve para extraer texto visible, pero es débil para probar cómo se escribió un documento.'], docxEvidence: ['Historial de edición DOCX como evidencia','Evidencia de origen','Un archivo editable original puede conservar pistas que un PDF o texto copiado no muestra.'], lowBurstiness: ['Baja burstiness en escritura de IA','Señal de escritura','Un ritmo demasiado regular puede ser una señal de IA, pero debe leerse con otros indicios.'], fakeCitations: ['Citas falsas y verificación de referencias','Verificación bibliográfica','Una referencia plausible aún necesita comprobar DOI, revista, autor y título.'] }, article: { body: ['Qué saber','OmniTrace separa señales de texto, origen del archivo y verificación bibliográfica para que una señal débil no se convierta en veredicto.','Cómo usarlo','Empieza con la guía pública o la vista previa breve; abre el espacio local completo para razones por frase, importación, historial y exportación PDF.'] } },
    pt: { lang: 'pt', nav: ['Detector gratuito','Privacidade','Limites PDF','Evidência DOCX','Abrir workspace'], detectorLabel: 'Amostra de texto', detectorButton: 'Analisar prévia', detectorPlaceholder: 'Cole até cerca de 220 palavras. A prévia verifica apenas sinais estatísticos locais.', detectorInitial: 'Os resultados aparecerão aqui. O texto fica neste navegador.', pages: { free: ['Detector gratuito de IA','Prévia gratuita no navegador','Cole um texto curto e veja sinais locais sem conta e sem envio.'], zhFree: ['Detector de chinês tradicional','Prévia gratuita no navegador','Entrada para textos curtos em chinês tradicional sem upload.'], localVsCloud: ['Detecção local de IA versus envio à nuvem','Guia de privacidade','Compare a detecção local com ferramentas que exigem enviar rascunhos confidenciais.'], pdfLimits: ['Limites da detecção de IA em PDF','Forense de arquivos','PDF ajuda a extrair texto visível, mas é fraco para provar como um documento foi escrito.'], docxEvidence: ['Histórico de edição DOCX como evidência','Evidência de origem','Arquivos editáveis originais podem guardar pistas que PDF ou texto copiado não mostram.'], lowBurstiness: ['Baixa burstiness em escrita de IA','Sinal de escrita','Ritmo regular demais pode ser sinal de IA, mas precisa ser lido com outras evidências.'], fakeCitations: ['Citações falsas e verificação de referências','Verificação bibliográfica','Referências plausíveis ainda exigem checagem de DOI, periódico, autor e título.'] }, article: { body: ['O que saber','OmniTrace separa sinais do texto, origem do arquivo e verificação bibliográfica para que um sinal fraco não vire veredito.','Como usar','Comece pelo guia público ou pela prévia curta; abra o workspace local completo para razões por frase, importação, histórico e exportação PDF.'] } },
    ru: { lang: 'ru', nav: ['Бесплатный детектор','Конфиденциальность','Ограничения PDF','Доказательства DOCX','Открыть рабочую область'], detectorLabel: 'Образец текста', detectorButton: 'Проверить предварительно', detectorPlaceholder: 'Вставьте до 220 слов. Предпросмотр проверяет только локальные статистические признаки.', detectorInitial: 'Результаты появятся здесь. Текст остается в этом браузере.', pages: { free: ['Бесплатный AI-детектор','Бесплатный предпросмотр в браузере','Вставьте короткий текст и получите локальные признаки без входа и загрузки.'], zhFree: ['Детектор традиционного китайского','Бесплатный предпросмотр в браузере','Вход для коротких текстов на традиционном китайском без загрузки.'], localVsCloud: ['Локальная AI-проверка и облачная загрузка','Руководство по приватности','Сравните локальную проверку с инструментами, требующими загрузки конфиденциальных черновиков.'], pdfLimits: ['Ограничения AI-проверки PDF','Файловая экспертиза','PDF полезен для видимого текста, но слаб как доказательство процесса написания.'], docxEvidence: ['История редактирования DOCX как доказательство','Доказательство источника','Исходный редактируемый файл может хранить следы, которых нет в PDF или скопированном тексте.'], lowBurstiness: ['Низкая burstiness в AI-тексте','Письменный сигнал','Слишком ровный ритм может быть признаком AI, но его нужно читать вместе с другими данными.'], fakeCitations: ['Фальшивые цитаты и проверка источников','Проверка ссылок','Даже правдоподобные ссылки требуют проверки DOI, журнала, автора и названия.'] }, article: { body: ['Что важно знать','OmniTrace разделяет текстовые признаки, происхождение файла и проверку ссылок, чтобы слабый сигнал не становился вердиктом.','Как использовать','Начните с публичного руководства или короткого предпросмотра; полный локальный рабочий стол нужен для построчных причин, импорта, истории и PDF-экспорта.'] } },
    th: { lang: 'th', nav: ['ตัวตรวจฟรี','คู่มือความเป็นส่วนตัว','ข้อจำกัด PDF','หลักฐาน DOCX','เปิดพื้นที่ทำงาน'], detectorLabel: 'ตัวอย่างข้อความ', detectorButton: 'วิเคราะห์ตัวอย่าง', detectorPlaceholder: 'วางข้อความประมาณไม่เกิน 220 คำ ตัวอย่างนี้ตรวจเฉพาะสัญญาณสถิติในเครื่อง', detectorInitial: 'ผลลัพธ์จะแสดงที่นี่ ข้อความอยู่ในเบราว์เซอร์นี้เท่านั้น', pages: { free: ['ตัวตรวจ AI ฟรี','ตัวอย่างฟรีในเบราว์เซอร์','วางข้อความสั้นเพื่อดูสัญญาณในเครื่อง โดยไม่ต้องเข้าสู่ระบบและไม่อัปโหลด'], zhFree: ['ตัวตรวจภาษาจีนตัวเต็ม','ตัวอย่างฟรีในเบราว์เซอร์','ทางเข้าสำหรับข้อความสั้นภาษาจีนตัวเต็มโดยไม่อัปโหลด'], localVsCloud: ['การตรวจ AI ในเครื่องเทียบกับการอัปโหลดคลาวด์','คู่มือความเป็นส่วนตัว','เปรียบเทียบการตรวจในเครื่องกับเครื่องมือที่ต้องอัปโหลดร่างลับ'], pdfLimits: ['ข้อจำกัดของการตรวจ AI ใน PDF','นิติวิทยาศาสตร์ไฟล์','PDF เหมาะกับการดึงข้อความที่เห็น แต่ไม่แข็งแรงพอจะพิสูจน์กระบวนการเขียน'], docxEvidence: ['ประวัติการแก้ไข DOCX เป็นหลักฐาน','หลักฐานที่มา','ไฟล์แก้ไขต้นฉบับอาจเก็บร่องรอยที่ PDF หรือข้อความคัดลอกไม่มี'], lowBurstiness: ['Burstiness ต่ำในงานเขียน AI','สัญญาณการเขียน','จังหวะประโยคที่สม่ำเสมอเกินไปอาจเป็นสัญญาณ AI แต่ต้องอ่านร่วมกับหลักฐานอื่น'], fakeCitations: ['การอ้างอิงปลอมและการตรวจเอกสารอ้างอิง','ตรวจเอกสารอ้างอิง','รายการอ้างอิงที่ดูน่าเชื่อถือยังต้องตรวจ DOI วารสาร ผู้แต่ง และชื่อเรื่อง'] }, article: { body: ['สิ่งที่ควรรู้','OmniTrace แยกสัญญาณข้อความ หลักฐานที่มาของไฟล์ และการตรวจเอกสารอ้างอิง เพื่อไม่ให้สัญญาณอ่อนหนึ่งอย่างกลายเป็นคำตัดสิน','วิธีใช้','เริ่มจากคู่มือสาธารณะหรือตัวอย่างข้อความสั้น แล้วเปิดพื้นที่ทำงานในเครื่องเมื่อจำเป็นต้องดูเหตุผลรายประโยค นำเข้าไฟล์ ประวัติ และส่งออก PDF'] } },
    ms: { lang: 'ms', nav: ['Pengesan percuma','Privasi','Had PDF','Bukti DOCX','Buka ruang kerja'], detectorLabel: 'Sampel teks', detectorButton: 'Analisis pratonton', detectorPlaceholder: 'Tampal sehingga kira-kira 220 patah perkataan. Pratonton hanya memeriksa corak statistik setempat.', detectorInitial: 'Keputusan akan muncul di sini. Teks kekal dalam pelayar ini.', pages: { free: ['Pengesan AI percuma','Pratonton percuma dalam pelayar','Tampal teks pendek dan lihat isyarat setempat tanpa log masuk atau muat naik.'], zhFree: ['Pengesan Cina Tradisional','Pratonton percuma dalam pelayar','Pintu masuk teks pendek Cina Tradisional tanpa muat naik.'], localVsCloud: ['Pengesanan AI setempat berbanding muat naik awan','Panduan privasi','Bandingkan pengesanan setempat dengan alat yang perlu memuat naik draf sulit.'], pdfLimits: ['Had pengesanan AI untuk PDF','Forensik fail','PDF berguna untuk teks kelihatan, tetapi lemah untuk membuktikan proses penulisan.'], docxEvidence: ['Sejarah suntingan DOCX sebagai bukti','Bukti sumber','Fail boleh sunting asal boleh menyimpan petunjuk yang tiada dalam PDF atau teks disalin.'], lowBurstiness: ['Burstiness rendah dalam penulisan AI','Isyarat penulisan','Ritma ayat terlalu sekata boleh menjadi isyarat AI, tetapi mesti dibaca bersama bukti lain.'], fakeCitations: ['Petikan palsu dan semakan rujukan','Semakan rujukan','Rujukan yang nampak munasabah masih perlu diperiksa DOI, jurnal, pengarang dan tajuknya.'] }, article: { body: ['Perkara penting','OmniTrace memisahkan isyarat teks, bukti sumber fail dan semakan rujukan supaya satu isyarat lemah tidak menjadi keputusan.','Cara menggunakan','Mulakan dengan panduan awam atau pratonton teks pendek, kemudian buka ruang kerja setempat penuh untuk sebab per ayat, import fail, sejarah dan eksport PDF.'] } },
    id: { lang: 'id', nav: ['Detektor gratis','Privasi','Batas PDF','Bukti DOCX','Buka ruang kerja'], detectorLabel: 'Contoh teks', detectorButton: 'Analisis pratinjau', detectorPlaceholder: 'Tempel hingga sekitar 220 kata. Pratinjau hanya memeriksa pola statistik lokal.', detectorInitial: 'Hasil akan muncul di sini. Teks tetap berada di browser ini.', pages: { free: ['Detektor AI gratis','Pratinjau gratis di browser','Tempel teks pendek dan lihat sinyal lokal tanpa login atau unggahan.'], zhFree: ['Detektor Tionghoa Tradisional','Pratinjau gratis di browser','Pintu masuk pratinjau teks pendek Tionghoa Tradisional tanpa unggahan.'], localVsCloud: ['Deteksi AI lokal vs unggahan cloud','Panduan privasi','Bandingkan deteksi lokal dengan alat yang mewajibkan unggahan draf rahasia.'], pdfLimits: ['Batas deteksi AI pada PDF','Forensik file','PDF berguna untuk teks terlihat, tetapi lemah untuk membuktikan proses penulisan.'], docxEvidence: ['Riwayat penyuntingan DOCX sebagai bukti','Bukti sumber','File asli yang dapat diedit bisa menyimpan petunjuk yang tidak ada pada PDF atau teks salinan.'], lowBurstiness: ['Burstiness rendah dalam tulisan AI','Sinyal tulisan','Ritme kalimat yang terlalu seragam bisa menjadi sinyal AI, tetapi harus dibaca bersama bukti lain.'], fakeCitations: ['Kutipan palsu dan pemeriksaan referensi','Pemeriksaan referensi','Referensi yang tampak masuk akal tetap perlu diperiksa DOI, jurnal, penulis, dan judulnya.'] }, article: { body: ['Yang perlu diketahui','OmniTrace memisahkan sinyal teks, bukti sumber file, dan pemeriksaan referensi agar satu sinyal lemah tidak menjadi vonis.','Cara menggunakan','Mulailah dari panduan publik atau pratinjau teks pendek, lalu buka ruang kerja lokal penuh untuk alasan per kalimat, impor file, riwayat, dan ekspor PDF.'] } }
  };

  function normalize(value) {
    if (!value) return 'en';
    const lower = value.replace('_', '-').toLowerCase();
    if (lower === 'zh-hant' || lower === 'zh-tw' || lower === 'zh-hk') return 'zh-Hant';
    if (lower === 'zh-hans' || lower === 'zh-cn' || lower === 'zh-sg') return 'zh-Hans';
    const base = lower.split('-')[0];
    return common[base] ? base : 'en';
  }

  function pageKey() {
    const explicit = document.body && document.body.dataset.page;
    if (explicit) return explicit;
    const path = window.location.pathname;
    if (path.includes('ai-article-detector')) return 'zhFree';
    if (path.includes('free-ai-detector')) return 'free';
    if (path.includes('local-ai-detector-vs-cloud-upload')) return 'localVsCloud';
    if (path.includes('pdf-ai-detection-limitations')) return 'pdfLimits';
    if (path.includes('docx-editing-history-ai-evidence')) return 'docxEvidence';
    if (path.includes('low-burstiness')) return 'lowBurstiness';
    if (path.includes('fake-citations')) return 'fakeCitations';
    return 'free';
  }

  function setText(selector, value) {
    const node = document.querySelector(selector);
    if (node && value) node.textContent = value;
  }

  function storedLanguage() {
    try {
      return window.localStorage.getItem('omnitrace-public-lang');
    } catch (_) {
      return null;
    }
  }

  function storeLanguage(lang) {
    const normalized = normalize(lang);
    const flutterLocale = normalized === 'zh-Hant'
      ? 'zh_Hant'
      : normalized === 'zh-Hans'
        ? 'zh_Hans'
        : normalized;
    try {
      window.localStorage.setItem('omnitrace-public-lang', normalized);
      window.localStorage.setItem('flutter.app_locale', JSON.stringify(flutterLocale));
    } catch (_) {}
  }

  function localizedPath(path, lang) {
    if (!path) return path;
    const url = new URL(path, window.location.origin);
    url.searchParams.set('lang', lang);
    return url.pathname + url.search + url.hash;
  }

  function localizedInternalHref(href, lang) {
    if (!href || href.startsWith('#') || href.startsWith('mailto:') || href.startsWith('tel:')) {
      return href;
    }
    const url = new URL(href, window.location.origin);
    if (url.origin !== window.location.origin) return href;
    url.searchParams.set('lang', normalize(lang));
    return url.pathname + url.search + url.hash;
  }

  function workspacePath(lang) {
    return '/?workspace=1&lang=' + encodeURIComponent(lang);
  }

  function renderLanguagePicker(lang) {
    const nav = document.querySelector('.tl-nav');
    if (!nav) return;
    const selected = normalize(lang);
    const existing = document.querySelector('.tl-language');
    const wrap = existing || document.createElement('div');
    wrap.className = 'tl-language';
    wrap.replaceChildren();

    const label = document.createElement('label');
    label.setAttribute('for', 'tl-public-language');
    label.textContent = languageLabels[selected] || languageLabels.en;

    const select = document.createElement('select');
    select.id = 'tl-public-language';
    select.name = 'language';
    select.setAttribute('aria-label', languageLabels[selected] || languageLabels.en);
    languages.forEach(([code, name]) => {
      const option = document.createElement('option');
      option.value = code;
      option.textContent = name;
      option.selected = code === selected;
      select.appendChild(option);
    });
    select.value = selected;
    if (select.value !== selected) select.value = 'en';
    select.addEventListener('change', () => {
      const nextLang = normalize(select.value);
      select.value = nextLang;
      storeLanguage(nextLang);
      const url = new URL(window.location.href);
      url.searchParams.set('lang', nextLang);
      window.location.href = url.pathname + url.search + url.hash;
    });

    wrap.append(label, select);
    wrap.dataset.currentLang = selected;
    if (!existing) nav.appendChild(wrap);
  }

  function detectorLandingCopy(lang) {
    const copy = {
      en: {
        actionSecondary: 'Open the other free entry',
        panels: [
          ['Free browser preview', 'Try short text without an account. Use the full OmniTrace workspace when you need long documents, sentence-level reasons, PDF export, or history.'],
          ['Multi-engine evidence', 'The full workspace separates text model, statistical, stylometry, rewriting defense, source-file, and reference-check signals so one score does not become the verdict.'],
          ['Private documents stay local', 'OmniTrace is local-first. For papers, contracts, internal drafts, and unpublished work, that privacy boundary matters as much as the score.'],
        ],
        noteTitle: 'Important',
        note: 'This free page is a short-text preview. It should not be used alone for academic, employment, or disciplinary decisions.',
        article: ['What the preview checks', 'It looks for local signals such as sentence rhythm, repeated transitions, lexical repetition, and citation-like claims that deserve follow-up.', 'When to use the full workspace', 'Use the full workspace for PDF, DOCX, ODT, plain text, OCR, reference checks, source metadata, sentence-level evidence, history, and report export.'],
        footer: 'Local-first AI content detection and document forensics.',
      },
      'zh-Hant': {
        actionSecondary: '開啟另一個免費入口',
        panels: [
          ['免費瀏覽器預覽', '不需登入即可先試短文。需要長文件、逐句理由、PDF 報告或歷史紀錄時，再使用完整 OmniTrace 工作台。'],
          ['多引擎證據', '完整工作台會拆開文字模型、統計特徵、寫作風格、改寫防禦、來源檔案與文獻核實訊號，不把單一分數當成結論。'],
          ['機密文件留在本機', 'OmniTrace 採本地優先。對論文、合約、內部草稿與未公開稿件，這條隱私界線和分數同樣重要。'],
        ],
        noteTitle: '提醒',
        note: '這個免費頁是短文預覽，不能單獨作為學術、聘僱或懲戒決策依據。',
        article: ['預覽會檢查什麼', '它會檢查句子節奏、重複轉折、詞彙重複與引用型主張等需要後續確認的本機訊號。', '何時使用完整工作台', '需要 PDF、DOCX、ODT、純文字、OCR、文獻核實、來源中繼資料、逐句證據、歷史紀錄與報告匯出時，請使用完整工作台。'],
        footer: '本地優先 AI 內容檢測與文件鑑識。',
      },
      'zh-Hans': {
        actionSecondary: '打开另一个免费入口',
        panels: [
          ['免费浏览器预览', '无需登录即可先试短文。需要长文档、逐句理由、PDF 报告或历史记录时，再使用完整 OmniTrace 工作台。'],
          ['多引擎证据', '完整工作台会拆分文字模型、统计特征、写作风格、改写防御、来源文件与文献核实信号，不把单一分数当成结论。'],
          ['机密文件留在本机', 'OmniTrace 采用本地优先。对论文、合同、内部草稿与未公开稿件，这条隐私边界和分数同样重要。'],
        ],
        noteTitle: '提醒',
        note: '这个免费页是短文预览，不能单独作为学术、聘用或纪律决策依据。',
        article: ['预览会检查什么', '它会检查句子节奏、重复转折、词汇重复与引用型主张等需要后续确认的本地信号。', '何时使用完整工作台', '需要 PDF、DOCX、ODT、纯文本、OCR、文献核实、来源元数据、逐句证据、历史记录与报告导出时，请使用完整工作台。'],
        footer: '本地优先 AI 内容检测与文件鉴识。',
      },
      ja: {
        actionSecondary: '別の無料入口を開く',
        panels: [
          ['無料ブラウザプレビュー', 'ログインなしで短文を試せます。長文、文ごとの理由、PDF レポート、履歴が必要な場合は完全な OmniTrace ワークスペースを使用してください。'],
          ['複数エンジンの証拠', '完全版ではテキストモデル、統計、文体、書き換え防御、出所ファイル、参考文献確認を分け、単一スコアを結論にしません。'],
          ['機密文書はローカルに保持', 'OmniTrace はローカル優先です。論文、契約、内部草稿、未公開原稿では、このプライバシー境界がスコアと同じくらい重要です。'],
        ],
        noteTitle: '重要',
        note: 'この無料ページは短文プレビューです。学術、雇用、懲戒上の判断に単独で使わないでください。',
        article: ['プレビューで確認すること', '文のリズム、繰り返しの接続表現、語彙反復、確認が必要な引用らしい主張などのローカル信号を見ます。', '完全版を使う場面', 'PDF、DOCX、ODT、プレーンテキスト、OCR、参考文献確認、出所メタデータ、文ごとの証拠、履歴、レポート出力が必要な場合に使います。'],
        footer: 'ローカル優先の AI コンテンツ検出と文書フォレンジック。',
      },
      ko: {
        actionSecondary: '다른 무료 입구 열기',
        panels: [
          ['무료 브라우저 미리보기', '로그인 없이 짧은 글을 먼저 시험할 수 있습니다. 긴 문서, 문장별 이유, PDF 보고서, 기록이 필요하면 전체 OmniTrace 작업 공간을 사용하세요.'],
          ['다중 엔진 증거', '전체 작업 공간은 텍스트 모델, 통계, 문체, 재작성 방어, 원본 파일, 참고문헌 검증 신호를 분리하여 단일 점수를 결론으로 만들지 않습니다.'],
          ['기밀 문서는 로컬에 유지', 'OmniTrace는 로컬 우선입니다. 논문, 계약서, 내부 초안, 미공개 원고에서는 이 개인정보 경계가 점수만큼 중요합니다.'],
        ],
        noteTitle: '중요',
        note: '이 무료 페이지는 짧은 글 미리보기입니다. 학업, 고용, 징계 판단에 단독으로 사용하지 마세요.',
        article: ['미리보기가 확인하는 것', '문장 리듬, 반복 전환 표현, 어휘 반복, 후속 확인이 필요한 인용형 주장 같은 로컬 신호를 봅니다.', '전체 작업 공간이 필요한 때', 'PDF, DOCX, ODT, 일반 텍스트, OCR, 참고문헌 검증, 출처 메타데이터, 문장별 증거, 기록, 보고서 내보내기가 필요할 때 사용합니다.'],
        footer: '로컬 우선 AI 콘텐츠 감지 및 문서 포렌식.',
      },
      th: {
        actionSecondary: 'เปิดทางเข้าฟรีอีกหน้า',
        panels: [
          ['ตัวอย่างฟรีในเบราว์เซอร์', 'ลองข้อความสั้นได้โดยไม่ต้องเข้าสู่ระบบ หากต้องใช้เอกสารยาว เหตุผลรายประโยค รายงาน PDF หรือประวัติ ให้ใช้พื้นที่ทำงาน OmniTrace แบบเต็ม'],
          ['หลักฐานหลายเครื่องยนต์', 'พื้นที่ทำงานเต็มแยกโมเดลข้อความ สถิติ สไตล์การเขียน การป้องกันการเขียนใหม่ ไฟล์ต้นทาง และการตรวจอ้างอิง จึงไม่ให้คะแนนเดียวกลายเป็นข้อสรุป'],
          ['เอกสารลับอยู่ในเครื่อง', 'OmniTrace ให้ความสำคัญกับการประมวลผลในเครื่อง สำหรับวิทยานิพนธ์ สัญญา ร่างภายใน และงานที่ยังไม่เผยแพร่ ขอบเขตความเป็นส่วนตัวนี้สำคัญเท่าคะแนน'],
        ],
        noteTitle: 'สำคัญ',
        note: 'หน้านี้เป็นตัวอย่างข้อความสั้นฟรี ไม่ควรใช้เดี่ยว ๆ เพื่อตัดสินทางวิชาการ การจ้างงาน หรือวินัย',
        article: ['ตัวอย่างตรวจอะไร', 'ตรวจสัญญาณในเครื่อง เช่น จังหวะประโยค คำเชื่อมซ้ำ การซ้ำคำ และข้ออ้างคล้ายการอ้างอิงที่ควรตรวจต่อ', 'เมื่อใดควรใช้พื้นที่ทำงานเต็ม', 'ใช้เมื่อจำเป็นต้องตรวจ PDF, DOCX, ODT, ข้อความล้วน, OCR, เอกสารอ้างอิง เมทาดาทาแหล่งที่มา หลักฐานรายประโยค ประวัติ และส่งออกรายงาน'],
        footer: 'การตรวจเนื้อหา AI และนิติวิทยาศาสตร์เอกสารแบบเน้นในเครื่อง',
      },
      ms: {
        actionSecondary: 'Buka pintu masuk percuma lain',
        panels: [
          ['Pratonton percuma dalam pelayar', 'Cuba teks pendek tanpa log masuk. Gunakan ruang kerja OmniTrace penuh apabila anda perlukan dokumen panjang, sebab per ayat, laporan PDF atau sejarah.'],
          ['Bukti berbilang enjin', 'Ruang kerja penuh memisahkan model teks, statistik, gaya, pertahanan tulis semula, fail sumber dan semakan rujukan supaya satu skor tidak menjadi keputusan.'],
          ['Dokumen sulit kekal setempat', 'OmniTrace mengutamakan pemprosesan setempat. Untuk tesis, kontrak, draf dalaman dan manuskrip belum diterbitkan, sempadan privasi ini sama penting dengan skor.'],
        ],
        noteTitle: 'Penting',
        note: 'Halaman percuma ini ialah pratonton teks pendek. Jangan gunakannya secara tunggal untuk keputusan akademik, pekerjaan atau disiplin.',
        article: ['Perkara yang diperiksa', 'Ia memeriksa isyarat setempat seperti ritma ayat, peralihan berulang, pengulangan leksikal dan dakwaan seperti petikan yang perlu disusuli.', 'Bila menggunakan ruang kerja penuh', 'Gunakan untuk PDF, DOCX, ODT, teks biasa, OCR, semakan rujukan, metadata sumber, bukti per ayat, sejarah dan eksport laporan.'],
        footer: 'Pengesanan kandungan AI dan forensik dokumen yang mengutamakan setempat.',
      },
      es: {
        actionSecondary: 'Abrir otra entrada gratuita',
        panels: [
          ['Vista previa gratuita en el navegador', 'Prueba texto breve sin iniciar sesión. Usa el área completa de OmniTrace cuando necesites documentos largos, razones por frase, informe PDF o historial.'],
          ['Evidencia de varios motores', 'El área completa separa modelo textual, estadísticas, estilo, defensa contra reescritura, archivo fuente y referencias para que una puntuación no sea el veredicto.'],
          ['Los documentos confidenciales quedan locales', 'OmniTrace prioriza lo local. Para tesis, contratos, borradores internos y manuscritos inéditos, ese límite de privacidad importa tanto como la puntuación.'],
        ],
        noteTitle: 'Importante',
        note: 'Esta página gratuita es una vista previa de texto breve. No debe usarse sola para decisiones académicas, laborales o disciplinarias.',
        article: ['Qué revisa la vista previa', 'Revisa señales locales como ritmo de frases, transiciones repetidas, repetición léxica y afirmaciones tipo cita que requieren seguimiento.', 'Cuándo usar el área completa', 'Úsala para PDF, DOCX, ODT, texto plano, OCR, revisión de referencias, metadatos de origen, evidencia por frase, historial y exportación de informes.'],
        footer: 'Detección de contenido IA y análisis documental local primero.',
      },
      id: {
        actionSecondary: 'Buka pintu gratis lain',
        panels: [
          ['Pratinjau gratis di browser', 'Coba teks pendek tanpa login. Gunakan ruang kerja OmniTrace penuh saat perlu dokumen panjang, alasan per kalimat, laporan PDF, atau riwayat.'],
          ['Bukti multi-mesin', 'Ruang kerja penuh memisahkan model teks, statistik, gaya, pertahanan penulisan ulang, file sumber, dan pemeriksaan referensi agar satu skor tidak menjadi vonis.'],
          ['Dokumen rahasia tetap lokal', 'OmniTrace mengutamakan pemrosesan lokal. Untuk tesis, kontrak, draf internal, dan naskah belum terbit, batas privasi ini sama pentingnya dengan skor.'],
        ],
        noteTitle: 'Penting',
        note: 'Halaman gratis ini adalah pratinjau teks pendek. Jangan gunakan sendirian untuk keputusan akademik, pekerjaan, atau disipliner.',
        article: ['Yang diperiksa pratinjau', 'Pratinjau memeriksa sinyal lokal seperti ritme kalimat, transisi berulang, pengulangan leksikal, dan klaim mirip kutipan yang perlu ditindaklanjuti.', 'Kapan memakai ruang kerja penuh', 'Gunakan untuk PDF, DOCX, ODT, teks biasa, OCR, pemeriksaan referensi, metadata sumber, bukti per kalimat, riwayat, dan ekspor laporan.'],
        footer: 'Deteksi konten AI dan forensik dokumen yang mengutamakan lokal.',
      },
      ru: {
        actionSecondary: 'Открыть другой бесплатный вход',
        panels: [
          ['Бесплатный предпросмотр в браузере', 'Проверьте короткий текст без входа. Полная рабочая область OmniTrace нужна для длинных документов, построчных причин, PDF-отчета или истории.'],
          ['Доказательства нескольких модулей', 'Полная рабочая область разделяет текстовую модель, статистику, стиль, защиту от переписывания, исходный файл и проверку ссылок, чтобы один балл не становился вердиктом.'],
          ['Конфиденциальные документы остаются локально', 'OmniTrace работает локально прежде всего. Для диссертаций, договоров, внутренних черновиков и неопубликованных текстов эта граница приватности важна не меньше оценки.'],
        ],
        noteTitle: 'Важно',
        note: 'Эта бесплатная страница является предпросмотром короткого текста. Не используйте ее отдельно для академических, трудовых или дисциплинарных решений.',
        article: ['Что проверяет предпросмотр', 'Он проверяет локальные признаки: ритм предложений, повторяющиеся переходы, лексические повторы и похожие на цитаты утверждения, требующие проверки.', 'Когда использовать полную рабочую область', 'Используйте ее для PDF, DOCX, ODT, обычного текста, OCR, проверки ссылок, метаданных источника, построчных доказательств, истории и экспорта отчетов.'],
        footer: 'Локальная AI-проверка контента и экспертиза документов.',
      },
      de: {
        actionSecondary: 'Anderen kostenlosen Einstieg öffnen',
        panels: [
          ['Kostenlose Browser-Vorschau', 'Testen Sie kurzen Text ohne Anmeldung. Nutzen Sie den vollständigen OmniTrace-Arbeitsbereich für lange Dokumente, Satzbelege, PDF-Berichte oder Verlauf.'],
          ['Mehrere Belegmodule', 'Der vollständige Arbeitsbereich trennt Textmodell, Statistik, Stilometrie, Umschreibschutz, Quelldatei und Referenzprüfung, damit ein einzelner Wert kein Urteil wird.'],
          ['Vertrauliche Dokumente bleiben lokal', 'OmniTrace ist lokal zuerst. Für Abschlussarbeiten, Verträge, interne Entwürfe und unveröffentlichte Manuskripte ist diese Datenschutzgrenze so wichtig wie die Punktzahl.'],
        ],
        noteTitle: 'Wichtig',
        note: 'Diese kostenlose Seite ist eine Kurztext-Vorschau. Sie sollte nicht allein für akademische, arbeitsrechtliche oder disziplinarische Entscheidungen verwendet werden.',
        article: ['Was die Vorschau prüft', 'Sie prüft lokale Signale wie Satzrhythmus, wiederholte Übergänge, Wortwiederholungen und zitationsartige Aussagen, die nachverfolgt werden sollten.', 'Wann der vollständige Arbeitsbereich sinnvoll ist', 'Nutzen Sie ihn für PDF, DOCX, ODT, Klartext, OCR, Referenzprüfung, Quellenmetadaten, Satzbelege, Verlauf und Berichtsexport.'],
        footer: 'Lokale KI-Inhaltserkennung und Dokumentforensik.',
      },
      fr: {
        actionSecondary: 'Ouvrir une autre entrée gratuite',
        panels: [
          ['Aperçu gratuit dans le navigateur', 'Essayez un texte court sans compte. Utilisez l’espace OmniTrace complet pour les longs documents, les raisons par phrase, le rapport PDF ou l’historique.'],
          ['Indices multi-moteurs', 'L’espace complet sépare modèle texte, statistiques, stylométrie, défense contre la réécriture, fichier source et vérification des références afin qu’un seul score ne devienne pas un verdict.'],
          ['Les documents confidentiels restent locaux', 'OmniTrace privilégie le local. Pour thèses, contrats, brouillons internes et manuscrits non publiés, cette limite de confidentialité compte autant que le score.'],
        ],
        noteTitle: 'Important',
        note: 'Cette page gratuite est un aperçu de texte court. Elle ne doit pas être utilisée seule pour des décisions académiques, professionnelles ou disciplinaires.',
        article: ['Ce que vérifie l’aperçu', 'Il examine des signaux locaux comme le rythme des phrases, les transitions répétées, la répétition lexicale et les affirmations proches de citations à vérifier.', 'Quand utiliser l’espace complet', 'Utilisez-le pour PDF, DOCX, ODT, texte brut, OCR, vérification des références, métadonnées de source, preuves par phrase, historique et export de rapports.'],
        footer: 'Détection de contenu IA et analyse documentaire locale.',
      },
      pt: {
        actionSecondary: 'Abrir outra entrada gratuita',
        panels: [
          ['Prévia gratuita no navegador', 'Teste texto curto sem login. Use o workspace completo do OmniTrace quando precisar de documentos longos, motivos por frase, relatório PDF ou histórico.'],
          ['Evidência de vários motores', 'O workspace completo separa modelo textual, estatísticas, estilo, defesa contra reescrita, arquivo fonte e verificação de referências para que uma pontuação não vire veredito.'],
          ['Documentos confidenciais ficam locais', 'OmniTrace prioriza o local. Para teses, contratos, rascunhos internos e manuscritos inéditos, essa fronteira de privacidade importa tanto quanto a pontuação.'],
        ],
        noteTitle: 'Importante',
        note: 'Esta página gratuita é uma prévia de texto curto. Não deve ser usada sozinha para decisões acadêmicas, profissionais ou disciplinares.',
        article: ['O que a prévia verifica', 'Ela verifica sinais locais como ritmo das frases, transições repetidas, repetição lexical e afirmações parecidas com citações que merecem acompanhamento.', 'Quando usar o workspace completo', 'Use para PDF, DOCX, ODT, texto simples, OCR, verificação de referências, metadados de origem, evidência por frase, histórico e exportação de relatórios.'],
        footer: 'Detecção de conteúdo IA e forense documental local-first.',
      },
    };
    return copy[lang] || copy.en;
  }

  function articleFooter(lang) {
    const footers = {
      en: 'Local-first AI content detection and document forensics.',
      'zh-Hant': '本地優先 AI 內容檢測與文件鑑識。',
      'zh-Hans': '本地优先 AI 内容检测与文件鉴识。',
      ja: 'ローカル優先の AI コンテンツ検出と文書フォレンジック。',
      ko: '로컬 우선 AI 콘텐츠 감지 및 문서 포렌식.',
      th: 'การตรวจเนื้อหา AI และนิติวิทยาศาสตร์เอกสารแบบเน้นในเครื่อง',
      ms: 'Pengesanan kandungan AI dan forensik dokumen yang mengutamakan setempat.',
      es: 'Detección de contenido IA y análisis documental local primero.',
      id: 'Deteksi konten AI dan forensik dokumen yang mengutamakan lokal.',
      ru: 'Локальная AI-проверка контента и экспертиза документов.',
      de: 'Lokale KI-Inhaltserkennung und Dokumentforensik.',
      fr: 'Détection de contenu IA et analyse documentaire locale.',
      pt: 'Detecção de conteúdo IA e forense documental local-first.',
    };
    return footers[lang] || footers.en;
  }

  function translateDetectorLanding(key, pack, page) {
    if (key !== 'free' && key !== 'zhFree') return;
    const body = detectorLandingCopy(pack.lang);
    const actions = document.querySelectorAll('.tl-actions a');
    if (actions[0]) actions[0].textContent = pack.nav[4];
    if (actions[1]) actions[1].textContent = body.actionSecondary;
    setText('#detector-title', page[0]);

    const panelTitles = document.querySelectorAll('.tl-panel h3');
    const panelBodies = document.querySelectorAll('.tl-panel p');
    body.panels.forEach((panel, index) => {
      if (panelTitles[index]) panelTitles[index].textContent = panel[0];
      if (panelBodies[index]) panelBodies[index].textContent = panel[1];
    });

    const note = document.querySelector('.tl-note');
    if (note) {
      note.replaceChildren();
      const strong = document.createElement('strong');
      strong.textContent = body.noteTitle + ':';
      note.append(strong, ' ' + body.note);
    }

    const article = document.querySelector('section.tl-article');
    if (article) {
      article.innerHTML = '';
      const h2a = document.createElement('h2');
      h2a.textContent = body.article[0];
      const p1 = document.createElement('p');
      p1.textContent = body.article[1];
      const h2b = document.createElement('h2');
      h2b.textContent = body.article[2];
      const p2 = document.createElement('p');
      p2.textContent = body.article[3];
      article.append(h2a, p1, h2b, p2);
    }

    const footer = document.querySelector('.tl-footer');
    if (footer) footer.textContent = '© 2026 OmniTrace. ' + body.footer;
  }

  const params = new URLSearchParams(window.location.search || '');
  const selectedLang = normalize(
    params.get('lang') ||
      storedLanguage() ||
      navigator.language ||
      document.documentElement.lang,
  );
  const pack = common[selectedLang] || common.en;
  const key = pageKey();
  const page = pack.pages[key] || common.en.pages[key];
  if (!page) return;

  document.documentElement.lang = pack.lang;
  document.title = page[0] + ' | OmniTrace';
  const description = document.querySelector('meta[name="description"]');
  if (description) description.setAttribute('content', page[2]);
  const ogTitle = document.querySelector('meta[property="og:title"]');
  if (ogTitle) ogTitle.setAttribute('content', page[0]);
  const ogDescription = document.querySelector('meta[property="og:description"]');
  if (ogDescription) ogDescription.setAttribute('content', page[2]);
  const nav = document.querySelector('.tl-nav');
  if (nav) nav.setAttribute('aria-label', navLabels[pack.lang] || navLabels.en);

  setText('h1', page[0]);
  setText('.tl-kicker', page[1]);
  setText('.tl-lead', page[2]);
  setText('label[for="sample-text"]', pack.detectorLabel);
  setText('[data-detector-run]', pack.detectorButton);
  const input = document.querySelector('[data-detector-input]');
  if (input) input.setAttribute('placeholder', pack.detectorPlaceholder);
  const result = document.querySelector('[data-detector-output] p');
  if (result) result.textContent = pack.detectorInitial;
  window.truthLensPublicLang = pack.lang;

  const navLinks = document.querySelectorAll('.tl-links a');
  navLinks.forEach((link, index) => {
    if (pack.nav[index]) link.textContent = pack.nav[index];
    const href = link.getAttribute('href');
    if (href === '/') {
      link.setAttribute('href', workspacePath(pack.lang));
    } else if (href && href.startsWith('/')) {
      link.setAttribute('href', localizedPath(href, pack.lang));
    }
    link.addEventListener('click', () => storeLanguage(pack.lang), { once: true });
  });
  const brand = document.querySelector('.tl-brand');
  if (brand) brand.setAttribute('href', '/?lang=' + encodeURIComponent(pack.lang));
  document.querySelectorAll('.tl-actions a, main a').forEach((link) => {
    const href = link.getAttribute('href');
    if (link.classList.contains('tl-brand')) return;
    if (href === '/') {
      link.setAttribute('href', workspacePath(pack.lang));
    } else if (href && href.startsWith('/')) {
      link.setAttribute('href', localizedPath(href, pack.lang));
    }
    link.addEventListener('click', () => storeLanguage(pack.lang), { once: true });
  });
  renderLanguagePicker(pack.lang);
  storeLanguage(pack.lang);
  translateDetectorLanding(key, pack, page);

  const article = document.querySelector('main.tl-article');
  if (article && key !== 'free' && key !== 'zhFree') {
    const body = pack.article.body;
    article.innerHTML = '';
    const kicker = document.createElement('p');
    kicker.className = 'tl-kicker';
    kicker.textContent = page[1];
    const h1 = document.createElement('h1');
    h1.textContent = page[0];
    const lead = document.createElement('p');
    lead.className = 'tl-lead';
    lead.textContent = page[2];
    const h2a = document.createElement('h2');
    h2a.textContent = body[0];
    const p1 = document.createElement('p');
    p1.textContent = body[1];
    const h2b = document.createElement('h2');
    h2b.textContent = body[2];
    const p2 = document.createElement('p');
    p2.textContent = body[3];
    article.append(kicker, h1, lead, h2a, p1, h2b, p2);
    const footer = document.querySelector('.tl-footer');
    if (footer) footer.textContent = '© 2026 OmniTrace. ' + articleFooter(pack.lang);
  }

  document.addEventListener('click', (event) => {
    const link = event.target.closest && event.target.closest('a[href]');
    if (!link) return;
    const lang = normalize(
      document.querySelector('.tl-language')?.dataset.currentLang ||
        window.truthLensPublicLang ||
        document.documentElement.lang ||
        selectedLang,
    );
    storeLanguage(lang);
    const href = link.getAttribute('href');
    const localized = localizedInternalHref(href, lang);
    if (localized && localized !== href) {
      event.preventDefault();
      window.location.href = localized;
    }
  }, true);
})();
