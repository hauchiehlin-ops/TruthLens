# TruthLens — Panduan Memulai Cepat（Bahasa Melayu）

**Matlamat**：Selesaikan analisis dokumen pertama anda dalam 5 minit

---

## 1️⃣ Buka aplikasi

### Pilihan A：Versi web（disyorkan）
```
Pelayar：https://truthlens.vercel.app
Peranti：Komputer desktop, tablet atau telefon bimbit
```
✅ Tidak memerlukan pemasangan  
✅ Tersedia dalam talian selepas memuat turun model  
✅ 100% privasi dijamin

### Pilihan B：Pembangunan tempatan
```bash
git clone https://github.com/hauchiehlin-ops/TruthLens.git
cd TruthLens
flutter pub get
flutter run -d web-server
# Membuka di http://localhost:8765
```

---

## 2️⃣ Muat turun model pengesanan AI（hanya sekali）

Apabila anda membuka aplikasi, panel konfigurasi akan dipaparkan：

```
┌─ Pemasangan model ──────────────┐
│ Pengesan RoBERTa (125.8 MB)    │
│ └─ [Muat turun] ✓ Dipasang    │
│                                 │
│ Pengesan multibahasa (135 MB) │
│ └─ [Muat turun] ✓ Dipasang    │
│                                 │
│ Enjin statistik (82 MB)       │
│ └─ [Muat turun] Pilihan       │
│                                 │
│ Pertahanan adversarial (135 MB)│
│ └─ [Muat turun] Pilihan       │
│                                 │
│ Penjanaan laporan LLM (1.7 GB)│
│ └─ [Muat turun] Pilihan       │
└────────────────────────────────┘
```

**⏱️ Persediaan awal**：Kira-kira 3 minit（bergantung pada kecepatan internet）

**Apa yang dimuat turun？**
- Model pengesanan teras：~350 MB（diperlukan）
- LLM untuk penjanaan laporan yang lebih baik：~1.7 GB（pilihan）

**Selepas memuat turun**：Semua analisis berjalan sepenuhnya dalam talian！✅

---

## 3️⃣ Muat naik fail atau tampal teks

### Cara 1：Tampal teks
```
1. Klik 「Tampal teks」
2. Tekan Ctrl+V（atau Cmd+V）untuk tampal
3. Disyorkan：Sekurang-kurangnya 100 aksara
```

### Cara 2：Muat naik fail
```
Format yang disokong：
• .txt（fail teks）
• .docx（fail Word）
• .pdf（fail PDF dengan OCR）
```

### Cara 3：Gunakan kamera（mudah alih）
```
1. Sentuh ikon kamera
2. Ambil gambar kerja tulisan tangan anda
3. OCR secara automatik menukar imej → teks
```

---

## 4️⃣ Mulai analisis

Klik butang biru **「Analisis」**

```
Status：[████░░░░░░░░░░░░] 25% sedang dianalisis...
（biasanya 2～10 saat, bergantung pada panjang teks）
```

---

## 5️⃣ Semak laporan

### Bahagian atas：**Kad ringkasan keputusan**
```
╔════════════════════════════════════╗
║  Keputusan：Mungkin dibuat oleh AI  ║
║  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   ║
║  Kebarangkalian AI：72%             ║
║  Keyakinan：Tinggi ✓               ║
╚════════════════════════════════════╝
```

**📌 Makna**：
- **Keputusan**：Penilaian umum（manusia / mungkin manusia / campuran / mungkin AI / AI）
- **Kebarangkalian**：Tahap keyakinan dalam penjanaan AI（0～100%）
- **Keyakinan**：Adakah semua enjin pengesanan bersetuju

---

### Bahagian tengah：**Kad metrik 3 lajur**
```
┌──────────────┬──────────────┬──────────────┐
│  Nisbah AI   │ Masa analisis │  Keyakinan   │
│  ────────    │ ────────     │  ────────   │
│  8/45 (18%)  │  2.3 saat    │  92%        │
└──────────────┴──────────────┴──────────────┘
```

**📌 Makna**：
- **Nisbah AI**：Berapa banyak ayat yang ditandai sebagai AI（8 daripada 45）
- **Masa analisis**：Masa imbasan
- **Keyakinan**：Kebolehpercayaan hasil keseluruhan

---

### Bahagian bawah：**Senarai ayat mencurigakan**
```
【Ayat #1】（halaman 3）Risiko：Tinggi 🔴 | Keyakinan 85%
  "Pergeseran paradigma sinergis membolehkan..."
  Sebab：Kesamaan tinggi, kompleksiti perbendaharaan luar biasa, corak irama

【Ayat #2】（halaman 5）Risiko：Sederhana 🟡 | Keyakinan 72%
  "Algoritma pembelajaran mesin memulai revolusi..."
  Sebab：Sisihan statistik, kepelbagaian perbendaharaan rendah
```

**📌 Cara membaca**：
- **Nombor halaman**：Kedudukan dalam dokumen
- **Warna risiko**：Merah（risiko tinggi）, kuning（risiko sederhana）, biru（risiko rendah）
- **Peratus AI**：Kebarangkalian itu adalah AI（0～100%）
- **Sebab**：Mengapa model menandai ayat ini

---

## 6️⃣ Tafsirkan hasil（Untuk guru）

