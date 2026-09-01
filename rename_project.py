import os
import re

dirs_to_process = ['lib', 'web', 'tool', 'assets', 'android', 'ios', 'macos']
root_files = ['README.md', 'DEVLOG.md', 'pubspec.yaml', 'vercel.json']

def replace_in_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except:
        return # Skip binary files or unreadable files

    original = content
    # Case sensitive replacements
    content = content.replace('TruthLens', 'OmniTrace')
    content = content.replace('Truth Lens', 'OmniTrace')
    content = content.replace('truthlens', 'omnitrace')
    content = content.replace('truth-lens', 'omni-trace')
    content = content.replace('truth_lens', 'omni_trace')
    content = content.replace('TRUTHLENS', 'OMNITRACE')

    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")

for root_file in root_files:
    if os.path.exists(root_file):
        replace_in_file(root_file)

for d in dirs_to_process:
    for root, dirs, files in os.walk(d):
        for file in files:
            # skip some binaries or hidden files if needed
            if file.startswith('.') or file.endswith(('.png', '.jpg', '.jpeg', '.so', '.bin', '.db', '.tflite', '.onnx', '.pdf', '.docx', '.zip')):
                continue
            filepath = os.path.join(root, file)
            replace_in_file(filepath)
