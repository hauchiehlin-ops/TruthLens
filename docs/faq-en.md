# TruthLens — Frequently Asked Questions (FAQ)

## General Questions

### Q: Is TruthLens free?
**A:** Yes! Completely free and open-source. No subscriptions, no ads, no hidden fees.

### Q: Where is my data stored?
**A:** Nowhere on our servers. All analysis happens on your device. Your analysis history is stored only in your browser's local storage (SQLite). You can delete it anytime in settings.

### Q: How accurate is TruthLens?
**A:** 95%+ accuracy on our test dataset (HC3 + educational texts). See our [accuracy guarantee](../docs/accuracy-guarantee-system.md) for details.

### Q: Does TruthLens work offline?
**A:** Yes! After downloading models, analysis works 100% offline. Optional features (link verification, DOI checking) need internet but can be disabled.

### Q: What languages does it support?
**A:** 
- Detection: 104+ languages (via XLM-RoBERTa)
- Interface: 14 languages (English, Chinese, Japanese, Korean, German, Spanish, French, Portuguese, Russian, Indonesian, Malay, Thai, Vietnamese, Arabic)

---

## Installation & Setup

### Q: Do I need to install anything?
**A:** No. TruthLens is a web app. Just open https://truthlens.vercel.app in your browser.

### Q: Can I run it offline?
**A:** Yes! Deploy `build/web/` to your school server or use GitHub Pages. See [docs/deployment.md](./deployment.md).

### Q: Why does it ask to download models on first use?
**A:** The AI detection models (~350 MB) must be downloaded once. They're then stored locally and used for all future analyses. This ensures privacy—no model or code runs on our servers.

### Q: How long does model download take?
**A:** Typically 2-5 minutes depending on your internet speed. After that, every analysis is instantaneous (2-10 seconds).

---

## Analysis & Results

### Q: Why do I get different results for the same text?
**A:** 
1. **Model updates**: New models might give slightly different results
2. **Context changes**: Longer context (surrounding text) affects predictions
3. **Engine availability**: If some engines fail to load, results differ
4. Check "Engine Contribution" card to see which engines participated

### Q: What does "Low Confidence" mean?
**A:** One or more detection engines failed to load, OR you're using very short text (<50 characters). The result is less reliable. 

**Fix:**
- Check Model Installation panel
- Try with longer text
- Refresh page and re-analyze

### Q: Can I trust 100% AI results?
**A:** 95-100% AI probability is highly reliable. However, always pair with other tools (TurnItIn, manual review). We recommend 95%+ as the decision threshold for schools.

### Q: What if the result says "Mixed Content"?
**A:** Your text has both human and AI sections. This is common when students:
- Use AI for brainstorming, then write sections themselves
- Use AI to refine their own writing

**Action**: Check the suspicious sentences list to pinpoint which parts are questionable.

---

## Models & Engines

### Q: What are the 4 detection engines?
**A:** 
1. **Transformer (RoBERTa)** — Semantic analysis (40% weight)
2. **Statistical (DistilGPT2)** — Perplexity/burstiness metrics (25% weight)
3. **Stylometry** — Writing style analysis (20% weight, built-in)
4. **Adversarial** — Paraphrase/rewrite detection (15% weight, optional)

See [model_integration_testing.md](./model_integration_testing.md) for details.

### Q: Can I disable certain engines?
**A:** Yes! Go to Settings → Model Management → toggle engines on/off.

### Q: What's "ESL Adjustment"?
**A:** If we detect non-native English writing, we reduce the Statistical engine's weight (lower perplexity doesn't mean AI, just language learning). Automatic.

