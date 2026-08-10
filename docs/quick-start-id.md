# TruthLens — Panduan Memulai Cepat（Bahasa Indonesia）

**Tujuan**：Selesaikan analisis dokumen pertama Anda dalam 5 menit

---

## 1️⃣ Buka aplikasi

### Opsi A：Versi web（direkomendasikan）
```
Browser：https://truthlens.vercel.app
Perangkat：Desktop, tablet, atau ponsel
```
✅ Tidak memerlukan instalasi  
✅ Tersedia offline setelah mengunduh model  
✅ 100% privasi terjamin

### Opsi B：Pengembangan lokal
```bash
git clone https://github.com/hauchiehlin-ops/TruthLens.git
cd TruthLens
flutter pub get
flutter run -d web-server
# Membuka di http://localhost:8765
```

---

## 2️⃣ Unduh model deteksi AI（hanya sekali）

Saat membuka aplikasi, panel konfigurasi akan ditampilkan：

```
┌─ Instalasi model ──────────────┐
│ Detektor RoBERTa (125,8 MB)   │
│ └─ [Unduh] ✓ Terinstal        │
│                                │
│ Detektor multibahasa (135 MB) │
│ └─ [Unduh] ✓ Terinstal        │
│                                │
│ Mesin statistik (82 MB)       │
│ └─ [Unduh] Opsional          │
│                                │
│ Pertahanan adversarial (135 MB)│
│ └─ [Unduh] Opsional          │
│                                │
│ Pembuatan laporan LLM (1.7 GB)│
│ └─ [Unduh] Opsional          │
└────────────────────────────────┘
```

**⏱️ Pengaturan awal**：Sekitar 3 menit（tergantung kecepatan internet）

**Apa yang diunduh？**
- Model deteksi inti：~350 MB（diperlukan）
- LLM untuk pembuatan laporan lebih baik：~1,7 GB（opsional）

**Setelah mengunduh**：Semua analisis berjalan sepenuhnya offline！✅

---

## 3️⃣ Unggah file atau tempel teks

### Cara 1：Tempel teks
```
1. Klik 「Tempel teks」
2. Tekan Ctrl+V（atau Cmd+V）untuk menempel
3. Disarankan：Minimal 100 karakter
```

### Cara 2：Unggah file
```
Format yang didukung：
• .txt（file teks）
• .docx（file Word）
• .pdf（file PDF dengan OCR）
```

### Cara 3：Gunakan kamera（mobile）
```
1. Sentuh ikon kamera
2. Ambil foto pekerjaan tulisan tangan Anda
3. OCR secara otomatis mengonversi gambar → teks
```

---

## 4️⃣ Mulai analisis

Klik tombol biru **「Analisis」**

```
Status：[████░░░░░░░░░░░░] 25% sedang dianalisis...
（biasanya 2～10 detik, tergantung panjang teks）
```

---

## 5️⃣ Tinjau laporan

### Bagian atas：**Kartu ringkasan putusan**
```
╔════════════════════════════════════╗
║  Putusan：Kemungkinan dibuat oleh AI ║
║  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   ║
║  Probabilitas AI：72%               ║
║  Kepercayaan：Tinggi ✓             ║
╚════════════════════════════════════╝
```

**📌 Arti**：
- **Putusan**：Penilaian umum（manusia / kemungkinan manusia / campuran / kemungkinan AI / AI）
- **Probabilitas**：Tingkat kepercayaan pembuatan oleh AI（0～100%）
- **Kepercayaan**：Apakah semua mesin deteksi setuju

---

### Bagian tengah：**Kartu metrik 3 kolom**
```
┌──────────────┬──────────────┬──────────────┐
│  Rasio AI    │ Waktu analisis│  Kepercayaan │
│  ────────    │ ────────     │  ────────   │
│  8/45 (18%)  │  2,3 detik    │  92%        │
└──────────────┴──────────────┴──────────────┘
```

**📌 Arti**：
- **Rasio AI**：Berapa banyak kalimat yang ditandai sebagai AI（8 dari 45）
- **Waktu analisis**：Waktu pemindaian
- **Kepercayaan**：Keandalan hasil keseluruhan

---

### Bagian bawah：**Daftar kalimat mencurigakan**
```
【Kalimat #1】（halaman 3）Risiko：Tinggi 🔴 | Kepercayaan 85%
  "Pergeseran paradigma sinergis memungkinkan..."
  Alasan：Kesamaan tinggi, kompleksitas kosakata yang tidak biasa, pola ritme

【Kalimat #2】（halaman 5）Risiko：Sedang 🟡 | Kepercayaan 72%
  "Algoritma pembelajaran mesin memulai revolusi..."
  Alasan：Penyimpangan statistik, keragaman kosakata rendah
```

**📌 Cara membaca**：
- **Nomor halaman**：Posisi dalam dokumen
- **Warna risiko**：Merah（risiko tinggi）, kuning（risiko sedang）, biru（risiko rendah）
- **Persentase AI**：Kemungkinan adalah AI（0～100%）
- **Alasan**：Mengapa model menandai kalimat ini

---

## 6️⃣ Interpretasikan hasil（Untuk guru）

