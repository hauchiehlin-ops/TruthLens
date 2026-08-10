# TruthLens — Quick Start Guide (English)

**Goal**: Analyze your first document in 5 minutes

---

## 1️⃣ Access the App

### Option A: Web Version (Recommended)
```
Browser: https://truthlens.vercel.app
Device: Desktop, Tablet, or Mobile
```
✅ No installation required  
✅ Works offline after model download  
✅ 100% privacy guaranteed

### Option B: Local Development
```bash
git clone https://github.com/hauchiehlin-ops/TruthLens.git
cd TruthLens
flutter pub get
flutter run -d web-server
# Opens at http://localhost:8765
```

---

## 2️⃣ Download AI Detection Models (First Time Only)

When you open the app, you'll see a settings panel:

```
┌─ Model Installation ─────────────┐
│ RoBERTa Detector (125.8 MB)    │
│ └─ [DOWNLOAD] ✓ Installed      │
│                                  │
│ Multilingual Detector (135 MB) │
│ └─ [DOWNLOAD] ✓ Installed      │
│                                  │
│ Statistical Engine (82 MB)     │
│ └─ [DOWNLOAD] Optional         │
│                                  │
│ Adversarial Defense (135 MB)   │
│ └─ [DOWNLOAD] Optional         │
│                                  │
│ LLM Report Generator (1.7 GB)  │
│ └─ [DOWNLOAD] Optional         │
└──────────────────────────────────┘
```

**⏱️ First-time setup**: ~3 minutes (depends on internet speed)

**What gets downloaded?**
- Core detection models: ~350 MB (required)
- LLM for better report wording: ~1.7 GB (optional)

**After download**: All analysis happens offline! ✅

---

## 3️⃣ Upload or Paste Your Document

### Method 1: Paste Text
```
1. Click "Paste Text" 
2. Ctrl+V (or Cmd+V) your text
3. At least 100 characters recommended
```

### Method 2: Upload File
```
Supported formats:
• .txt (text files)
• .docx (Word documents)
• .pdf (PDF files with OCR)
```

### Method 3: Use Camera (Mobile)
```
1. Tap camera icon
2. Take photo of written work
3. OCR converts image → text automatically
```

---

## 4️⃣ Start Analysis

Click the blue **"Analyze"** button

```
Status: [████░░░░░░░░░░░░] 25% analyzing...
(Usually 2-10 seconds for most documents)
```

---

## 5️⃣ Read the Report

### Top Section: **Summary Card**
```
╔════════════════════════════════════╗
║  VERDICT: Likely AI                ║
║  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  ║
║  AI Probability: 72%               ║
║  Confidence: High ✓                ║
╚════════════════════════════════════╝
```

**📌 What it means:**
- **Verdict**: Overall judgement (Human / Likely Human / Mixed / Likely AI / AI)
- **Probability**: 0-100% confidence it's AI-generated
- **Confidence**: Whether all detection engines agree

---

### Middle Section: **Three Metric Cards**
```
┌──────────────┬──────────────┬──────────────┐
│  AI Ratio    │ Analysis     │  Confidence  │
│  ————────    │ ────────     │  ────────── │
│  8/45 (18%)  │  2.3 seconds │  92%        │
└──────────────┴──────────────┴──────────────┘
```

**📌 What it means:**
- **AI Ratio**: How many sentences are flagged as AI (8 out of 45)
- **Analysis Time**: How long the scan took
- **Confidence**: Reliability of the overall result

---

### Bottom Section: **Suspicious Sentences**
```
【Sentence #1】(Page 3) Risk: High 🔴 | 85% AI
  "The synergistic paradigm shift enables..."
  Reasoning: High similarity, complex vocabulary, unusual rhythm

【Sentence #2】(Page 5) Risk: Medium 🟡 | 72% AI
  "Machine learning algorithms..."
  Reasoning: Statistical deviation, low diversity
```

**📌 How to read:**
- **Page number**: Where in the document to find it
- **Risk color**: Red (high), Yellow (medium), Blue (low)
- **AI percentage**: 0-100% likelihood it's AI
- **Reasoning**: Why the model flagged it

---

## 6️⃣ Interpret Results (For Teachers)

