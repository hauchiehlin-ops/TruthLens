# TruthLens — Troubleshooting Guide

## 🔴 Critical Issues

### ❌ App Won't Load / Blank Screen
**Symptoms**: Browser shows blank page or "Loading..." forever

**Fix**:
```
Step 1: Hard refresh (Ctrl+Shift+R on Windows/Linux, Cmd+Shift+R on Mac)
Step 2: Clear browser cache
        • Chrome: Settings → Privacy → Clear browsing data
        • Safari: Develop → Empty Caches
Step 3: Try different browser (Chrome, Firefox, Safari, Edge)
Step 4: Check internet connection
Step 5: Wait 5 minutes and retry (server might be down)
```

**If still broken**: 
- Check [GitHub Status](https://github.com/hauchiehlin-ops/TruthLens/issues) for outages
- Email: support@truthlens.dev

---

### ❌ "Out of Memory" Error
**Symptoms**: Browser crash, "Unable to allocate memory", or grey screen

**Root causes**:
- Device has < 2GB free RAM
- Browser has too many tabs/extensions
- Long document (10,000+ characters)

**Fix** (Priority order):
```
1. Close ALL other browser tabs
2. Close other applications (Slack, Teams, Mail, etc.)
3. Restart your browser completely
4. If mobile: Close the app and reopen
5. Try on a desktop computer instead
6. Upgrade browser to latest version
7. If still failing: Try with shorter document (< 5,000 chars)
```

**Permanent fix**: Allocate more RAM to browser or use computer with more RAM

---

### ❌ "Model Not Installed" Error (Analysis Won't Start)
**Symptoms**: Can't click "Analyze" button, or says "Model not installed"

**Root causes**:
- Models haven't been downloaded yet
- Download was interrupted
- Models became corrupted

**Fix**:
```
Step 1: Go to Settings (⚙️ icon, top right)
Step 2: Under "Model Management", click [DOWNLOAD] for each model
Step 3: Wait until all show "✓ Installed"
Step 4: If download hangs > 2 minutes:
   ├─ Pause and retry
   ├─ Check internet speed (need > 1 Mbps)
   └─ If still hangs: Proceed to next section
```

**If download keeps failing**:
→ See "Model Download Fails" section below

---

## 🟡 Common Issues

### Model Download Fails
**Symptoms**: Download starts but stops with "Connection error" or "Failed"

**Root causes**:
- Slow internet (<1 Mbps)
- VPN/proxy blocking
- Browser cache corrupted
- ISP throttling

**Fix** (Try in order):
```
1. Disable VPN/proxy
2. Pause all other downloads (YouTube, etc.)
3. Clear browser cache (Ctrl+Shift+Del)
4. Close other browser tabs
5. Switch networks (WiFi ↔ Mobile hotspot)
6. Try different browser
7. Wait 30 minutes and retry (possible rate-limiting)
```

**Still failing?** Check your internet:
```bash
# Open Terminal/Command Prompt
ping huggingface.co  # Should see "time=X ms"
              # If "Unreachable" = network problem
```

---

### Analysis is Very Slow (>15 seconds)
**Symptoms**: Page shows "Analyzing..." for 15+ seconds

**Common causes** (in order of likelihood):
```
1. FIRST RUN (most common!)
   └─ Analyzing first time = loading models into RAM (~5-10s)
   └─ Fix: This is normal. Subsequent analyses will be 2-3s

2. Very long document (10,000+ characters)
   └─ 10,000 chars = ~20s
   └─ 5,000 chars = ~10s
   └─ Fix: Try shorter document

3. Low-end device
   └─ Old laptop or mobile with 2GB RAM
   └─ Fix: Close other applications

4. One or more engines failing
   └─ Show "not loaded" in engine list
   └─ Fix: Re-download that model

5. Browser using excessive memory
   └─ Many tabs/extensions
   └─ Fix: Close tabs, restart browser

6. Server overload (rare)
   └─ Fix: Wait 1 hour and retry
```

**Debug slowness**:
```
1. Open Settings (⚙️)
2. Check "Engine Status"
3. Look for red ❌ (failed engines)
4. Re-download any failed engines
5. Retry analysis
```

---

### Low Confidence Warning
**Symptoms**: Report shows "⚠️ Low Confidence (< 60%)"

**Meaning**: One or more detection engines couldn't load, so result may be unreliable

**Fix**:
```
Step 1: Go to Settings → Model Management
Step 2: Identify which models show "❌ Failed" or "⚠️ Not Installed"
Step 3: Click [DOWNLOAD] to re-install
Step 4: After downloading, re-analyze the text
```

**If still low confidence**:
- Text too short (< 50 characters) → Try longer text
- Device out of memory → Close other apps
- Browser cache corrupted → Clear cache and refresh

---

### Results Differ Each Time I Analyze
**Symptoms**: Same text gives different AI scores on different days

**Why this happens** (normal):
```
Possible reasons:
├─ Model version updated (we improve models weekly)
├─ Different engines available (some might not load)
├─ Context changed (surrounding text affects predictions)
└─ Statistical variance (models use randomness)
```

**This is OK**: Results typically vary by ±5% (e.g., 75% → 80%). Larger swings (75% → 60%) suggest engine instability.

**Fix**: If swings > 10%, check Engine Status in Settings

---

### Browser Keeps Crashing
**Symptoms**: App works briefly then browser closes/restarts

**Causes**:
- Out of memory (see section above)
- Browser bug (out of date)
- Conflicting extension

**Fix**:
```
1. Disable browser extensions one by one
   └─ Restart browser after each
2. Update browser to latest version
   └─ Chrome: Menu → Help → About
3. Try different browser
4. If only happens on this device: Upgrade RAM or device
```

---

## 🟢 Performance Issues

### Page Loads Slowly
**Symptoms**: Takes 5+ seconds to reach the input screen

**Causes**:
- Slow internet
- Browser startup slow
- First-time page load (downloads JS)

**Fix**:
```
1. Faster internet (5+ Mbps)
2. Close other applications
3. Use Chrome or Firefox (faster than Safari/Edge)
4. Check browser extensions (disable unused ones)
5. Bookmark the page for faster loading next time
```

---

### Analysis Results Show False Positives
**Symptoms**: Human-written text marked as 80%+ AI

**Why**: Happens sometimes with:
- Academic writing (formal tone = AI-like)
- Non-native speaker (unusual phrasing)
- Technical writing (specific terminology)
- Poetry or creative writing (unusual structure)

**Fix**:
```
1. Cross-check with other tools (Turnitin, GPTZero)
2. Check individual sentences (some might be human)
3. Ask yourself: "Does this match the student's ability?"
4. When in doubt, discuss with the student
5. Report false positives so we improve
```

**Report false positive**:
- Go to: [GitHub Issues](https://github.com/hauchiehlin-ops/TruthLens/issues/new)
- Include: Original text + screenshot of result
- We'll analyze and improve the models

---

### Analysis Shows "False Negative" (Missed AI)
**Symptoms**: Text you know is AI marked as human

**Causes**:
- AI text heavily paraphrased (rewritten with paraphrase tools)
- AI model detecting model (GPT-4 output sometimes tricks detectors)
- Text from very new AI (trained after our models)

**Fix**:
```
1. Re-download models (we update weekly)
2. Use secondary tools (Turnitin, TurnItIn)
3. Check for other signals:
   ├─ Unusual writing for this student
   ├─ Style doesn't match their past work
   ├─ Formatting/structure too perfect
   └─ Admits to using AI
```

**Report missed AI**: Same as false positive (GitHub Issues)

---

## 🔵 Settings & Configuration

### How to Access Settings
```
1. Click ⚙️ icon (top right, next to Home)
2. Right sidebar opens
3. Scroll to see all options
```

### Settings Panel Doesn't Appear
**Symptoms**: Click ⚙️ but nothing happens

**Fix**:
```
1. Refresh page (Cmd/Ctrl + R)
2. Check if sidebar is hidden (small screen = vertical layout)
3. Make browser window wider if on mobile/tablet
```

---

### "Check Links" Verification Takes Too Long
**Symptoms**: After analysis, checking links takes 30+ seconds

**Why**: We verify every URL by attempting connection (your internet speed matters)

**Fix**:
```
Option 1: Disable link checking
  ├─ Go to Settings
  ├─ Turn OFF "Check Links"
  └─ Re-analyze

Option 2: Faster internet
  └─ Use 5+ Mbps connection
```

---

### "Verify DOI" Fails
**Symptoms**: Says "DOI verification failed" at the bottom

**Why**: Crossref API might be down or URL is invalid

**Fix**:
```
1. Check your internet connection
2. Verify DOI is correctly formatted (e.g., 10.1234/xyz)
3. Disable DOI verification in Settings if not needed
4. If Crossref is down: Wait and retry in 1 hour
```

---

## 📱 Mobile-Specific Issues

### Touchscreen Not Responsive
**Symptoms**: Can't tap buttons or input fields

**Fix**:
```
1. Wait 2 seconds after page loads
2. Tap in the middle of buttons, not edges
3. Try pinch-zooming out and back in
4. Restart browser completely
5. Update mobile browser to latest version
```

---

### Camera (OCR) Doesn't Work
**Symptoms**: Camera icon greyed out or camera won't open

**Causes**:
- Browser doesn't have camera permission
- Device doesn't have camera

**Fix**:
```
1. Go to Phone Settings
2. Find "App Permissions"
3. Search for your browser (Chrome/Safari/Firefox)
4. Ensure "Camera" is enabled
5. Restart browser
6. Try camera again
```

---

### Mobile Screen Too Small
**Symptoms**: Can't read text or buttons are cramped

**Fix**:
```
1. Rotate phone to landscape (wider)
2. Pinch-zoom out a bit (less magnified)
3. Use tablet or desktop if available
   └─ Mobile is supported but desktop is optimal
```

---

## 🌐 Network & Connectivity

### VPN / Proxy Blocking
**Symptoms**: "Connection error" or "Cannot reach models"

**Why**: Some proxies block HuggingFace/GitHub URLs

**Fix**:
```
1. Temporarily disable VPN/proxy
2. Download models once
3. Re-enable VPN (models are cached locally, won't need internet)
4. Tell your IT: Whitelist:
   - huggingface.co
   - github.com
   - api.crossref.org (for DOI verification)
```

---

### Offline Mode
**Symptoms**: No internet available, want to use TruthLens

**Solution**:
```
✅ You CAN analyze if:
  └─ Stylometry engine is installed (it's built-in)
  
❌ You CANNOT if:
  └─ Models haven't been downloaded yet
  
How to use offline:
1. Download all models while online
2. Close browser without clearing cache
3. Go offline
4. Reopen TruthLens in same browser
5. Analysis works (except link/DOI verification)
```

---

## 🆘 Still Not Fixed?

### Before Contacting Support
```
1. ✅ Hard refresh page (Ctrl+Shift+R)
2. ✅ Clear browser cache
3. ✅ Try different browser
4. ✅ Check internet speed (speedtest.net)
5. ✅ Re-download all models
6. ✅ Check [existing issues](https://github.com/hauchiehlin-ops/TruthLens/issues)
```

### How to Get Help
**Option 1: GitHub Issues** (best for bugs)
```
1. Go to https://github.com/hauchiehlin-ops/TruthLens/issues
2. Click "New Issue"
3. Include:
   ├─ Browser/OS version
   ├─ Error message (screenshot)
   ├─ Steps to reproduce
   └─ Your RAM/internet speed
```

**Option 2: Email Support**
```
Email: support@truthlens.dev
Include:
  ├─ What were you trying to do?
  ├─ What went wrong?
  ├─ Screenshot of error
  └─ Browser/device info
```

**Option 3: GitHub Discussions**
```
https://github.com/hauchiehlin-ops/TruthLens/discussions
(For questions, not bugs)
```

---

**Last updated**: 2026-08-10  
**Can't find your issue?** [Start a discussion](https://github.com/hauchiehlin-ops/TruthLens/discussions/new)
