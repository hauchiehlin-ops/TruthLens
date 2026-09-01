(function () {
  const input = document.querySelector('[data-detector-input]');
  const run = document.querySelector('[data-detector-run]');
  const count = document.querySelector('[data-word-count]');
  const output = document.querySelector('[data-detector-output]');

  if (!input || !run || !count || !output) {
    return;
  }

  const lang = document.documentElement.lang || 'en';
  const locale = lang.toLowerCase().startsWith('zh') ? 'zh' : lang.split('-')[0];
  const text = {
    en: {
      count: (words) => `${words} / 220 words`,
      short: 'The sample is short, so this preview can only provide a rough direction.',
      lowVariance: 'Sentence lengths vary little, a pattern often seen in generated prose.',
      highVariance: 'Sentence lengths vary strongly, which weakens a template-like signal.',
      transitions: 'Transition phrases are dense, which can indicate model-organized writing.',
      repetition: 'Lexical repetition is elevated and should be read against the topic constraints.',
      citations: 'The text contains citation-like claims; the full workspace can verify DOI and bibliographic records.',
      source: 'Personal experience or source-material cues reduce confidence in text-only classification.',
      long: 'This preview is calibrated for samples under 220 words; use the full workspace for long documents.',
      none: 'No strong pattern was detected; use the full workspace for multi-engine sentence-level evidence.',
      intro: 'This is a lightweight in-browser preview, not the full OmniTrace multi-engine verdict.',
    },
    zh: {
      count: (words) => `${words} / 220 字預覽`,
      short: '樣本太短，只能提供非常粗略的方向。',
      lowVariance: '句長變化偏低，呈現較整齊的生成式節奏。',
      highVariance: '句長起伏明顯，較不像單一模板輸出。',
      transitions: '連接詞與段落轉折密度偏高，可能是模型整理式寫法。',
      repetition: '詞彙重複率偏高，需要與主題限制一起判讀。',
      citations: '文字含有引用型主張；完整工具會另外檢查 DOI、期刊與文獻資料庫。',
      source: '文字含有個人經驗或原始材料訊號，降低單靠文字判讀的把握。',
      long: '預覽工具建議 220 字以內；長文請改用完整工作台逐句分析。',
      none: '未偵測到明顯模式；請用完整工作台取得多引擎與逐句報告。',
      intro: '這是瀏覽器內的輕量預覽，不是完整 OmniTrace 多引擎結論。',
    },
    ja: {
      count: (words) => `${words} / 220 語`,
      short: 'サンプルが短いため、大まかな方向のみ表示します。',
      lowVariance: '文の長さの変化が小さく、生成文に見られる整ったリズムです。',
      highVariance: '文の長さに十分な揺れがあり、テンプレート的な兆候は弱まります。',
      transitions: '接続表現が多く、モデルが整理した文章の兆候になり得ます。',
      repetition: '語彙の反復が高めです。主題の制約と合わせて読む必要があります。',
      citations: '引用らしい主張があります。完全版では DOI と文献記録を確認できます。',
      source: '個人経験や一次資料の手がかりがあり、テキストだけの判定信頼度は下がります。',
      long: 'このプレビューは 220 語以内向けです。長文は完全なワークスペースを使用してください。',
      none: '強いパターンは見つかりません。完全版で複数エンジンの文単位証拠を確認してください。',
      intro: 'これはブラウザ内の軽量プレビューであり、OmniTrace の完全な複数エンジン判定ではありません。',
    },
    ko: {
      count: (words) => `${words} / 220 단어`,
      short: '샘플이 짧아 매우 대략적인 방향만 제공합니다.',
      lowVariance: '문장 길이 변화가 작아 생성형 문체의 일정한 리듬이 보입니다.',
      highVariance: '문장 길이 변화가 커서 템플릿형 신호가 약해집니다.',
      transitions: '전환 표현 밀도가 높아 모델이 정리한 글의 신호일 수 있습니다.',
      repetition: '어휘 반복이 높아 주제 제약과 함께 해석해야 합니다.',
      citations: '인용형 주장이 있습니다. 전체 작업 공간에서 DOI와 문헌 기록을 검증할 수 있습니다.',
      source: '개인 경험 또는 원자료 단서가 있어 텍스트만으로 분류하는 신뢰도가 낮아집니다.',
      long: '이 미리보기는 220단어 이하에 맞춰져 있습니다. 긴 문서는 전체 작업 공간을 사용하세요.',
      none: '뚜렷한 패턴은 감지되지 않았습니다. 전체 작업 공간에서 문장별 증거를 확인하세요.',
      intro: '브라우저 내 가벼운 미리보기이며 OmniTrace 전체 다중 엔진 결론은 아닙니다.',
    },
    es: {
      count: (words) => `${words} / 220 palabras`,
      short: 'La muestra es corta; esta vista previa solo puede dar una orientación aproximada.',
      lowVariance: 'Las longitudes de las frases varían poco, un patrón común en prosa generada.',
      highVariance: 'Las longitudes varían mucho, lo que debilita una señal de plantilla.',
      transitions: 'Hay muchas frases de transición, posible señal de escritura organizada por modelo.',
      repetition: 'La repetición léxica es elevada y debe leerse junto con el tema.',
      citations: 'El texto contiene afirmaciones tipo cita; el área completa puede verificar DOI y registros.',
      source: 'Las señales de experiencia personal o material fuente reducen la confianza de una clasificación solo textual.',
      long: 'La vista previa está calibrada para menos de 220 palabras; usa el área completa para documentos largos.',
      none: 'No se detectó un patrón fuerte; usa el área completa para evidencia por frase y varios motores.',
      intro: 'Esta es una vista previa ligera en el navegador, no el veredicto multiengine completo de OmniTrace.',
    },
    de: {
      count: (words) => `${words} / 220 Wörter`,
      short: 'Die Probe ist kurz; diese Vorschau kann nur eine grobe Richtung zeigen.',
      lowVariance: 'Die Satzlängen variieren wenig, ein Muster, das oft in generierter Prosa vorkommt.',
      highVariance: 'Die Satzlängen variieren deutlich, was ein vorlagenartiges Signal abschwächt.',
      transitions: 'Übergangsphrasen treten gehäuft auf und können auf modellorganisierte Texte hinweisen.',
      repetition: 'Die Wortwiederholung ist erhöht und sollte mit den Themenvorgaben gelesen werden.',
      citations: 'Der Text enthält zitationsartige Aussagen; der vollständige Arbeitsbereich kann DOI und Literaturdaten prüfen.',
      source: 'Persönliche Erfahrung oder Quellmaterial senken die Sicherheit einer rein textbasierten Einstufung.',
      long: 'Diese Vorschau ist für Proben unter 220 Wörtern kalibriert; nutzen Sie für lange Dokumente den Arbeitsbereich.',
      none: 'Es wurde kein starkes Muster erkannt; nutzen Sie den Arbeitsbereich für satzweise Mehr-Engine-Belege.',
      intro: 'Dies ist eine leichte Browser-Vorschau, nicht das vollständige Mehr-Engine-Urteil von OmniTrace.',
    },
    fr: {
      count: (words) => `${words} / 220 mots`,
      short: 'L’échantillon est court ; cet aperçu ne donne qu’une orientation approximative.',
      lowVariance: 'Les longueurs de phrases varient peu, un motif fréquent dans la prose générée.',
      highVariance: 'Les longueurs de phrases varient fortement, ce qui affaiblit le signal de modèle.',
      transitions: 'Les transitions sont denses et peuvent indiquer une écriture organisée par modèle.',
      repetition: 'La répétition lexicale est élevée et doit être lue avec les contraintes du sujet.',
      citations: 'Le texte contient des affirmations de type citation ; l’espace complet peut vérifier DOI et notices.',
      source: 'Des indices d’expérience personnelle ou de source réduisent la confiance d’une classification textuelle seule.',
      long: 'Cet aperçu est calibré pour moins de 220 mots ; utilisez l’espace complet pour les longs documents.',
      none: 'Aucun motif fort n’a été détecté ; utilisez l’espace complet pour des preuves par phrase.',
      intro: 'Ceci est un aperçu léger dans le navigateur, pas le verdict multi-moteur complet de OmniTrace.',
    },
    pt: {
      count: (words) => `${words} / 220 palavras`,
      short: 'A amostra é curta; esta prévia só pode indicar uma direção aproximada.',
      lowVariance: 'Os comprimentos das frases variam pouco, padrão comum em prosa gerada.',
      highVariance: 'Os comprimentos variam bastante, o que enfraquece um sinal de modelo.',
      transitions: 'As frases de transição são densas e podem indicar escrita organizada por modelo.',
      repetition: 'A repetição lexical está elevada e deve ser lida junto com o tema.',
      citations: 'O texto contém afirmações semelhantes a citações; o workspace completo pode verificar DOI e registros.',
      source: 'Sinais de experiência pessoal ou material-fonte reduzem a confiança em uma classificação só textual.',
      long: 'Esta prévia é calibrada para menos de 220 palavras; use o workspace completo para documentos longos.',
      none: 'Nenhum padrão forte foi detectado; use o workspace completo para evidências por frase.',
      intro: 'Esta é uma prévia leve no navegador, não o veredito multi-motor completo do OmniTrace.',
    },
    ru: {
      count: (words) => `${words} / 220 слов`,
      short: 'Образец короткий, поэтому предпросмотр дает только приблизительное направление.',
      lowVariance: 'Длины предложений меняются мало, что часто встречается в сгенерированной прозе.',
      highVariance: 'Длины предложений заметно различаются, что ослабляет шаблонный сигнал.',
      transitions: 'Переходные фразы встречаются часто и могут указывать на модельную организацию текста.',
      repetition: 'Лексические повторы повышены; их нужно читать с учетом темы.',
      citations: 'Текст содержит похожие на цитаты утверждения; полный режим может проверить DOI и записи.',
      source: 'Личный опыт или исходные материалы снижают уверенность текстовой классификации.',
      long: 'Предпросмотр рассчитан на образцы до 220 слов; для длинных документов используйте рабочую область.',
      none: 'Сильный шаблон не обнаружен; используйте рабочую область для посрочных доказательств.',
      intro: 'Это легкий предпросмотр в браузере, а не полный многоуровневый вывод OmniTrace.',
    },
    th: {
      count: (words) => `${words} / 220 คำ`,
      short: 'ตัวอย่างสั้น จึงให้ได้เพียงทิศทางคร่าว ๆ',
      lowVariance: 'ความยาวประโยคเปลี่ยนแปลงน้อย เป็นรูปแบบที่พบได้ในข้อความที่สร้างโดยโมเดล',
      highVariance: 'ความยาวประโยคแกว่งชัดเจน จึงลดสัญญาณแบบแม่แบบลง',
      transitions: 'มีวลีเชื่อมโยงหนาแน่น ซึ่งอาจบ่งชี้งานเขียนที่โมเดลจัดระเบียบ',
      repetition: 'การซ้ำคำสูงขึ้น ควรอ่านร่วมกับข้อจำกัดของหัวข้อ',
      citations: 'ข้อความมีข้ออ้างคล้ายการอ้างอิง พื้นที่ทำงานเต็มสามารถตรวจ DOI และรายการบรรณานุกรม',
      source: 'สัญญาณประสบการณ์ส่วนตัวหรือแหล่งข้อมูลต้นทางลดความมั่นใจของการจำแนกจากข้อความล้วน',
      long: 'ตัวอย่างนี้ปรับไว้สำหรับไม่เกิน 220 คำ เอกสารยาวควรใช้พื้นที่ทำงานเต็ม',
      none: 'ไม่พบรูปแบบเด่นชัด โปรดใช้พื้นที่ทำงานเต็มเพื่อดูหลักฐานรายประโยคหลายเครื่องยนต์',
      intro: 'นี่คือการแสดงตัวอย่างแบบเบาในเบราว์เซอร์ ไม่ใช่ข้อสรุปหลายเครื่องยนต์เต็มของ OmniTrace',
    },
    ms: {
      count: (words) => `${words} / 220 perkataan`,
      short: 'Sampel ini pendek, jadi pratonton hanya memberi arah kasar.',
      lowVariance: 'Panjang ayat kurang berubah, corak yang kerap dilihat dalam prosa dijana.',
      highVariance: 'Panjang ayat berubah dengan jelas, lalu melemahkan isyarat seperti templat.',
      transitions: 'Frasa peralihan padat dan boleh menandakan penulisan yang disusun model.',
      repetition: 'Pengulangan leksikal tinggi dan perlu dibaca bersama kekangan topik.',
      citations: 'Teks mengandungi dakwaan seperti petikan; ruang kerja penuh boleh menyemak DOI dan rekod bibliografi.',
      source: 'Isyarat pengalaman peribadi atau bahan sumber mengurangkan keyakinan klasifikasi teks sahaja.',
      long: 'Pratonton ini ditala untuk kurang daripada 220 perkataan; gunakan ruang kerja penuh untuk dokumen panjang.',
      none: 'Tiada corak kuat dikesan; gunakan ruang kerja penuh untuk bukti per ayat berbilang enjin.',
      intro: 'Ini pratonton ringan dalam pelayar, bukan keputusan penuh berbilang enjin OmniTrace.',
    },
    id: {
      count: (words) => `${words} / 220 kata`,
      short: 'Sampel ini pendek, jadi pratinjau hanya memberi arah kasar.',
      lowVariance: 'Panjang kalimat sedikit bervariasi, pola yang sering muncul pada prosa buatan.',
      highVariance: 'Panjang kalimat sangat bervariasi, sehingga sinyal seperti templat melemah.',
      transitions: 'Frasa transisi cukup padat dan dapat menunjukkan tulisan yang disusun model.',
      repetition: 'Pengulangan leksikal meningkat dan perlu dibaca bersama batasan topik.',
      citations: 'Teks berisi klaim seperti kutipan; ruang kerja lengkap dapat memeriksa DOI dan catatan bibliografi.',
      source: 'Sinyal pengalaman pribadi atau bahan sumber menurunkan keyakinan klasifikasi berbasis teks saja.',
      long: 'Pratinjau ini dikalibrasi untuk kurang dari 220 kata; gunakan ruang kerja lengkap untuk dokumen panjang.',
      none: 'Tidak ada pola kuat yang terdeteksi; gunakan ruang kerja lengkap untuk bukti per kalimat.',
      intro: 'Ini adalah pratinjau ringan di browser, bukan kesimpulan multi-mesin penuh OmniTrace.',
    },
  };
  const t = text[locale] || text.en;

  function estimateWords(text) {
    const latin = text.match(/[A-Za-z0-9]+(?:'[A-Za-z0-9]+)?/g) || [];
    const cjk = text.match(/[\u3400-\u9fff]/g) || [];
    return latin.length + Math.ceil(cjk.length / 2);
  }

  function sentences(text) {
    return text
      .split(/[.!?。！？\n]+/)
      .map((item) => item.trim())
      .filter((item) => item.length > 0);
  }

  function sentenceLength(text) {
    const cjk = text.match(/[\u3400-\u9fff]/g) || [];
    const latin = text.match(/[A-Za-z0-9]+(?:'[A-Za-z0-9]+)?/g) || [];
    return latin.length + Math.ceil(cjk.length / 2);
  }

  function clamp(value, min, max) {
    return Math.max(min, Math.min(max, value));
  }

  function uniqueRatio(text) {
    const tokens = (text.toLowerCase().match(/[\u3400-\u9fff]|[a-z0-9]+/g) || [])
      .filter((token) => token.length > 0);
    if (tokens.length < 8) {
      return 1;
    }
    return new Set(tokens).size / tokens.length;
  }

  function analyze(text) {
    const clean = text.trim();
    const parts = sentences(clean);
    const lengths = parts.map(sentenceLength).filter((value) => value > 0);
    const words = estimateWords(clean);
    let score = 24;
    const reasons = [];

    if (words < 45) {
      reasons.push(t.short);
    }

    if (lengths.length >= 4) {
      const mean = lengths.reduce((sum, value) => sum + value, 0) / lengths.length;
      const variance =
        lengths.reduce((sum, value) => sum + Math.pow(value - mean, 2), 0) /
        lengths.length;
      const coefficient = Math.sqrt(variance) / Math.max(mean, 1);
      if (coefficient < 0.38) {
        score += 22;
        reasons.push(t.lowVariance);
      } else if (coefficient > 0.9) {
        score -= 8;
        reasons.push(t.highVariance);
      }
    }

    const transitionPattern =
      /(此外|因此|然而|總之|首先|其次|最後|in addition|therefore|however|overall|firstly|secondly|finally)/gi;
    const transitionHits = clean.match(transitionPattern) || [];
    if (transitionHits.length >= 3) {
      score += 14;
      reasons.push(t.transitions);
    }

    const ratio = uniqueRatio(clean);
    if (ratio < 0.48 && words >= 60) {
      score += 12;
      reasons.push(t.repetition);
    }

    const citationPattern =
      /\b(19|20)\d{2}\b|doi:|et al\.|參考文獻|引用|journal|conference/gi;
    if ((clean.match(citationPattern) || []).length >= 3) {
      score += 8;
      reasons.push(t.citations);
    }

    const humanPattern =
      /(I remember|in my experience|我記得|我當時|個人經驗|訪談|田野|手稿)/gi;
    if ((clean.match(humanPattern) || []).length >= 2) {
      score -= 10;
      reasons.push(t.source);
    }

    if (words > 220) {
      score -= 4;
      reasons.push(t.long);
    }

    if (reasons.length === 0) {
      reasons.push(t.none);
    }

    return {
      score: clamp(Math.round(score), 5, 92),
      reasons,
    };
  }

  function render() {
    const words = estimateWords(input.value);
    count.textContent = t.count(words);
  }

  function showResult() {
    const result = analyze(input.value);
    output.replaceChildren();

    const score = document.createElement('div');
    score.className = 'tl-score';
    score.textContent = `${result.score}/100`;
    output.appendChild(score);

    const intro = document.createElement('p');
    intro.textContent = t.intro;
    output.appendChild(intro);

    const list = document.createElement('ul');
    list.className = 'tl-result-list';
    result.reasons.forEach((reason) => {
      const item = document.createElement('li');
      item.textContent = reason;
      list.appendChild(item);
    });
    output.appendChild(list);
  }

  input.addEventListener('input', render);
  run.addEventListener('click', showResult);
  render();
})();
