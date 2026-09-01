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

  const common = {
    en: {
      lang: 'en', nav: ['Free detector', 'Privacy guide', 'PDF limits', 'DOCX evidence', 'Open workspace'],
      detectorLabel: 'Text sample', detectorButton: 'Analyze preview', detectorPlaceholder: 'Paste up to about 220 words. The preview checks local statistical patterns only.', detectorInitial: 'Results will appear here. Your text stays in this browser.',
      pages: {
        free: ['Free AI Detector', 'Free browser preview', 'Paste a short writing sample and get instant local signals before opening the full TruthLens workspace. No login and no upload are required.'],
        zhFree: ['Traditional Chinese AI Detector', 'Free browser preview', 'Use the same no-upload short text preview with Traditional Chinese entry text.'],
        localVsCloud: ['Local AI Detector vs Cloud Upload Tools', 'Privacy guide', 'Compare local AI detection with tools that require uploading confidential drafts.'],
        pdfLimits: ['PDF AI Detection Limitations', 'File forensics', 'PDF files are useful for visible text extraction, but weak for proving how a document was written.'],
        docxEvidence: ['DOCX Editing History as AI Evidence', 'Source evidence', 'Original editable files can preserve drafting clues that a pasted PDF or copied text cannot show.'],
        lowBurstiness: ['Low Burstiness in AI Writing', 'Writing signal', 'Sentence rhythm can be an AI signal, but it must be interpreted with other evidence.'],
        fakeCitations: ['Fake Citations and Reference Checks', 'Reference checks', 'Plausible references still need DOI, journal, author, and title verification.']
      },
      article: {
        body: ['What to know', 'TruthLens separates text signals, file-source evidence, and reference verification so that one weak signal does not become a verdict.', 'How to use it', 'Start with the public guide or short-text preview, then open the full local workspace when you need sentence-level reasons, file import, history, and PDF export.']
      }
    },
    'zh-Hant': {
      lang: 'zh-Hant', nav: ['免費檢測器', '隱私指南', 'PDF 限制', 'DOCX 證據', '開啟工作台'],
      detectorLabel: '文字樣本', detectorButton: '開始預覽', detectorPlaceholder: '建議貼上 220 字以內。預覽只檢查輕量本機統計特徵。', detectorInitial: '結果會顯示在這裡。文字只留在這個瀏覽器。',
      pages: {
        free: ['免費 AI 文章檢測器', '免費瀏覽器預覽', '貼上一小段文章，先在瀏覽器本機取得初步訊號；不需登入，也不會上傳文字。'],
        zhFree: ['免費 AI 文章檢測器', '免費瀏覽器預覽', '這是繁體中文入口，提供不需上傳的短文初步檢測。'],
        localVsCloud: ['本地 AI 檢測與雲端上傳比較', '隱私指南', '比較本地檢測與需要上傳機密草稿的雲端工具。'],
        pdfLimits: ['PDF AI 檢測限制', '文件鑑識', 'PDF 適合抽取可見文字，但通常不適合證明文件實際如何被撰寫。'],
        docxEvidence: ['DOCX 編輯紀錄證據', '來源證據', '原始可編輯檔可能保留 PDF 或複製文字看不到的撰寫過程線索。'],
        lowBurstiness: ['AI 寫作的低突發性', '寫作訊號', '句長和節奏過度整齊可能是 AI 訊號，但必須和其他證據一起判讀。'],
        fakeCitations: ['假文獻與引用核實', '引用檢查', '看起來合理的參考文獻仍需核對 DOI、期刊、作者與篇名。']
      },
      article: { body: ['你需要知道的事', 'TruthLens 會拆開文字訊號、文件來源證據與文獻核實，避免把單一薄弱訊號誤當成結論。', '如何使用', '可先閱讀公開指南或試用短文預覽；需要逐句理由、文件匯入、歷史紀錄與 PDF 匯出時，再開啟完整本地工作台。'] }
    },
    'zh-Hans': {
      lang: 'zh-Hans', nav: ['免费检测器', '隐私指南', 'PDF 限制', 'DOCX 证据', '打开工作台'], detectorLabel: '文字样本', detectorButton: '开始预览', detectorPlaceholder: '建议粘贴 220 字以内。预览只检查轻量本地统计特征。', detectorInitial: '结果会显示在这里。文字只留在这个浏览器。',
      pages: { free: ['免费 AI 文章检测器','免费浏览器预览','粘贴一小段文章，在浏览器本地取得初步信号；无需登录，也不会上传文字。'], zhFree: ['繁体中文 AI 检测器','免费浏览器预览','这是繁体中文入口，提供无需上传的短文初步检测。'], localVsCloud: ['本地 AI 检测与云端上传比较','隐私指南','比较本地检测与需要上传机密草稿的云端工具。'], pdfLimits: ['PDF AI 检测限制','文件鉴识','PDF 适合提取可见文字，但通常不适合证明文件实际如何被撰写。'], docxEvidence: ['DOCX 编辑记录证据','来源证据','原始可编辑文件可能保留 PDF 或复制文字看不到的写作过程线索。'], lowBurstiness: ['AI 写作的低突发性','写作信号','句长和节奏过度整齐可能是 AI 信号，但必须和其他证据一起解读。'], fakeCitations: ['虚假文献与引用核实','引用检查','看似合理的参考文献仍需核对 DOI、期刊、作者与题名。'] }, article: { body: ['需要了解的事','TruthLens 会拆分文字信号、文件来源证据与文献核实，避免把单一薄弱信号误当成结论。','如何使用','可先阅读公开指南或试用短文预览；需要逐句理由、文件导入、历史记录与 PDF 导出时，再打开完整本地工作台。'] }
    },
    ja: { lang: 'ja', nav: ['無料検出', 'プライバシー', 'PDF の限界', 'DOCX 証拠', 'ワークスペースを開く'], detectorLabel: 'テキストサンプル', detectorButton: 'プレビュー分析', detectorPlaceholder: '約 220 語以内を貼り付けてください。軽量なローカル統計だけを確認します。', detectorInitial: '結果はここに表示されます。テキストはこのブラウザ内に残ります。', pages: { free: ['無料 AI 文章検出ツール','無料ブラウザプレビュー','短い文章を貼り付けるだけで、アップロードなしにローカルの初期シグナルを確認できます。'], zhFree: ['繁体字中国語 AI 検出ツール','無料ブラウザプレビュー','繁体字中国語向けの短文プレビュー入口です。'], localVsCloud: ['ローカル AI 検出とクラウドアップロードの比較','プライバシーガイド','機密草稿をアップロードするツールとローカル検出を比較します。'], pdfLimits: ['PDF の AI 検出の限界','ファイル鑑識','PDF は表示テキストの抽出には有用ですが、執筆過程の証明には弱い形式です。'], docxEvidence: ['DOCX 編集履歴の証拠','出所証拠','編集可能な元ファイルには、PDF やコピー文では見えない執筆履歴が残る場合があります。'], lowBurstiness: ['AI 文章における低バースト性','文章シグナル','文の長さやリズムが整いすぎる場合、AI の兆候になり得ますが単独では判断できません。'], fakeCitations: ['偽引用と参考文献チェック','参考文献チェック','もっともらしい参考文献でも DOI、雑誌、著者、題名の確認が必要です。'] }, article: { body: ['知っておくこと','TruthLens は文章シグナル、ファイル出所、参考文献確認を分けて表示し、弱いシグナルを結論にしません。','使い方','公開ガイドや短文プレビューから始め、逐文理由、ファイル取り込み、履歴、PDF 出力が必要なときに完全なローカルワークスペースを開きます。'] } },
    ko: { lang: 'ko', nav: ['무료 감지기','개인정보 가이드','PDF 한계','DOCX 증거','작업 공간 열기'], detectorLabel: '텍스트 샘플', detectorButton: '미리 분석', detectorPlaceholder: '약 220단어 이내를 붙여넣으세요. 가벼운 로컬 통계만 확인합니다.', detectorInitial: '결과가 여기에 표시됩니다. 텍스트는 이 브라우저에만 남습니다.', pages: { free: ['무료 AI 글 감지기','무료 브라우저 미리보기','짧은 글을 붙여넣고 업로드 없이 로컬 초기 신호를 확인합니다.'], zhFree: ['번체 중국어 AI 감지기','무료 브라우저 미리보기','번체 중국어용 짧은 글 미리보기 입구입니다.'], localVsCloud: ['로컬 AI 감지와 클라우드 업로드 비교','개인정보 가이드','기밀 초안을 업로드해야 하는 도구와 로컬 감지를 비교합니다.'], pdfLimits: ['PDF AI 감지의 한계','파일 포렌식','PDF는 보이는 텍스트 추출에는 유용하지만 작성 과정을 증명하기에는 약합니다.'], docxEvidence: ['DOCX 편집 기록 증거','출처 증거','원본 편집 파일은 PDF나 복사 텍스트에 없는 작성 과정 단서를 보존할 수 있습니다.'], lowBurstiness: ['AI 글쓰기의 낮은 버스티니스','쓰기 신호','문장 길이와 리듬이 지나치게 일정하면 AI 신호일 수 있지만 단독 판단은 위험합니다.'], fakeCitations: ['가짜 인용 및 참고문헌 확인','참고문헌 확인','그럴듯한 참고문헌도 DOI, 저널, 저자, 제목 확인이 필요합니다.'] }, article: { body: ['알아둘 점','TruthLens는 텍스트 신호, 파일 출처 증거, 참고문헌 검증을 분리해 약한 신호 하나가 결론이 되지 않도록 합니다.','사용 방법','공개 가이드나 짧은 글 미리보기로 시작하고, 문장별 이유, 파일 가져오기, 기록, PDF 내보내기가 필요할 때 전체 로컬 작업 공간을 엽니다.'] } },
    de: { lang: 'de', nav: ['Kostenloser Detektor','Datenschutz','PDF-Grenzen','DOCX-Nachweis','Arbeitsbereich öffnen'], detectorLabel: 'Textprobe', detectorButton: 'Vorschau analysieren', detectorPlaceholder: 'Fügen Sie bis etwa 220 Wörter ein. Die Vorschau prüft nur lokale statistische Muster.', detectorInitial: 'Ergebnisse erscheinen hier. Ihr Text bleibt in diesem Browser.', pages: { free: ['Kostenloser KI-Textdetektor','Kostenlose Browser-Vorschau','Fügen Sie einen kurzen Text ein und prüfen Sie lokale Signale ohne Login und ohne Upload.'], zhFree: ['Detektor für traditionelles Chinesisch','Kostenlose Browser-Vorschau','Kurztext-Vorschau für traditionelles Chinesisch ohne Upload.'], localVsCloud: ['Lokale KI-Erkennung statt Cloud-Upload','Datenschutzleitfaden','Vergleichen Sie lokale Erkennung mit Diensten, die vertrauliche Entwürfe hochladen müssen.'], pdfLimits: ['Grenzen der KI-Erkennung bei PDF','Dateiforensik','PDFs eignen sich für sichtbaren Text, aber kaum als Nachweis des Schreibprozesses.'], docxEvidence: ['DOCX-Bearbeitungshistorie als Nachweis','Quelldatei-Nachweis','Bearbeitbare Originaldateien können Entstehungshinweise enthalten, die PDF oder kopierter Text nicht zeigen.'], lowBurstiness: ['Niedrige Burstiness in KI-Texten','Schreibsignal','Zu gleichmäßige Satzlängen und Rhythmen können ein KI-Signal sein, müssen aber mit weiteren Belegen gelesen werden.'], fakeCitations: ['Falsche Zitate und Quellenprüfung','Referenzprüfung','Plausible Literaturangaben brauchen DOI-, Journal-, Autoren- und Titelprüfung.'] }, article: { body: ['Wichtig zu wissen','TruthLens trennt Textsignale, Dateiquellen und Referenzprüfung, damit ein schwaches Signal nicht zum Urteil wird.','So nutzen Sie es','Beginnen Sie mit dem öffentlichen Leitfaden oder der Kurztext-Vorschau und öffnen Sie den lokalen Arbeitsbereich für Satzbelege, Dateiimport, Verlauf und PDF-Export.'] } },
    fr: { lang: 'fr', nav: ['Détecteur gratuit','Confidentialité','Limites PDF','Indice DOCX','Ouvrir l’espace'], detectorLabel: 'Extrait de texte', detectorButton: 'Analyser l’aperçu', detectorPlaceholder: 'Collez jusqu’à environ 220 mots. L’aperçu vérifie seulement des signaux statistiques locaux.', detectorInitial: 'Les résultats apparaîtront ici. Votre texte reste dans ce navigateur.', pages: { free: ['Détecteur IA gratuit','Aperçu gratuit dans le navigateur','Collez un court texte et obtenez des signaux locaux sans compte ni envoi.'], zhFree: ['Détecteur chinois traditionnel','Aperçu gratuit dans le navigateur','Entrée de prévisualisation pour courts textes en chinois traditionnel, sans envoi.'], localVsCloud: ['Détection IA locale ou envoi vers le cloud','Guide de confidentialité','Comparez la détection locale avec les outils qui exigent l’envoi de brouillons confidentiels.'], pdfLimits: ['Limites de la détection IA sur PDF','Analyse de fichier','Le PDF aide à extraire le texte visible, mais prouve mal le processus d’écriture.'], docxEvidence: ['Historique DOCX comme indice','Indice de source','Un fichier éditable original peut conserver des traces invisibles dans un PDF ou un texte copié.'], lowBurstiness: ['Faible burstiness dans l’écriture IA','Signal d’écriture','Un rythme trop régulier peut être un signal IA, mais doit être lu avec d’autres indices.'], fakeCitations: ['Fausses citations et vérification des références','Vérification bibliographique','Une référence plausible doit quand même être vérifiée par DOI, revue, auteur et titre.'] }, article: { body: ['À savoir','TruthLens sépare signaux textuels, origine du fichier et vérification bibliographique afin qu’un indice faible ne devienne pas un verdict.','Comment l’utiliser','Commencez par le guide public ou l’aperçu de texte court, puis ouvrez l’espace local complet pour les raisons phrase par phrase, l’import de fichiers, l’historique et l’export PDF.'] } },
    es: { lang: 'es', nav: ['Detector gratuito','Privacidad','Límites PDF','Evidencia DOCX','Abrir área'], detectorLabel: 'Muestra de texto', detectorButton: 'Analizar vista previa', detectorPlaceholder: 'Pega hasta unas 220 palabras. La vista previa solo revisa señales estadísticas locales.', detectorInitial: 'Los resultados aparecerán aquí. El texto queda en este navegador.', pages: { free: ['Detector gratuito de IA','Vista previa gratuita en el navegador','Pega un texto breve y obtén señales locales sin cuenta ni subida.'], zhFree: ['Detector de chino tradicional','Vista previa gratuita en el navegador','Entrada para textos breves en chino tradicional sin subir contenido.'], localVsCloud: ['Detección local de IA frente a subida a la nube','Guía de privacidad','Compara la detección local con herramientas que exigen subir borradores confidenciales.'], pdfLimits: ['Límites de la detección de IA en PDF','Análisis forense de archivos','El PDF sirve para extraer texto visible, pero es débil para probar cómo se escribió un documento.'], docxEvidence: ['Historial de edición DOCX como evidencia','Evidencia de origen','Un archivo editable original puede conservar pistas que un PDF o texto copiado no muestra.'], lowBurstiness: ['Baja burstiness en escritura de IA','Señal de escritura','Un ritmo demasiado regular puede ser una señal de IA, pero debe leerse con otros indicios.'], fakeCitations: ['Citas falsas y verificación de referencias','Verificación bibliográfica','Una referencia plausible aún necesita comprobar DOI, revista, autor y título.'] }, article: { body: ['Qué saber','TruthLens separa señales de texto, origen del archivo y verificación bibliográfica para que una señal débil no se convierta en veredicto.','Cómo usarlo','Empieza con la guía pública o la vista previa breve; abre el espacio local completo para razones por frase, importación, historial y exportación PDF.'] } },
    pt: { lang: 'pt', nav: ['Detector gratuito','Privacidade','Limites PDF','Evidência DOCX','Abrir workspace'], detectorLabel: 'Amostra de texto', detectorButton: 'Analisar prévia', detectorPlaceholder: 'Cole até cerca de 220 palavras. A prévia verifica apenas sinais estatísticos locais.', detectorInitial: 'Os resultados aparecerão aqui. O texto fica neste navegador.', pages: { free: ['Detector gratuito de IA','Prévia gratuita no navegador','Cole um texto curto e veja sinais locais sem conta e sem envio.'], zhFree: ['Detector de chinês tradicional','Prévia gratuita no navegador','Entrada para textos curtos em chinês tradicional sem upload.'], localVsCloud: ['Detecção local de IA versus envio à nuvem','Guia de privacidade','Compare a detecção local com ferramentas que exigem enviar rascunhos confidenciais.'], pdfLimits: ['Limites da detecção de IA em PDF','Forense de arquivos','PDF ajuda a extrair texto visível, mas é fraco para provar como um documento foi escrito.'], docxEvidence: ['Histórico de edição DOCX como evidência','Evidência de origem','Arquivos editáveis originais podem guardar pistas que PDF ou texto copiado não mostram.'], lowBurstiness: ['Baixa burstiness em escrita de IA','Sinal de escrita','Ritmo regular demais pode ser sinal de IA, mas precisa ser lido com outras evidências.'], fakeCitations: ['Citações falsas e verificação de referências','Verificação bibliográfica','Referências plausíveis ainda exigem checagem de DOI, periódico, autor e título.'] }, article: { body: ['O que saber','TruthLens separa sinais do texto, origem do arquivo e verificação bibliográfica para que um sinal fraco não vire veredito.','Como usar','Comece pelo guia público ou pela prévia curta; abra o workspace local completo para razões por frase, importação, histórico e exportação PDF.'] } },
    ru: { lang: 'ru', nav: ['Бесплатный детектор','Конфиденциальность','Ограничения PDF','Доказательства DOCX','Открыть рабочую область'], detectorLabel: 'Образец текста', detectorButton: 'Проверить предварительно', detectorPlaceholder: 'Вставьте до 220 слов. Предпросмотр проверяет только локальные статистические признаки.', detectorInitial: 'Результаты появятся здесь. Текст остается в этом браузере.', pages: { free: ['Бесплатный AI-детектор','Бесплатный предпросмотр в браузере','Вставьте короткий текст и получите локальные признаки без входа и загрузки.'], zhFree: ['Детектор традиционного китайского','Бесплатный предпросмотр в браузере','Вход для коротких текстов на традиционном китайском без загрузки.'], localVsCloud: ['Локальная AI-проверка и облачная загрузка','Руководство по приватности','Сравните локальную проверку с инструментами, требующими загрузки конфиденциальных черновиков.'], pdfLimits: ['Ограничения AI-проверки PDF','Файловая экспертиза','PDF полезен для видимого текста, но слаб как доказательство процесса написания.'], docxEvidence: ['История редактирования DOCX как доказательство','Доказательство источника','Исходный редактируемый файл может хранить следы, которых нет в PDF или скопированном тексте.'], lowBurstiness: ['Низкая burstiness в AI-тексте','Письменный сигнал','Слишком ровный ритм может быть признаком AI, но его нужно читать вместе с другими данными.'], fakeCitations: ['Фальшивые цитаты и проверка источников','Проверка ссылок','Даже правдоподобные ссылки требуют проверки DOI, журнала, автора и названия.'] }, article: { body: ['Что важно знать','TruthLens разделяет текстовые признаки, происхождение файла и проверку ссылок, чтобы слабый сигнал не становился вердиктом.','Как использовать','Начните с публичного руководства или короткого предпросмотра; полный локальный рабочий стол нужен для построчных причин, импорта, истории и PDF-экспорта.'] } },
    th: { lang: 'th', nav: ['ตัวตรวจฟรี','คู่มือความเป็นส่วนตัว','ข้อจำกัด PDF','หลักฐาน DOCX','เปิดพื้นที่ทำงาน'], detectorLabel: 'ตัวอย่างข้อความ', detectorButton: 'วิเคราะห์ตัวอย่าง', detectorPlaceholder: 'วางข้อความประมาณไม่เกิน 220 คำ ตัวอย่างนี้ตรวจเฉพาะสัญญาณสถิติในเครื่อง', detectorInitial: 'ผลลัพธ์จะแสดงที่นี่ ข้อความอยู่ในเบราว์เซอร์นี้เท่านั้น', pages: { free: ['ตัวตรวจ AI ฟรี','ตัวอย่างฟรีในเบราว์เซอร์','วางข้อความสั้นเพื่อดูสัญญาณในเครื่อง โดยไม่ต้องเข้าสู่ระบบและไม่อัปโหลด'], zhFree: ['ตัวตรวจภาษาจีนตัวเต็ม','ตัวอย่างฟรีในเบราว์เซอร์','ทางเข้าสำหรับข้อความสั้นภาษาจีนตัวเต็มโดยไม่อัปโหลด'], localVsCloud: ['การตรวจ AI ในเครื่องเทียบกับการอัปโหลดคลาวด์','คู่มือความเป็นส่วนตัว','เปรียบเทียบการตรวจในเครื่องกับเครื่องมือที่ต้องอัปโหลดร่างลับ'], pdfLimits: ['ข้อจำกัดของการตรวจ AI ใน PDF','นิติวิทยาศาสตร์ไฟล์','PDF เหมาะกับการดึงข้อความที่เห็น แต่ไม่แข็งแรงพอจะพิสูจน์กระบวนการเขียน'], docxEvidence: ['ประวัติการแก้ไข DOCX เป็นหลักฐาน','หลักฐานที่มา','ไฟล์แก้ไขต้นฉบับอาจเก็บร่องรอยที่ PDF หรือข้อความคัดลอกไม่มี'], lowBurstiness: ['Burstiness ต่ำในงานเขียน AI','สัญญาณการเขียน','จังหวะประโยคที่สม่ำเสมอเกินไปอาจเป็นสัญญาณ AI แต่ต้องอ่านร่วมกับหลักฐานอื่น'], fakeCitations: ['การอ้างอิงปลอมและการตรวจเอกสารอ้างอิง','ตรวจเอกสารอ้างอิง','รายการอ้างอิงที่ดูน่าเชื่อถือยังต้องตรวจ DOI วารสาร ผู้แต่ง และชื่อเรื่อง'] }, article: { body: ['สิ่งที่ควรรู้','TruthLens แยกสัญญาณข้อความ หลักฐานที่มาของไฟล์ และการตรวจเอกสารอ้างอิง เพื่อไม่ให้สัญญาณอ่อนหนึ่งอย่างกลายเป็นคำตัดสิน','วิธีใช้','เริ่มจากคู่มือสาธารณะหรือตัวอย่างข้อความสั้น แล้วเปิดพื้นที่ทำงานในเครื่องเมื่อจำเป็นต้องดูเหตุผลรายประโยค นำเข้าไฟล์ ประวัติ และส่งออก PDF'] } },
    ms: { lang: 'ms', nav: ['Pengesan percuma','Privasi','Had PDF','Bukti DOCX','Buka ruang kerja'], detectorLabel: 'Sampel teks', detectorButton: 'Analisis pratonton', detectorPlaceholder: 'Tampal sehingga kira-kira 220 patah perkataan. Pratonton hanya memeriksa corak statistik setempat.', detectorInitial: 'Keputusan akan muncul di sini. Teks kekal dalam pelayar ini.', pages: { free: ['Pengesan AI percuma','Pratonton percuma dalam pelayar','Tampal teks pendek dan lihat isyarat setempat tanpa log masuk atau muat naik.'], zhFree: ['Pengesan Cina Tradisional','Pratonton percuma dalam pelayar','Pintu masuk teks pendek Cina Tradisional tanpa muat naik.'], localVsCloud: ['Pengesanan AI setempat berbanding muat naik awan','Panduan privasi','Bandingkan pengesanan setempat dengan alat yang perlu memuat naik draf sulit.'], pdfLimits: ['Had pengesanan AI untuk PDF','Forensik fail','PDF berguna untuk teks kelihatan, tetapi lemah untuk membuktikan proses penulisan.'], docxEvidence: ['Sejarah suntingan DOCX sebagai bukti','Bukti sumber','Fail boleh sunting asal boleh menyimpan petunjuk yang tiada dalam PDF atau teks disalin.'], lowBurstiness: ['Burstiness rendah dalam penulisan AI','Isyarat penulisan','Ritma ayat terlalu sekata boleh menjadi isyarat AI, tetapi mesti dibaca bersama bukti lain.'], fakeCitations: ['Petikan palsu dan semakan rujukan','Semakan rujukan','Rujukan yang nampak munasabah masih perlu diperiksa DOI, jurnal, pengarang dan tajuknya.'] }, article: { body: ['Perkara penting','TruthLens memisahkan isyarat teks, bukti sumber fail dan semakan rujukan supaya satu isyarat lemah tidak menjadi keputusan.','Cara menggunakan','Mulakan dengan panduan awam atau pratonton teks pendek, kemudian buka ruang kerja setempat penuh untuk sebab per ayat, import fail, sejarah dan eksport PDF.'] } },
    id: { lang: 'id', nav: ['Detektor gratis','Privasi','Batas PDF','Bukti DOCX','Buka ruang kerja'], detectorLabel: 'Contoh teks', detectorButton: 'Analisis pratinjau', detectorPlaceholder: 'Tempel hingga sekitar 220 kata. Pratinjau hanya memeriksa pola statistik lokal.', detectorInitial: 'Hasil akan muncul di sini. Teks tetap berada di browser ini.', pages: { free: ['Detektor AI gratis','Pratinjau gratis di browser','Tempel teks pendek dan lihat sinyal lokal tanpa login atau unggahan.'], zhFree: ['Detektor Tionghoa Tradisional','Pratinjau gratis di browser','Pintu masuk pratinjau teks pendek Tionghoa Tradisional tanpa unggahan.'], localVsCloud: ['Deteksi AI lokal vs unggahan cloud','Panduan privasi','Bandingkan deteksi lokal dengan alat yang mewajibkan unggahan draf rahasia.'], pdfLimits: ['Batas deteksi AI pada PDF','Forensik file','PDF berguna untuk teks terlihat, tetapi lemah untuk membuktikan proses penulisan.'], docxEvidence: ['Riwayat penyuntingan DOCX sebagai bukti','Bukti sumber','File asli yang dapat diedit bisa menyimpan petunjuk yang tidak ada pada PDF atau teks salinan.'], lowBurstiness: ['Burstiness rendah dalam tulisan AI','Sinyal tulisan','Ritme kalimat yang terlalu seragam bisa menjadi sinyal AI, tetapi harus dibaca bersama bukti lain.'], fakeCitations: ['Kutipan palsu dan pemeriksaan referensi','Pemeriksaan referensi','Referensi yang tampak masuk akal tetap perlu diperiksa DOI, jurnal, penulis, dan judulnya.'] }, article: { body: ['Yang perlu diketahui','TruthLens memisahkan sinyal teks, bukti sumber file, dan pemeriksaan referensi agar satu sinyal lemah tidak menjadi vonis.','Cara menggunakan','Mulailah dari panduan publik atau pratinjau teks pendek, lalu buka ruang kerja lokal penuh untuk alasan per kalimat, impor file, riwayat, dan ekspor PDF.'] } }
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
      return window.localStorage.getItem('truthlens-public-lang');
    } catch (_) {
      return null;
    }
  }

  function storeLanguage(lang) {
    try {
      window.localStorage.setItem('truthlens-public-lang', lang);
    } catch (_) {}
  }

  function localizedPath(path, lang) {
    if (!path) return path;
    const url = new URL(path, window.location.origin);
    url.searchParams.set('lang', lang);
    return url.pathname + url.search + url.hash;
  }

  function workspacePath(lang) {
    return '/?workspace=1&lang=' + encodeURIComponent(lang);
  }

  function renderLanguagePicker(lang) {
    const nav = document.querySelector('.tl-nav');
    if (!nav || document.querySelector('.tl-language')) return;

    const wrap = document.createElement('div');
    wrap.className = 'tl-language';

    const label = document.createElement('label');
    label.setAttribute('for', 'tl-public-language');
    label.textContent = languageLabels[lang] || languageLabels.en;

    const select = document.createElement('select');
    select.id = 'tl-public-language';
    languages.forEach(([code, name]) => {
      const option = document.createElement('option');
      option.value = code;
      option.textContent = name;
      option.selected = code === lang;
      select.appendChild(option);
    });
    select.addEventListener('change', () => {
      storeLanguage(select.value);
      const url = new URL(window.location.href);
      url.searchParams.set('lang', select.value);
      window.location.href = url.pathname + url.search + url.hash;
    });

    wrap.append(label, select);
    nav.appendChild(wrap);
  }

  function translateDetectorLanding(key, pack, page) {
    if (key !== 'free' && key !== 'zhFree') return;
    const body = pack.article.body;
    const actions = document.querySelectorAll('.tl-actions a');
    if (actions[0]) actions[0].textContent = pack.nav[4];
    if (actions[1]) actions[1].textContent = pack.nav[0];
    setText('#detector-title', page[0]);

    const panelTitles = document.querySelectorAll('.tl-panel h3');
    const panelBodies = document.querySelectorAll('.tl-panel p');
    if (panelTitles[0]) panelTitles[0].textContent = page[1];
    if (panelBodies[0]) panelBodies[0].textContent = page[2];
    if (panelTitles[1]) panelTitles[1].textContent = body[0];
    if (panelBodies[1]) panelBodies[1].textContent = body[1];
    if (panelTitles[2]) panelTitles[2].textContent = body[2];
    if (panelBodies[2]) panelBodies[2].textContent = body[3];

    const note = document.querySelector('.tl-note');
    if (note) {
      note.replaceChildren();
      const strong = document.createElement('strong');
      strong.textContent = body[0] + ':';
      note.append(strong, ' ' + body[1]);
    }

    const article = document.querySelector('section.tl-article');
    if (article) {
      article.innerHTML = '';
      const h2a = document.createElement('h2');
      h2a.textContent = body[0];
      const p1 = document.createElement('p');
      p1.textContent = body[1];
      const h2b = document.createElement('h2');
      h2b.textContent = body[2];
      const p2 = document.createElement('p');
      p2.textContent = body[3];
      article.append(h2a, p1, h2b, p2);
    }

    const footer = document.querySelector('.tl-footer');
    if (footer) footer.textContent = '© 2026 TruthLens. ' + page[2];
  }

  const params = new URLSearchParams(window.location.search || '');
  const pack =
    common[
      normalize(
        params.get('lang') ||
          storedLanguage() ||
          navigator.language ||
          document.documentElement.lang,
      )
    ] || common.en;
  const key = pageKey();
  const page = pack.pages[key] || common.en.pages[key];
  if (!page) return;

  document.documentElement.lang = pack.lang;
  document.title = page[0] + ' | TruthLens';
  const description = document.querySelector('meta[name="description"]');
  if (description) description.setAttribute('content', page[2]);

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
  }
})();
