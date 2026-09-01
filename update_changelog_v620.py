import re

with open('web/seo/home_i18n.js', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('v6.1.0', 'v6.2.0')

with open('web/seo/home_i18n.js', 'w', encoding='utf-8') as f:
    f.write(content)

with open('web/index.html', 'r', encoding='utf-8') as f:
    html = f.read()

html = html.replace('v6.1.0', 'v6.2.0')

with open('web/index.html', 'w', encoding='utf-8') as f:
    f.write(html)
