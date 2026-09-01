import glob
import re
import os

for html_file in glob.glob('web/**/*.html', recursive=True):
    with open(html_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Replace <li><strong>v4.13.10</strong> - <span data-home-changelog-1>...</span></li>
    # with <li><span data-home-changelog-1>Improved DOCX piece table parsing for better text extraction accuracy.</span></li>
    
    # Using regex to catch any variation
    content = re.sub(r'<li>\s*<strong>v4\.13\.10</strong>\s*-\s*<span data-home-changelog-1>', r'<li><span data-home-changelog-1>', content)
    content = re.sub(r'<li>\s*<strong>v4\.13\.9</strong>\s*-\s*<span data-home-changelog-2>', r'<li><span data-home-changelog-2>', content)

    with open(html_file, 'w', encoding='utf-8') as f:
        f.write(content)
    
print("Fixed HTML files")
