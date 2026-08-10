# TruthLens — Schnellstartanleitung（Deutsch）

**Ziel**：Ihre erste Dokumentenanalyse in 5 Minuten abschließen

---

## 1️⃣ App öffnen

### Option A：Web-Version（empfohlen）
```
Browser：https://truthlens.vercel.app
Gerät：Desktop, Tablet oder Mobiltelefon
```
✅ Keine Installation erforderlich  
✅ Nach Modelldownload offline verfügbar  
✅ 100% Datenschutz garantiert

### Option B：Lokale Entwicklung
```bash
git clone https://github.com/hauchiehlin-ops/TruthLens.git
cd TruthLens
flutter pub get
flutter run -d web-server
# Öffnet unter http://localhost:8765
```

---

## 2️⃣ AI-Erkennungsmodelle herunterladen（nur beim ersten Mal）

Wenn Sie die App öffnen, wird ein Einstellungsfeld angezeigt：

```
┌─ Modellinstallation ────────────┐
│ RoBERTa-Detektor (125,8 MB)    │
│ └─ [Download] ✓ Installiert    │
│                                  │
│ Mehrsprachiger Detektor (135 MB)│
│ └─ [Download] ✓ Installiert    │
│                                  │
│ Statistisches Engine (82 MB)    │
│ └─ [Download] Optional         │
│                                  │
│ Adversarial-Verteidigung (135 MB)│
│ └─ [Download] Optional         │
│                                  │
│ LLM-Berichtsgenerierung (1,7 GB)│
│ └─ [Download] Optional         │
└──────────────────────────────────┘
```

**⏱️ Erstes Setup**：ca. 3 Minuten（abhängig von Internetgeschwindigkeit）

**Was wird heruntergeladen？**
- Kernerkennungsmodelle：ca. 350 MB（erforderlich）
- LLM für bessere Berichtserstellung：ca. 1,7 GB（optional）

**Nach Download**：Alle Analysen laufen vollständig offline！✅

---

## 3️⃣ Datei hochladen oder Text einfügen

### Methode 1：Text einfügen
```
1. Klicken Sie auf 「Text einfügen」
2. Drücken Sie Ctrl+V（oder Cmd+V）um Text einzufügen
3. Empfohlen：mindestens 100 Zeichen
```

### Methode 2：Datei hochladen
```
Unterstützte Formate：
• .txt（Textdatei）
• .docx（Word-Datei）
• .pdf（PDF-Datei mit OCR）
```

### Methode 3：Kamera verwenden（Mobil）
```
1. Klicken Sie auf das Kamerasymbol
2. Foto der handschriftlichen Arbeit aufnehmen
3. OCR konvertiert Bild automatisch → Text
```

---

## 4️⃣ Analyse starten

Klicken Sie auf die blaue Schaltfläche **「Analyse」**

```
Status：[████░░░░░░░░░░░░] 25% analysiert...
（in der Regel 2～10 Sekunden, abhängig von der Textlänge）
```

---

## 5️⃣ Bericht überprüfen

### Oberer Abschnitt：**Urteils-Zusammenfassungskarte**
```
╔════════════════════════════════════╗
║  Urteil：Wahrscheinlich AI-generiert ║
║  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  ║
║  AI-Wahrscheinlichkeit：72%         ║
║  Vertrauen：Hoch ✓                 ║
╚════════════════════════════════════╝
```

**📌 Bedeutung**：
- **Urteil**：Gesamtbeurteilung（menschlich / wahrscheinlich menschlich / gemischt / wahrscheinlich AI / AI）
- **Wahrscheinlichkeit**：Sicherheitsgrad für AI-Generierung（0～100%）
- **Vertrauen**：Stimmen alle Erkennungsmodulen überein

---

### Mittlerer Abschnitt：**3-Spalten-Metrikkarten**
```
┌──────────────┬──────────────┬──────────────┐
│  AI-Quote    │ Analyszeit   │  Vertrauen   │
│  ────────    │ ────────     │  ────────   │
│  8/45 (18%)  │  2,3 Sek.    │  92%        │
└──────────────┴──────────────┴──────────────┘
```

**📌 Bedeutung**：
- **AI-Quote**：Wie viele Sätze als AI gekennzeichnet（8 von 45）
- **Analyszeit**：Scanzeit
- **Vertrauen**：Zuverlässigkeit des Gesamtergebnisses

---

### Unterer Abschnitt：**Verdächtige Sätze**
```
【Satz #1】（Seite 3）Risiko：Hoch 🔴 | Vertrauen 85%
  "Die synergistische Paradigmenverschebung ermöglicht..."
  Begründung：Hohe Ähnlichkeit, ungewöhnliche Vokabularkomplexität, rhythmisches Muster

【Satz #2】（Seite 5）Risiko：Mittel 🟡 | Vertrauen 72%
  "Machine-Learning-Algorithmen haben die Revolution ausgelöst..."
  Begründung：Statistische Abweichung, geringe Vokabelvielfalt
```

**📌 Lesart**：
- **Seitennummer**：Position im Dokument
- **Risiko-Farbe**：Rot（hohes Risiko）, Gelb（mittleres Risiko）, Blau（niedriges Risiko）
- **AI-Prozentsatz**：Wahrscheinlichkeit, dass AI es ist（0～100%）
- **Begründung**：Warum das Modell den Satz gekennzeichnet hat

---

## 6️⃣ Ergebnisse interpretieren（Für Lehrer）

