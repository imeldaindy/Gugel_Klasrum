# Gugel Classroom

**Gugel Classroom** adalah aplikasi pembelajaran digital yang dikembangkan sebagai proyek Ujian Tengah Semester (UTS). Aplikasi ini terinspirasi dari Google Classroom dengan nama yang dimodifikasi menjadi Gugel Klasrum.

Aplikasi ini dikembangkan menggunakan Flutter untuk frontend, Laravel (PHP) untuk backend REST API, dan MySQL sebagai database.

## Anggota Kelompok

| No. | Nama Anggota | NIM |
|---|---|---|
| 1 | Alif Muhammad Hafizh | 24051214228 |
| 2 | Ahmad Fauzi Ramadhani | 24051214232 |
| 3 | Savannah Farah | 24051214242 |
| 4 | Imelda Indy Nasya Hardianti | 24051214231 |
| 5 | M. Ridho Aulia | 24051214237 |

## Teknologi yang Digunakan

- **Frontend:** Flutter
- **Backend:** Laravel (PHP)
- **API:** REST API
- **Database:** MySQL
- **Database Management:** Laragon

## Struktur Proyek

```text
gugel-klasrum/
├── frontend/       # Source code aplikasi Flutter
├── backend/        # Source code Laravel REST API
├── database/       # File database SQL atau dokumentasi database
└── README.md       # Dokumentasi proyek
```

## Cara Menjalankan Aplikasi

### 1. Menjalankan Backend Laravel

1. Pastikan PHP, Composer, dan MySQL sudah terpasang.
2. Jalankan MySQL melalui Laragon.
3. Masuk ke folder backend.
4. Instal dependensi Laravel:

   ```bash
   composer install
   ```

5. Salin `.env.example` menjadi `.env`, lalu sesuaikan konfigurasi database.
6. Buat application key:

   ```bash
   php artisan key:generate
   ```

7. Jalankan migrasi database jika file migrasi sudah tersedia dan konfigurasi database benar:

   ```bash
   php artisan migrate
   ```

8. Jalankan server Laravel:

   ```bash
   php artisan serve
   ```

### 2. Menjalankan Frontend Flutter

1. Pastikan Flutter SDK sudah terpasang.
2. Masuk ke folder frontend.
3. Instal dependensi Flutter:

   ```bash
   flutter pub get
   ```

4. Sesuaikan alamat API pada aplikasi dengan alamat server backend yang digunakan.
5. Jalankan aplikasi:

   ```bash
   flutter run
   ```

## Tujuan Proyek

Proyek ini dibuat untuk memenuhi tugas Ujian Tengah Semester (UTS), sekaligus menerapkan pengembangan aplikasi Flutter yang terhubung dengan backend REST API dan database MySQL.

## Catatan

- Pastikan backend dan database sudah berjalan sebelum aplikasi Flutter dihubungkan ke API.
- Jangan mengunggah file `.env` yang berisi kredensial atau informasi rahasia ke repositori publik.
- Struktur folder dan langkah menjalankan aplikasi perlu disesuaikan dengan struktur akhir proyek.
