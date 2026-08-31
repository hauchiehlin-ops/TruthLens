(function () {
  const input = document.querySelector('[data-detector-input]');
  const run = document.querySelector('[data-detector-run]');
  const count = document.querySelector('[data-word-count]');
  const output = document.querySelector('[data-detector-output]');

  if (!input || !run || !count || !output) {
    return;
  }

  const lang = document.documentElement.lang || 'en';
  const isZh = lang.toLowerCase().startsWith('zh');

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
      reasons.push(
        isZh
          ? '樣本太短，只能提供非常粗略的方向。'
          : 'The sample is short, so this preview can only provide a rough direction.',
      );
    }

    if (lengths.length >= 4) {
      const mean = lengths.reduce((sum, value) => sum + value, 0) / lengths.length;
      const variance =
        lengths.reduce((sum, value) => sum + Math.pow(value - mean, 2), 0) /
        lengths.length;
      const coefficient = Math.sqrt(variance) / Math.max(mean, 1);
      if (coefficient < 0.38) {
        score += 22;
        reasons.push(
          isZh
            ? '句長變化偏低，呈現較整齊的生成式節奏。'
            : 'Sentence lengths vary little, a pattern often seen in generated prose.',
        );
      } else if (coefficient > 0.9) {
        score -= 8;
        reasons.push(
          isZh
            ? '句長起伏明顯，較不像單一模板輸出。'
            : 'Sentence lengths vary strongly, which weakens a template-like signal.',
        );
      }
    }

    const transitionPattern =
      /(此外|因此|然而|總之|首先|其次|最後|in addition|therefore|however|overall|firstly|secondly|finally)/gi;
    const transitionHits = clean.match(transitionPattern) || [];
    if (transitionHits.length >= 3) {
      score += 14;
      reasons.push(
        isZh
          ? '連接詞與段落轉折密度偏高，可能是模型整理式寫法。'
          : 'Transition phrases are dense, which can indicate model-organized writing.',
      );
    }

    const ratio = uniqueRatio(clean);
    if (ratio < 0.48 && words >= 60) {
      score += 12;
      reasons.push(
        isZh
          ? '詞彙重複率偏高，需要與主題限制一起判讀。'
          : 'Lexical repetition is elevated and should be read against the topic constraints.',
      );
    }

    const citationPattern =
      /\b(19|20)\d{2}\b|doi:|et al\.|參考文獻|引用|journal|conference/gi;
    if ((clean.match(citationPattern) || []).length >= 3) {
      score += 8;
      reasons.push(
        isZh
          ? '文字含有引用型主張；完整工具會另外檢查 DOI、期刊與文獻資料庫。'
          : 'The text contains citation-like claims; the full workspace can verify DOI and bibliographic records.',
      );
    }

    const humanPattern =
      /(I remember|in my experience|我記得|我當時|個人經驗|訪談|田野|手稿)/gi;
    if ((clean.match(humanPattern) || []).length >= 2) {
      score -= 10;
      reasons.push(
        isZh
          ? '文字含有個人經驗或原始材料訊號，降低單靠文字判讀的把握。'
          : 'Personal experience or source-material cues reduce confidence in text-only classification.',
      );
    }

    if (words > 220) {
      score -= 4;
      reasons.push(
        isZh
          ? '預覽工具建議 220 字以內；長文請改用完整工作台逐句分析。'
          : 'This preview is calibrated for samples under 220 words; use the full workspace for long documents.',
      );
    }

    if (reasons.length === 0) {
      reasons.push(
        isZh
          ? '未偵測到明顯模式；請用完整工作台取得多引擎與逐句報告。'
          : 'No strong pattern was detected; use the full workspace for multi-engine sentence-level evidence.',
      );
    }

    return {
      score: clamp(Math.round(score), 5, 92),
      reasons,
    };
  }

  function render() {
    const words = estimateWords(input.value);
    count.textContent = isZh ? `${words} / 220 字預覽` : `${words} / 220 words`;
  }

  function showResult() {
    const result = analyze(input.value);
    output.replaceChildren();

    const score = document.createElement('div');
    score.className = 'tl-score';
    score.textContent = `${result.score}/100`;
    output.appendChild(score);

    const intro = document.createElement('p');
    intro.textContent = isZh
      ? '這是瀏覽器內的輕量預覽，不是完整 TruthLens 多引擎結論。'
      : 'This is a lightweight in-browser preview, not the full TruthLens multi-engine verdict.';
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