### Scenario A: Overall AI Probability > 80%
```
⚠️ Strong evidence of AI use
→ Action: Deep dive into suspicious sentences
→ Next: Discuss with student if assignment guidelines allow AI
```

### Scenario B: AI Probability 50-80%
```
🤔 Mixed signals; some sections are questionable
→ Action: Focus on red-flagged sentences
→ Next: Check if they align with student's typical writing style
```

### Scenario C: AI Probability < 30%
```
✅ Looks like genuine student work
→ Action: Consider clearing, or spot-check a few sentences
→ Note: Even human work can trigger false positives
```

---

## 7️⃣ Download & Share Results

### Export Options
```
1. [📄 Download PDF]  → Full report with all details
2. [📊 Export CSV]    → For your grading spreadsheet
3. [📋 Copy Results]  → Paste into email/LMS
```

**PDF includes:**
- Summary verdict
- Detailed metrics
- All suspicious sentences with reasoning
- Page numbers for easy reference

---

## ⚙️ Customize Settings (Optional)

Right panel: Click the **⚙️ Gear icon**

| Setting | Default | What it does |
|---------|---------|--------------|
| Model Download | Auto | Re-download detection models |
| Check Links | ON | Verify URLs are real |
| Verify DOI | ON | Check citations exist (Crossref) |
| Language | Auto | Switch UI language (14 options) |
| Privacy Policy | — | Read our zero-upload guarantee |

---

## 🆘 Common Issues & Fixes

### Issue: "Model download fails"
```
❌ Error: Cannot download RoBERTa model
✅ Fix:
  1. Check internet connection
  2. Disable VPN/proxy
  3. Retry in 5 minutes
  4. Clear browser cache (Ctrl+Shift+Del)
```

### Issue: "Analysis is very slow"
```
❌ Waiting 30+ seconds
✅ Fix:
  1. First run is slow (loads models into RAM)
  2. Subsequent runs are 2-5 seconds
  3. Close other browser tabs
  4. Restart browser if still slow
```

### Issue: "Browser says 'Out of memory'"
```
❌ Error: Ran out of RAM
✅ Fix:
  1. Requires 2GB+ free RAM
  2. Close other applications
  3. Refresh page (Cmd/Ctrl + R)
  4. Try on desktop instead of mobile
```

### Issue: "Report shows 'Low Confidence'"
```
❌ Warning: Analysis confidence below 60%
✅ Explanation:
  - Some detection models failed to load
  - Results less reliable; consider re-running
  - Check Model Installation panel
```

---

## ✅ Next Steps

### For Teachers
1. ✅ Download models
2. ✅ Test with 1-2 sample documents
3. ✅ Get familiar with report format
4. ✅ Create grading rubric based on AI detection scores
5. ✅ Roll out to class with guidelines

### For School Admins
1. ✅ Deploy to school server (optional, for offline use)
2. ✅ Create teacher guidelines
3. ✅ Train staff on using the tool
4. ✅ Set academic integrity policy that incorporates AI detection

### For Developers
1. ✅ See [CLAUDE.md](../CLAUDE.md) for setup
2. ✅ Check [docs/implementation_plan.md](./implementation_plan.md) for architecture
3. ✅ Read [docs/model_integration_testing.md](./model_integration_testing.md) for model details

---

## 📚 More Resources

| Resource | Purpose |
|----------|---------|
| [Complete Docs](./implementation_plan.md) | Deep dive into every feature |
| [Privacy Policy](https://truthlens.vercel.app/#/privacy) | How we protect your data |
| [Model List](./model_integration_testing.md) | Technical details of each AI model |
| [FAQ](./faq-en.md) | Answers to common questions |
| [Troubleshooting](./troubleshooting-en.md) | More detailed fixes |

---

## 💬 Questions or Feedback?

- **Found a bug?** → [GitHub Issues](https://github.com/hauchiehlin-ops/TruthLens/issues)
- **Feature request?** → [GitHub Discussions](https://github.com/hauchiehlin-ops/TruthLens/discussions)
- **Questions?** → hauchieh.lin@gmail.com

---

**Ready to analyze?** → [Open TruthLens now!](https://truthlens.vercel.app)
