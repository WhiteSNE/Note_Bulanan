# 💰 Celengan Mahasiswa

**Celengan Mahasiswa** adalah aplikasi *Expense Tracker* (Pencatat Keuangan) berbasis **Flutter** yang dirancang khusus untuk membantu mahasiswa mengelola arus kas bulanan, menabung untuk barang impian (Wishlist), dan memantau kesehatan finansial melalui grafik interaktif.

Aplikasi ini dibuat dengan fokus pada *User Experience* (UX), persistensi data lokal, dan antarmuka yang modern.

---

## ✨ Fitur Unggulan

### 1. 📊 Dashboard Interaktif
* **Saldo Real-time:** Menghitung saldo akhir berdasarkan akumulasi bulan-bulan sebelumnya (*Carry-Over Balance*).
* **Grafik Harian:** Visualisasi naik-turun uang menggunakan `fl_chart` dengan tooltip detail (Tanggal & Nominal).
* **Maskot Ekspresif:** Karakter lucu yang berubah ekspresi (Sedih/Datar/Senang) tergantung kondisi saldo.
* **Wishlist Progress:** Memantau persentase ketercapaian target belanja langsung dari dashboard.

### 2. 📝 Manajemen Transaksi (CRUD)
* Mencatat Pemasukan dan Pengeluaran.
* Menghapus transaksi dengan gestur *Swipe-to-Delete* (Geser untuk hapus).
* Filter data berdasarkan Bulan (Timeline).

### 3. 🎁 Integrasi Wishlist
* Menetapkan target barang impian.
* **Integrasi Otomatis:** Saat barang dicentang (terbeli), saldo otomatis terpotong dan tercatat di riwayat pengeluaran.
* Sistem konfirmasi "Yakin Beli?" untuk mencegah pembelian impulsif.

### 4. 🎨 Personalisasi & UI Modern
* **Dark Mode / Light Mode:** Tema warna yang nyaman di mata (Teal & Emerald).
* **Profil Pengguna:** Mendukung upload foto profil dari galeri (`image_picker`) dan input nama panggilan.
* **Onboarding:** Halaman sambutan interaktif untuk pengguna baru.

### 5. 💾 Penyimpanan Data (Persistance)
* Data tersimpan permanen di memori HP menggunakan `shared_preferences` dan serialisasi JSON.
* Data tidak hilang meskipun aplikasi ditutup atau direstart.
* Fitur **Factory Reset** untuk menghapus semua data dan kembali ke pengaturan awal.

---

## 📸 Tangkapan Layar (Screenshots)

| Dashboard (Light) | Riwayat Transaksi | Wishlist & Dialog | Dark Mode |
| :---: | :---: | :---: | :---: |
| <img src="assets/screenshots/dashboard.png" width="200" /> | <img src="assets/screenshots/riwayat.png" width="200" /> | <img src="assets/screenshots/wishlist.png" width="200" /> | <img src="assets/screenshots/darkmode.png" width="200" /> |

---

## 🛠️ Teknologi yang Digunakan

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **State Management:** `setState` (Native)
* **Local Storage:** [`shared_preferences`](https://pub.dev/packages/shared_preferences) (JSON Encoding/Decoding)
* **Charting:** [`fl_chart`](https://pub.dev/packages/fl_chart)
* **Formatting:** [`intl`](https://pub.dev/packages/intl) (Date & Currency Formatting)
* **Media:** [`image_picker`](https://pub.dev/packages/image_picker)

---

## 📂 Struktur Proyek

Aplikasi ini menggunakan struktur folder yang rapi dan modular:

```text
lib/
├── models/             # Model data (Transaksi & Wishlist) dengan JSON Serialization
├── screens/            # Tampilan UI (Dashboard, Riwayat, Settings, Onboarding)
├── main.dart           # Logika utama, Routing, dan State Management Global
└── tema_aplikasi.dart  # Konfigurasi tema warna (Light & Dark)