### Senario A：Kebarangkalian AI keseluruhan > 80%
```
⚠️ Bukti kukuh penggunaan AI
→ Tindakan：Periksa ayat mencurigakan dengan teliti
→ Seterusnya：Berbincang dengan pelajar tentang sama ada dasar membenarkan AI
```

### Senario B：Kebarangkalian AI 50～80%
```
🤔 Isyarat bercampur; beberapa perenggan mencurigakan
→ Tindakan：Fokus pada ayat yang ditandai merah
→ Seterusnya：Periksa sama ada ia sepadan dengan gaya penulisan pelajar yang khas
```

### Senario C：Kebarangkalian AI < 30%
```
✅ Kelihatan seperti kerja asli pelajar
→ Tindakan：Pertimbangkan untuk meluluskan atau periksa beberapa ayat
→ Catatan：Teks manusia juga boleh mempunyai positif palsu
```

---

## 7️⃣ Muat turun dan kongsikan keputusan

### Pilihan eksport
```
1. [📄 Muat turun PDF]     → Laporan lengkap dengan semua butiran
2. [📊 Eksport CSV]        → Untuk hamparan penggredan
3. [📋 Salin keputusan]    → Untuk tampal dalam email/LMS
```

**PDF termasuk**：
- Ringkasan keputusan
- Metrik terperinci
- Semua ayat mencurigakan dan sebab
- Nombor halaman untuk rujukan mudah

---

## ⚙️ Sesuaikan tetapan（pilihan）

Panel kanan：Klik **⚙️ ikon gear**

| Tetapan | Lalai | Fungsi |
|--------|-------|--------|
| Muat turun model | Automatik | Muat turun semula model pengesanan |
| Periksa pautan | Didayakan | Sahkan URL benar-benar wujud |
| Sah DOI | Didayakan | Sahkan petikan wujud（Crossref） |
| Bahasa | Automatik | Tukar bahasa UI（14 disokong） |
| Dasar privasi | — | Baca jaminan 「sifar muat naik」 |

---

## 🆘 Masalah umum dan penyelesaian

### Masalah：「Kegagalan muat turun model」
```
❌ Ralat：Tidak dapat memuat turun model RoBERTa
✅ Penyelesaian：
  1. Periksa sambungan internet
  2. Lumpuhkan VPN/proksi
  3. Tunggu 5 minit dan cuba lagi
  4. Kosongkan cache pelayar（Ctrl+Shift+Del）
```

### Masalah：「Analisis sangat perlahan」
```
❌ Menunggu lebih daripada 30 saat
✅ Penyelesaian：
  1. Larian pertama perlahan（memuatkan model ke RAM）
  2. Larian seterusnya mengambil 2～5 saat
  3. Tutup tab pelayar lain
  4. Mulai semula pelayar jika tetap perlahan
```

### Masalah：「Pelayar berkata 'ingatan tidak mencukupi'」
```
❌ Ralat：Tidak dapat memperuntukkan ingatan
✅ Penyelesaian：
  1. Minimum 2 GB RAM bebas diperlukan
  2. Tutup aplikasi lain
  3. Muat semula halaman（Cmd/Ctrl + R）
  4. Cuba di komputer desktop
```

---

## ✅ Langkah seterusnya

### Untuk guru
1. ✅ Muat turun model
2. ✅ Uji dengan 1～2 dokumen sampel
3. ✅ Biasakan diri dengan format laporan
4. ✅ Buat rubrik penggredan berdasarkan skor pengesanan AI
5. ✅ Edarkan garis panduan kelas

### Untuk pentadbir sekolah
1. ✅ Gunakan di pelayan sekolah（pilihan, untuk penggunaan dalam talian）
2. ✅ Buat panduan guru
3. ✅ Latih kakitangan dalam penggunaan alat
4. ✅ Tetapkan dasar integriti akademik dengan pengesanan AI

### Untuk pemaju
1. ✅ Lihat [CLAUDE.md](../CLAUDE.md) untuk persediaan
2. ✅ Lihat [docs/implementation_plan.md](./implementation_plan.md) untuk seni bina
3. ✅ Lihat [docs/model_integration_testing.md](./model_integration_testing.md) untuk butiran model

---

## 📚 Sumber tambahan

| Sumber | Tujuan |
|--------|--------|
| [Dokumentasi lengkap](./implementation_plan.md) | Selami semua ciri |
| [Dasar privasi](https://truthlens.vercel.app/#/privacy) | Sahkan cara kami melindungi data |
| [Senarai model](./model_integration_testing.md) | Butiran teknikal setiap model AI |
| [Soalan lazim](./faq-ms.md) | Jawapan kepada soalan lazim |
| [Penyelesaian masalah](./troubleshooting-ms.md) | Kaedah penyelesaian masalah lebih terperinci |

---

## 💬 Adakah anda mempunyai soalan atau ulasan？

- **Temui pepijat？** → [GitHub Issues](https://github.com/hauchiehlin-ops/TruthLens/issues)
- **Permintaan ciri？** → [GitHub Discussions](https://github.com/hauchiehlin-ops/TruthLens/discussions)
- **Soalan lain？** → hauchieh.lin@gmail.com

---

**Bersedia untuk menganalisis？** → [Buka TruthLens sekarang！](https://truthlens.vercel.app)
