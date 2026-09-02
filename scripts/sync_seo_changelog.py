import sys
import re

if len(sys.argv) < 3:
    print("Usage: python3 sync_seo_changelog.py <version> <message>")
    sys.exit(1)

raw_version = sys.argv[1]
message = sys.argv[2]

m = re.match(r'^([0-9]+\.[0-9]+\.[0-9]+)', raw_version)
if not m:
    sys.exit(0)
version = f"v{m.group(1)}"

new_changelog = f"{version} - {message}"

with open('web/seo/home_i18n.js', 'r', encoding='utf-8') as f:
    js_content = f.read()

def update_js(content, new_text):
    lines = content.split('\n')
    out_lines = []
    current_c1 = None
    for line in lines:
        m1 = re.search(r'(changelog1:\s*)(["\'])(.*?)\2(,?)', line)
        m2 = re.search(r'(changelog2:\s*)(["\'])(.*?)\2(,?)', line)
        if m1:
            current_c1 = m1.group(3)
            new_line = line[:m1.start(3)] + new_text + line[m1.end(3):]
            out_lines.append(new_line)
        elif m2 and current_c1 is not None:
            new_line = line[:m2.start(3)] + current_c1 + line[m2.end(3):]
            out_lines.append(new_line)
            current_c1 = None
        else:
            out_lines.append(line)
    return '\n'.join(out_lines)

new_js = update_js(js_content, new_changelog)
with open('web/seo/home_i18n.js', 'w', encoding='utf-8') as f:
    f.write(new_js)

with open('web/index.html', 'r', encoding='utf-8') as f:
    html_content = f.read()

def update_html(content, new_text):
    m1 = re.search(r'(<span data-home-changelog-1>)(.*?)(</span>)', content)
    if m1:
        current_c1 = m1.group(2)
        # Using lambda to avoid regex escape issues with the replacement text
        content = re.sub(
            r'(<span data-home-changelog-2>)(.*?)(</span>)', 
            lambda match: f"{match.group(1)}{current_c1}{match.group(3)}", 
            content
        )
        content = re.sub(
            r'(<span data-home-changelog-1>)(.*?)(</span>)', 
            lambda match: f"{match.group(1)}{new_text}{match.group(3)}", 
            content
        )
    return content

new_html = update_html(html_content, new_changelog)
with open('web/index.html', 'w', encoding='utf-8') as f:
    f.write(new_html)

print(f"Synced SEO changelog with {version}")