### Skenario A：Probabilitas AI keseluruhan > 80%
```
⚠️ Bukti kuat penggunaan AI
→ Tindakan：Periksa kalimat mencurigakan dengan cermat
→ Selanjutnya：Bicarakan dengan siswa tentang apakah kebijakan memungkinkan AI
```

### Skenario B：Probabilitas AI 50～80%
```
🤔 Sinyal campuran; beberapa paragraf mencurigakan
→ Tindakan：Fokus pada kalimat yang ditandai merah
→ Selanjutnya：Periksa apakah cocok dengan gaya penulisan siswa yang khas
```

### Skenario C：Probabilitas AI < 30%
```
✅ Terlihat seperti pekerjaan autentik siswa
→ Tindakan：Pertimbangkan untuk menyetujui atau periksa beberapa kalimat
→ Catatan：Teks manusia juga bisa memiliki positif palsu
```

---

## 7️⃣ Unduh dan bagikan hasil

### Opsi ekspor
```
1. [📄 Unduh PDF]      → Laporan lengkap dengan semua detail
2. [📊 Ekspor CSV]     → Untuk spreadsheet nilai
3. [📋 Salin hasil]    → Untuk tempel di email/LMS
```

**PDF menyertakan**：
- Ringkasan putusan
- Metrik terperinci
- Semua kalimat mencurigakan dan alasan
- Nomor halaman untuk referensi mudah

---

## ⚙️ Sesuaikan pengaturan（opsional）

Panel kanan：Klik **⚙️ ikon gigi**

| Pengaturan | Default | Fungsi |
|-----------|---------|--------|
| Unduh model | Otomatis | Unduh ulang model deteksi |
| Periksa tautan | Aktif | Verifikasi URL benar-benar ada |
| Validasi DOI | Aktif | Verifikasi sitasi ada（Crossref） |
| Bahasa | Otomatis | Alihkan bahasa UI（14 didukung） |
| Kebijakan privasi | — | Baca jaminan 「nol unggahan」 |

---

## 🆘 Masalah umum dan solusi

### Masalah：「Unduhan model gagal」
```
❌ Kesalahan：Tidak dapat mengunduh model RoBERTa
✅ Solusi：
  1. Periksa koneksi internet
  2. Nonaktifkan VPN/proxy
  3. Tunggu 5 menit dan coba lagi
  4. Kosongkan cache browser（Ctrl+Shift+Del）
```

### Masalah：「Analisis sangat lambat」
```
❌ Menunggu lebih dari 30 detik
✅ Solusi：
  1. Jalankan pertama lambat（memuat model ke RAM）
  2. Jalankan berikutnya membutuhkan 2～5 detik
  3. Tutup tab browser lain
  4. Mulai ulang browser jika tetap lambat
```

### Masalah：「Browser bilang 'memori habis'」
```
❌ Kesalahan：Tidak dapat mengalokasikan memori
✅ Solusi：
  1. Minimal 2 GB RAM gratis diperlukan
  2. Tutup aplikasi lain
  3. Muat ulang halaman（Cmd/Ctrl + R）
  4. Coba di komputer desktop
```

---

## ✅ Langkah selanjutnya

### Untuk guru
1. ✅ Unduh model
2. ✅ Uji dengan 1～2 dokumen contoh
3. ✅ Biasakan diri dengan format laporan
4. ✅ Buat rubrik penilaian berdasarkan skor deteksi AI
5. ✅ Distribusikan panduan kelas

### Untuk administrator sekolah
1. ✅ Terapkan di server sekolah（opsional, untuk penggunaan offline）
2. ✅ Buat panduan guru
3. ✅ Latih staf dalam penggunaan alat
4. ✅ Tetapkan kebijakan integritas akademik dengan deteksi AI

### Untuk developer
1. ✅ Lihat [CLAUDE.md](../CLAUDE.md) untuk pengaturan
2. ✅ Lihat [docs/implementation_plan.md](./implementation_plan.md) untuk arsitektur
3. ✅ Lihat [docs/model_integration_testing.md](./model_integration_testing.md) untuk detail model

---

## 📚 Sumber daya tambahan

| Sumber daya | Tujuan |
|-----------|--------|
| [Dokumentasi lengkap](./implementation_plan.md) | Selami semua fitur |
| [Kebijakan privasi](https://truthlens.vercel.app/#/privacy) | Verifikasi cara kami melindungi data |
| [Daftar model](./model_integration_testing.md) | Detail teknis setiap model AI |
| [Pertanyaan umum](./faq-id.md) | Jawaban pertanyaan umum |
| [Penyelesaian masalah](./troubleshooting-id.md) | Metode pemecahan masalah lebih detail |

---

## 💬 Punya pertanyaan atau komentar？

- **Menemukan bug？** → [GitHub Issues](https://github.com/hauchiehlin-ops/TruthLens/issues)
- **Permintaan fitur？** → [GitHub Discussions](https://github.com/hauchiehlin-ops/TruthLens/discussions)
- **Pertanyaan lain？** → hauchieh.lin@gmail.com

---

**Siap menganalisis？** → [Buka TruthLens sekarang！](https://truthlens.vercel.app)
