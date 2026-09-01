import re
import json

with open('web/seo/home_i18n.js', 'r', encoding='utf-8') as f:
    content = f.read()

translations = {
    'en': ['Latest Updates', 'v4.13.10 - Improved DOCX piece table parsing, increasing text extraction accuracy.', 'v4.13.9 - Added full PDF citation extraction and Crossref validation.', 'Local-first AI content detection and document forensics.'],
    'zh-Hant': ['近期更新', 'v4.13.10 - 改善 DOCX piece table 解析，提升文字抽取準確度。', 'v4.13.9 - 新增完整的 PDF 引用文獻抽取與 Crossref 驗證。', '本地優先 AI 內容檢測與文件鑑識。'],
    'zh-Hans': ['近期更新', 'v4.13.10 - 改善 DOCX piece table 解析，提升文字抽取准确度。', 'v4.13.9 - 新增完整的 PDF 引用文献抽取与 Crossref 验证。', '本地优先 AI 内容检测与文件鉴识。'],
    'ja': ['最新のアップデート', 'v4.13.10 - DOCXピーステーブルの解析を改善し、テキスト抽出の精度を向上させました。', 'v4.13.9 - PDFの完全な引用抽出とCrossref検証を追加しました。', 'ローカル優先の AI コンテンツ検出と文書フォレンジック。'],
    'ko': ['최근 업데이트', 'v4.13.10 - DOCX 피스 테이블 파싱을 개선하여 텍스트 추출 정확도를 높였습니다.', 'v4.13.9 - 전체 PDF 인용 추출 및 Crossref 검증을 추가했습니다.', '로컬 우선 AI 콘텐츠 감지 및 문서 포렌식.'],
    'th': ['อัปเดตล่าสุด', 'v4.13.10 - ปรับปรุงการแยกวิเคราะห์ตารางชิ้นส่วน DOCX เพื่อเพิ่มความแม่นยำในการดึงข้อความ', 'v4.13.9 - เพิ่มการดึงการอ้างอิง PDF แบบเต็มและการตรวจสอบ Crossref', 'การตรวจเนื้อหา AI และนิติวิทยาศาสตร์เอกสารแบบเน้นในเครื่อง'],
    'ms': ['Kemas Kini Terkini', 'v4.13.10 - Memperbaiki penghuraian jadual kepingan DOCX, meningkatkan ketepatan pengekstrakan teks.', 'v4.13.9 - Menambah pengekstrakan petikan PDF penuh dan pengesahan Crossref.', 'Pengesanan kandungan AI dan forensik dokumen yang mengutamakan setempat.'],
    'es': ['Últimas actualizaciones', 'v4.13.10 - Análisis mejorado de la tabla de piezas DOCX, aumentando la precisión de la extracción de texto.', 'v4.13.9 - Se agregó la extracción completa de citas en PDF y validación de Crossref.', 'Detección de contenido IA y análisis documental local primero.'],
    'id': ['Pembaruan Terbaru', 'v4.13.10 - Peningkatan penguraian tabel bagian DOCX, meningkatkan akurasi ekstraksi teks.', 'v4.13.9 - Menambahkan ekstraksi kutipan PDF lengkap dan validasi Crossref.', 'Deteksi konten AI dan forensik dokumen yang mengutamakan lokal.'],
    'ru': ['Последние обновления', 'v4.13.10 - Улучшен анализ таблицы фрагментов DOCX, повышена точность извлечения текста.', 'v4.13.9 - Добавлено полное извлечение цитат из PDF и проверка Crossref.', 'Локальная AI-проверка контента и экспертиза документов.'],
    'de': ['Neueste Updates', 'v4.13.10 - Verbesserte DOCX-Stücktabelle-Analyse, Erhöhung der Genauigkeit der Textextraktion.', 'v4.13.9 - Vollständige PDF-Zitatextraktion und Crossref-Validierung hinzugefügt.', 'Lokale KI-Inhaltserkennung und Dokumentforensik.'],
    'fr': ['Dernières mises à jour', 'v4.13.10 - Amélioration de l\'analyse de la table des pièces DOCX, augmentant la précision de l\'extraction de texte.', 'v4.13.9 - Ajout de l\'extraction complète des citations PDF et de la validation Crossref.', 'Détection de contenu IA et analyse documentaire locale.'],
    'pt': ['Últimas Atualizações', 'v4.13.10 - Melhoria na análise da tabela de peças DOCX, aumentando a precisão da extração de texto.', 'v4.13.9 - Adicionada extração completa de citações em PDF e validação Crossref.', 'Detecção de conteúdo IA e forense documental local-first.']
}

for lang, tr in translations.items():
    # Only add if not present, but for en and zh-Hant we might already have it, so we can replace or just append if missing.
    # To be safe, we'll replace the language block.
    # A block starts with `lang: {` and we can insert right after `title:` or similar.
    # Actually, we can just do a regex substitution: find the start of the object for that lang, and inject the keys.
    pattern = r"(" + lang + r":\s*\{)"
    # Clean up existing ones if they exist
    content = re.sub(r'changelogTitle:\s*".*?",\n\s*', '', content)
    content = re.sub(r'changelog1:\s*".*?",\n\s*', '', content)
    content = re.sub(r'changelog2:\s*".*?",\n\s*', '', content)
    content = re.sub(r'footerText:\s*".*?",\n\s*', '', content)

    replacement = r"\1\n      changelogTitle: " + json.dumps(tr[0], ensure_ascii=False) + r",\n      changelog1: " + json.dumps(tr[1], ensure_ascii=False) + r",\n      changelog2: " + json.dumps(tr[2], ensure_ascii=False) + r",\n      footerText: " + json.dumps(tr[3], ensure_ascii=False) + r","
    
    content = re.sub(pattern, replacement, content, count=1)

with open('web/seo/home_i18n.js', 'w', encoding='utf-8') as f:
    f.write(content)