### Szenario A：Gesamte AI-Wahrscheinlichkeit > 80%
```
⚠️ Starke Hinweise auf AI-Nutzung
→ Aktion：Verdächtige Sätze genauer untersuchen
→ Weiter：Mit dem Schüler besprechen, ob die Aufgabenrichtlinie AI erlaubt
```

### Szenario B：AI-Wahrscheinlichkeit 50～80%
```
🤔 Gemischte Signale; einige Absätze verdächtig
→ Aktion：Sich auf rot gekennzeichnete Sätze konzentrieren
→ Weiter：Überprüfen, ob sie dem typischen Schreibstil des Schülers entsprechen
```

### Szenario C：AI-Wahrscheinlichkeit < 30%
```
✅ Sieht wie echte Schülerarbeit aus
→ Aktion：Bestehen erwägen oder einige Sätze stichprobenartig überprüfen
→ Hinweis：Auch menschliche Texte können Fehlalarme auslösen
```

---

## 7️⃣ Ergebnisse herunterladen und teilen

### Exportoptionen
```
1. [📄 PDF herunterladen]    → Vollständiger Bericht mit allen Details
2. [📊 CSV exportieren]      → Für Bewertungstabellenkalkulation
3. [📋 Ergebnisse kopieren]  → In E-Mail/LMS einfügen
```

**PDF enthält**：
- Urteils-Zusammenfassung
- Detaillierte Metriken
- Alle verdächtigen Sätze mit Begründungen
- Seitennummern für einfache Referenzierung

---

## ⚙️ Einstellungen anpassen（optional）

Rechtes Panel：Klicken Sie auf **⚙️ Zahnradsymbol**

| Einstellung | Standard | Funktion |
|-----------|----------|----------|
| Modell herunterladen | Automatisch | Erkennungsmodelle neu herunterladen |
| Links überprüfen | An | Überprüfen Sie, ob URLs tatsächlich existieren |
| DOI validieren | An | Überprüfen Sie, ob Zitate existieren（Crossref） |
| Sprache | Automatisch | UI-Sprache wechseln（14 unterstützt） |
| Datenschutzrichtlinie | — | Lesen Sie die 「Null-Upload」-Garantie |

---

## 🆘 Häufige Probleme und Lösungen

### Problem：「Modelldownload fehlgeschlagen」
```
❌ Fehler：RoBERTa-Modell kann nicht heruntergeladen werden
✅ Lösung：
  1. Internet-Verbindung überprüfen
  2. VPN/Proxy deaktivieren
  3. Warten Sie 5 Minuten und versuchen Sie es erneut
  4. Browser-Cache leeren（Ctrl+Shift+Del）
```

### Problem：「Analyse ist sehr langsam」
```
❌ Warten Sie mehr als 30 Sekunden
✅ Lösung：
  1. Erster Lauf ist langsam（Modelle in RAM laden）
  2. Nachfolgende Läufe dauern 2～5 Sekunden
  3. Andere Browser-Registerkarten schließen
  4. Browser neu starten, wenn immer noch langsam
```

### Problem：「Browser sagt 'Speicher läuft aus'」
```
❌ Fehler：Speicher kann nicht zugewiesen werden
✅ Lösung：
  1. Mindestens 2 GB freier RAM erforderlich
  2. Andere Anwendungen schließen
  3. Seite aktualisieren（Cmd/Ctrl + R）
  4. Auf einem Desktop-Computer versuchen
```

---

## ✅ Nächste Schritte

### Für Lehrer
1. ✅ Modelle herunterladen
2. ✅ Mit 1～2 Beispieldokumenten testen
3. ✅ Mit Berichtsformat vertraut machen
4. ✅ Bewertungsrubrik basierend auf AI-Erkennungswerten erstellen
5. ✅ Klassen-Richtlinien bereitstellen

### Für Schuladministratoren
1. ✅ Auf Schulserver bereitstellen（optional, für Offline-Nutzung）
2. ✅ Lehrerhandbuch erstellen
3. ✅ Personalschulung zur Tool-Nutzung
4. ✅ Richtlinie für akademische Integrität mit AI-Erkennung festlegen

### Für Entwickler
1. ✅ Siehe [CLAUDE.md](../CLAUDE.md) für Setup
2. ✅ Siehe [docs/implementation_plan.md](./implementation_plan.md) für Architektur
3. ✅ Siehe [docs/model_integration_testing.md](./model_integration_testing.md) für Modelldetails

---

## 📚 Weitere Ressourcen

| Ressource | Zweck |
|-----------|--------|
| [Vollständige Dokumentation](./implementation_plan.md) | Tief in alle Funktionen eintauchen |
| [Datenschutzrichtlinie](https://truthlens.vercel.app/#/privacy) | Überprüfen Sie, wie wir Daten schützen |
| [Modelliste](./model_integration_testing.md) | Technische Details jedes AI-Modells |
| [Häufig gestellte Fragen](./faq-de.md) | Antworten auf häufig gestellte Fragen |
| [Fehlerbehebung](./troubleshooting-de.md) | Weitere Lösungsmethoden |

---

## 💬 Haben Sie Fragen oder Feedback？

- **Fehler gefunden？** → [GitHub Issues](https://github.com/hauchiehlin-ops/TruthLens/issues)
- **Funktionsanfrage？** → [GitHub Discussions](https://github.com/hauchiehlin-ops/TruthLens/discussions)
- **Andere Fragen？** → hauchieh.lin@gmail.com

---

**Bereit zu analysieren？** → [Öffnen Sie TruthLens jetzt！](https://truthlens.vercel.app)
