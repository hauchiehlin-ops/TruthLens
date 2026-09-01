import re
import json

with open('web/seo/home_i18n.js', 'r', encoding='utf-8') as f:
    content = f.read()

translations = {
    'en': ['v6.1.0 - Enhanced legacy DOCX and PDF text extraction and import coverage.', 'v6.0.0 - Rebranded to OmniTrace with a new multidimensional forensics logo.'],
    'zh-Hant': ['v6.1.0 - 強化舊版 DOCX 與 PDF 匯入與文字擷取覆蓋率。', 'v6.0.0 - 品牌全新升級為 OmniTrace，並導入發光數據流圖示。'],
    'zh-Hans': ['v6.1.0 - 强化旧版 DOCX 与 PDF 导入与文本提取覆盖率。', 'v6.0.0 - 品牌全新升级为 OmniTrace，并导入发光数据流图标。'],
    'ja': ['v6.1.0 - 以前のDOCXおよびPDFのインポートとテキスト抽出のカバレッジを強化しました。', 'v6.0.0 - OmniTraceにブランド名を変更し、新しい多次元フォレンジックロゴを導入。'],
    'ko': ['v6.1.0 - 기존 DOCX 및 PDF 가져오기 및 텍스트 추출 커버리지를 강화했습니다.', 'v6.0.0 - OmniTrace로 브랜드 변경 및 새로운 다차원 포렌식 로고 도입.'],
    'th': ['v6.1.0 - ปรับปรุงการนำเข้า DOCX และ PDF แบบเก่าและการครอบคลุมการดึงข้อความ', 'v6.0.0 - เปลี่ยนชื่อแบรนด์เป็น OmniTrace พร้อมโลโก้การตรวจสอบหลายมิติใหม่'],
    'ms': ['v6.1.0 - Mempertingkat liputan import dan pengekstrakan teks DOCX dan PDF warisan.', 'v6.0.0 - Menjenamakan semula kepada OmniTrace dengan logo forensik pelbagai dimensi baharu.'],
    'es': ['v6.1.0 - Se mejoró la importación de DOCX y PDF heredados y la cobertura de extracción de texto.', 'v6.0.0 - Cambio de marca a OmniTrace con un nuevo logotipo de análisis multidimensional.'],
    'id': ['v6.1.0 - Meningkatkan cakupan impor dan ekstraksi teks DOCX dan PDF versi lama.', 'v6.0.0 - Ganti nama menjadi OmniTrace dengan logo forensik multidimensi baru.'],
    'ru': ['v6.1.0 - Улучшен импорт старых DOCX и PDF, а также полнота извлечения текста.', 'v6.0.0 - Ребрендинг в OmniTrace с новым многомерным криминалистическим логотипом.'],
    'de': ['v6.1.0 - Verbesserter Import von alten DOCX- und PDF-Dateien sowie höhere Textextraktionsabdeckung.', 'v6.0.0 - Umbenennung in OmniTrace mit einem neuen mehrdimensionalen Forensik-Logo.'],
    'fr': ['v6.1.0 - Amélioration de l\'importation des anciens DOCX et PDF et de la couverture de l\'extraction de texte.', 'v6.0.0 - Changement de marque pour OmniTrace avec un nouveau logo de criminalistique multidimensionnelle.'],
    'pt': ['v6.1.0 - Melhoria na importação de DOCX e PDF antigos e na cobertura de extração de texto.', 'v6.0.0 - Rebranding para OmniTrace com um novo logotipo de forense multidimensional.']
}

for lang, tr in translations.items():
    # We replace changelog1 and changelog2 for each language
    # Match changelog1: "...",
    pattern1 = r"(changelog1:\s*\").*?(\",\s*)"
    # We will use re.sub with a function or just replace the matched text.
    # Wait, in the JS file the key is `changelog1: "..."`
    
    # We need to find the specific block for the language.
    # A robust way is to split the content by language keys or just regex it.
    
    # regex to find the block for lang
    block_pattern = re.compile(rf"('{lang}'|{lang}):\s*{{(.*?)}}", re.DOTALL)
    match = block_pattern.search(content)
    if match:
        block = match.group(2)
        block = re.sub(r'changelog1:\s*".*?"', f'changelog1: "{tr[0]}"', block)
        block = re.sub(r'changelog2:\s*".*?"', f'changelog2: "{tr[1]}"', block)
        content = content[:match.start(2)] + block + content[match.end(2):]

with open('web/seo/home_i18n.js', 'w', encoding='utf-8') as f:
    f.write(content)

# Now update web/index.html fallback
with open('web/index.html', 'r', encoding='utf-8') as f:
    html = f.read()

html = re.sub(r'<span data-home-changelog-1>.*?</span>', f'<span data-home-changelog-1>{translations["en"][0]}</span>', html)
html = re.sub(r'<span data-home-changelog-2>.*?</span>', f'<span data-home-changelog-2>{translations["en"][1]}</span>', html)

with open('web/index.html', 'w', encoding='utf-8') as f:
    f.write(html)

print("Updated JS and HTML changelogs.")
