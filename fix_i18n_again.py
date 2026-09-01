import re
import json

with open('web/seo/home_i18n.js', 'r', encoding='utf-8') as f:
    content = f.read()

# First, clean up ANY existing changelog keys from all blocks
content = re.sub(r'\s*changelogTitle:\s*".*?",\n', '\n', content)
content = re.sub(r'\s*changelog1:\s*".*?",\n', '\n', content)
content = re.sub(r'\s*changelog2:\s*".*?",\n', '\n', content)
content = re.sub(r'\s*footerText:\s*".*?",\n', '\n', content)

translations = {
    'en': ['Latest Updates', 'v6.0.0 - Rebranded to OmniTrace with a new multidimensional forensics logo.', 'v5.0.0 - Added programmatic SEO engine and multilingual static pages.', 'Local-first AI content detection and document forensics.'],
    'zh-Hant': ['近期更新', 'v6.0.0 - 品牌全新升級為 OmniTrace，並導入發光數據流圖示。', 'v5.0.0 - 新增多國語系靜態頁面矩陣與自動化 SEO 引擎。', '本地優先 AI 內容檢測與文件鑑識。'],
    'zh-Hans': ['近期更新', 'v6.0.0 - 品牌全新升级为 OmniTrace，并导入发光数据流图标。', 'v5.0.0 - 新增多国语系静态页面矩阵与自动化 SEO 引擎。', '本地优先 AI 内容检测与文件鉴识。'],
    'ja': ['最新のアップデート', 'v6.0.0 - OmniTraceにブランド名を変更し、新しい多次元フォレンジックロゴを導入。', 'v5.0.0 - プログラマティックSEOエンジンと多言語静的ページを追加しました。', 'ローカル優先の AI コンテンツ検出と文書フォレンジック。'],
    'ko': ['최근 업데이트', 'v6.0.0 - OmniTrace로 브랜드 변경 및 새로운 다차원 포렌식 로고 도입.', 'v5.0.0 - 프로그래밍 방식 SEO 엔진 및 다국어 정적 페이지 추가.', '로컬 우선 AI 콘텐츠 감지 및 문서 포렌식.'],
    'th': ['อัปเดตล่าสุด', 'v6.0.0 - เปลี่ยนชื่อแบรนด์เป็น OmniTrace พร้อมโลโก้การตรวจสอบหลายมิติใหม่', 'v5.0.0 - เพิ่มเครื่องมือ SEO และหน้าเว็บแบบคงที่หลายภาษา', 'การตรวจเนื้อหา AI และนิติวิทยาศาสตร์เอกสารแบบเน้นในเครื่อง'],
    'ms': ['Kemas Kini Terkini', 'v6.0.0 - Menjenamakan semula kepada OmniTrace dengan logo forensik pelbagai dimensi baharu.', 'v5.0.0 - Menambah enjin SEO programatik dan halaman statik berbilang bahasa.', 'Pengesanan kandungan AI dan forensik dokumen yang mengutamakan setempat.'],
    'es': ['Últimas actualizaciones', 'v6.0.0 - Cambio de marca a OmniTrace con un nuevo logotipo de análisis multidimensional.', 'v5.0.0 - Se agregó motor SEO programático y páginas estáticas multilingües.', 'Detección de contenido IA y análisis documental local primero.'],
    'id': ['Pembaruan Terbaru', 'v6.0.0 - Ganti nama menjadi OmniTrace dengan logo forensik multidimensi baru.', 'v5.0.0 - Menambahkan mesin SEO programatik dan halaman statis multibahasa.', 'Deteksi konten AI dan forensik dokumen yang mengutamakan lokal.'],
    'ru': ['Последние обновления', 'v6.0.0 - Ребрендинг в OmniTrace с новым многомерным криминалистическим логотипом.', 'v5.0.0 - Добавлен программный SEO-движок и многоязычные статические страницы.', 'Локальная AI-проверка контента и экспертиза документов.'],
    'de': ['Neueste Updates', 'v6.0.0 - Umbenennung in OmniTrace mit einem neuen mehrdimensionalen Forensik-Logo.', 'v5.0.0 - Programmatische SEO-Engine und mehrsprachige statische Seiten hinzugefügt.', 'Lokale KI-Inhaltserkennung und Dokumentforensik.'],
    'fr': ['Dernières mises à jour', 'v6.0.0 - Changement de marque pour OmniTrace avec un nouveau logo de criminalistique multidimensionnelle.', 'v5.0.0 - Ajout d\'un moteur SEO programmatique et de pages statiques multilingues.', 'Détection de contenu IA et analyse documentaire locale.'],
    'pt': ['Últimas Atualizações', 'v6.0.0 - Rebranding para OmniTrace com um novo logotipo de forense multidimensional.', 'v5.0.0 - Adicionado motor SEO programático e páginas estáticas multilíngues.', 'Detecção de conteúdo IA e forense documental local-first.']
}

for lang, tr in translations.items():
    pattern = r"(" + lang + r":\s*\{)"
    replacement = r"\1\n      changelogTitle: " + json.dumps(tr[0], ensure_ascii=False) + r",\n      changelog1: " + json.dumps(tr[1], ensure_ascii=False) + r",\n      changelog2: " + json.dumps(tr[2], ensure_ascii=False) + r",\n      footerText: " + json.dumps(tr[3], ensure_ascii=False) + r","
    content = re.sub(pattern, replacement, content, count=1)

with open('web/seo/home_i18n.js', 'w', encoding='utf-8') as f:
    f.write(content)
print("Fixed home_i18n.js")