### Q: Do I need all models installed?
**A:** No. Only Stylometry is required (it's built-in). Other models are optional:
- Transformer: Highly recommended (best accuracy)
- Statistical: Recommended (adds detection resilience)
- Adversarial: Optional (catches paraphrase attacks)

---

## Privacy & Security

### Q: Is my document really never uploaded?
**A:** Core AI analysis happens locally in your browser using JavaScript/WebAssembly, and the complete document is not uploaded. If optional citation verification is enabled, only detected URLs, DOI values, or individual citation fields (author, title, year, and venue) are sent to public bibliographic services. Web OCR may also send selected images or PDF page images to Gemini only when you configure that fallback.

### Q: Do you store my analysis results?
**A:** No. Results are stored only in your browser (SQLite). You can delete them anytime.

### Q: What about model updates and link verification?
**A:** 
- **Model updates**: We send only the version number (not your document)
- **Link verification**: We check if URLs are reachable (URL only, not your content)
- **Citation verification**: We query Crossref, OpenAlex, DataCite, Semantic Scholar, Europe PMC/PubMed/AGRICOLA, ERIC, DOAJ, and publisher catalogs with a DOI or individual citation fields (not the complete document). Google Scholar is provided only as a user-initiated manual lookup because it does not offer automated API access

All can be disabled in settings.

### Q: Is TruthLens GDPR/FERPA compliant?
**A:** Yes. No personal data is collected. No cookies. No tracking. See [Privacy Policy](../README.md#-隐私保证) for full details.

### Q: Can I use this for schools in [my country]?
**A:** Probably! TruthLens has no data retention, no tracking, and complies with GDPR, FERPA (US), and similar regulations. Consult your IT/privacy officer.

---

## Troubleshooting

### Q: My model download keeps failing
**A:** 
1. Check your internet connection
2. Try disabling VPN/proxy
3. Wait 5 minutes and retry
4. Clear browser cache (Ctrl+Shift+Del)
5. If still failing, email support

### Q: Analysis is taking too long
**A:** 
1. **First run?** Loading models into RAM can take 5-10 seconds. Subsequent runs are fast.
2. **Slow device?** Close other browser tabs. Requires 2GB+ RAM.
3. **Very long document?** 10,000+ character documents may take 15-30 seconds.

### Q: Browser says "Out of Memory"
**A:** 
1. Requires minimum 2GB free RAM
2. Close other applications
3. Refresh page (Cmd/Ctrl + R)
4. Try on a desktop computer instead

### Q: I got a different result after updating my browser
**A:** Browser updates sometimes change WebAssembly performance. Re-download models if using different browser.

---

## Advanced Questions

### Q: Can I batch analyze 100+ documents?
**A:** 
- **Current**: Upload one at a time
- **Coming soon**: Batch analysis via admin panel
- **Now**: Write a Python script using our API (see GitHub)

### Q: Can I integrate TruthLens into my LMS?
**A:** 
- **Canvas/Blackboard**: Coming soon via LTI integration
- **Now**: Manual upload or copy/paste results

### Q: Can I use TruthLens as an API?
**A:** 
- **Public API**: Not yet
- **Self-hosted**: Yes. Build `build/web/`, deploy your own instance, call detection endpoints directly

### Q: How do I report a false positive?
**A:** 
1. Screenshot the result
2. Include the original text
3. Email: support@truthlens.dev or GitHub Issues

We use your feedback to improve the model.

---

## Educator-Specific Questions

### Q: Should I tell students about TruthLens?
**A:** **Yes!** Transparency is best. Tell them:
- "We use AI detection tools"
- "AI use isn't automatically disallowed, but must be disclosed"
- "We check for undisclosed AI use"

### Q: What if a student disputes the result?
**A:** 
1. Show the "Suspicious Sentences" list
2. Discuss why those specific sentences are flagged
3. Check if they match the student's typical writing
4. Offer to re-analyze if they revise
5. If still disputed, use secondary confirmation (Turnitin, manual review)

### Q: Can I use this for placement exams?
**A:** Yes, but combine with multiple signals:
- TruthLens (AI detection)
- Turnitin (plagiarism)
- Manual review
- Student interview (for borderline cases)

### Q: How do I explain results to parents?
**A:** Use this simple explanation:
> "We use AI detection to ensure academic integrity. This tool checks if essays show signs of AI generation. A high score doesn't automatically mean the student cheated—it just means we need to discuss it."

---

## Account & Support

### Q: Do I need an account?
**A:** No. TruthLens requires no login, no account, no email. Just open and use.

### Q: How do I get support?
**A:** 
- **Bugs**: [GitHub Issues](https://github.com/hauchiehlin-ops/TruthLens/issues)
- **Questions**: Email hauchieh.lin@gmail.com
- **Ideas**: [GitHub Discussions](https://github.com/hauchiehlin-ops/TruthLens/discussions)

### Q: Can I contribute to TruthLens?
**A:** Yes! We're open-source. See [CLAUDE.md](../CLAUDE.md) for contributing guidelines.

---

**Last updated**: 2026-08-10  
**Questions not answered?** [Open an issue](https://github.com/hauchiehlin-ops/TruthLens/issues/new)
