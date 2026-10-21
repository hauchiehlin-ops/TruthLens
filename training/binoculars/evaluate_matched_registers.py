"""同題材、同語域語料上比較 Binoculars 與裸困惑度（見 eval_matched/README.md）。

用法：
    .venv/bin/python binoculars/evaluate_matched_registers.py binoculars eval_dir \\
        "Qwen/Qwen2.5-1.5B|Qwen/Qwen2.5-1.5B-Instruct" proposal.txt

eval_dir 需含 csl_human_zh.jsonl、ai_zh_claude.jsonl、ai_en_claude.jsonl，以及由本機論文
PDF 抽出的 human_en.jsonl（出版社著作不收錄於 repo）。proposal.txt 為待測長文的純文字。
"""
import sys, json, re, time
from pathlib import Path
import numpy as np, torch
from sklearn.metrics import roc_auc_score
sys.path.insert(0, sys.argv[1])  # training/binoculars
from run_binoculars import score_text, load_pair
ev = Path(sys.argv[2]); pairs = sys.argv[3].split(',')
def load(p): return [json.loads(l) for l in open(p, encoding='utf8')]
proposal = open(sys.argv[4], encoding='utf8').read()
paras = [p.strip() for p in proposal.split('\n') if len(p.strip()) >= 60]
chunks, buf = [], ''
for p in paras:
    buf += p
    if len(buf) >= 300: chunks.append(buf); buf = ''
groups = {
  'zh_human_csl': [r['text'] for r in load(ev/'csl_human_zh.jsonl')],
  'zh_ai_matched': [r['text'] for r in load(ev/'ai_zh_claude.jsonl')],
  'zh_ai_proposal': chunks[:30],
  'en_human': [r['text'] for r in load(ev/'human_en.jsonl')],
  'en_ai_matched': [r['text'] for r in load(ev/'ai_en_claude.jsonl')],
}
results = {}
for pair in pairs:
    obs, perf = pair.split('|')
    dtype = torch.float16 if '1.5B' in obs else torch.float32
    tok, o, pf = load_pair(obs, perf, 'mps', dtype)
    scores = {}
    t0 = time.time()
    for g, texts in groups.items():
        scores[g] = [s for s in (score_text(t, tok, o, pf, 'mps', 512) for t in texts) if s]
    def metric(h, a, key):
        hs = np.array([s[key] for s in scores[h]]); as_ = np.array([s[key] for s in scores[a]])
        y = np.r_[np.zeros(len(hs)), np.ones(len(as_))]; x = -np.r_[hs, as_]  # lower = AI
        thr = hs.min()  # strictest: no human below threshold
        return {'auroc': round(float(roc_auc_score(y, x)), 3), 'recall_at_0fp': round(float((as_ < thr).mean()), 3),
                'human_median': round(float(np.median(hs)), 3), 'ai_median': round(float(np.median(as_)), 3), 'n': [len(hs), len(as_)]}
    res = {}
    for key in ['binoculars', 'log_perplexity']:
        res[key] = {
          'zh_matched': metric('zh_human_csl', 'zh_ai_matched', key),
          'zh_proposal_vs_csl': metric('zh_human_csl', 'zh_ai_proposal', key),
          'en_matched': metric('en_human', 'en_ai_matched', key),
        }
    res['seconds'] = round(time.time() - t0, 1)
    results[pair] = res
    print(json.dumps({pair: res}, ensure_ascii=False, indent=1), flush=True)
    del o, pf; torch.mps.empty_cache()
json.dump(results, open(ev/'binoculars_results.json', 'w'), ensure_ascii=False, indent=1)
