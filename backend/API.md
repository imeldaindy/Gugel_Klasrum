# Gugel Klasrum REST API

Base URL: `http://localhost:8000/api` (emulator Android: `http://10.0.2.2:8000/api`).
Format: JSON. Endpoint selain `/login` dan `/register` butuh header
`Authorization: Bearer <token>` (Laravel Sanctum). Kirim juga `Accept: application/json`.

## Menjalankan

```bash
cp .env.example .env            # lalu atur DB_* (MySQL: buat database gugel_klasrum)
composer install
php artisan key:generate
php artisan migrate --seed      # tabel + data awal (sandi semua akun: "password")
php artisan serve --host=0.0.0.0 --port=8000
```

Akun seed: `24051214228@mhs.unesa.ac.id`, `alfgame321@gmail.com`,
`alifscc0311@gmail.com`, `sotoayamcakipinktt@gmail.com`, `alifmhafizh0311@gmail.com`.
Kode kelas seed: `audit001`, `literas2`, `ksig0003`, `mlp03rab`, `keamanan`, `apsi2024`, `sbd2024g`.

## Endpoint

| Method | Path | Keterangan |
|---|---|---|
| POST | `/register` | `name, email, password, password_confirmation` -> `{user, token}` |
| POST | `/login` | `email, password` -> `{user, token}` (juga dipakai untuk "Tambahkan akun") |
| GET | `/me` | profil akun aktif |
| POST | `/logout` | cabut token saat ini |
| GET | `/courses` | kelas milik / diikuti user |
| POST | `/courses` | buat kelas: `name`* , `description, section, room, subject, level`. Pembuat jadi pengajar |
| GET | `/courses/{id}` | detail kelas |
| PUT/PATCH | `/courses/{id}` | setelan kelas (pengajar): field detail + `invite_enabled`, `post_policy`, `notify_mode` |
| POST | `/courses/{id}/reset-code` | kode baru (pengajar); kode lama tidak berlaku |
| POST | `/courses/join` | `code` = kode kelas **atau** link undangan (`?cjc=`) |
| POST | `/courses/{id}/leave` | keluar kelas (siswa) |
| GET/POST | `/courses/{id}/posts` | forum; POST `content` (ikut `post_policy`) |
| GET/POST | `/courses/{id}/assignments` | daftar tugas; POST (pengajar): `title*, description, points, deadline` |
| GET | `/courses/{id}/people` | `{teacher, data: [siswa]}` |
| GET | `/assignments` | daftar tugas semua kelas |
| GET/PUT/DELETE | `/assignments/{id}` | detail / ubah / hapus (ubah & hapus: pengajar) |
| POST/DELETE | `/assignments/{id}/submit` | serahkan (lampiran opsional) / batal serahkan |
| GET/POST | `/comments/{post\|assignment}/{id}` | komentar kelas, POST `content` |
| GET | `/notifications` | notifikasi user |
| POST | `/notifications/{id}/read` | tandai dibaca |
| POST | `/feedback` | `message*`, `include_screenshot`, `include_system_info` |

Nilai `post_policy`: `students_post_and_comment` · `students_comment_only` · `teacher_only`.
Nilai `notify_mode`: `condensed` · `full` · `hidden`.
Field `code`, `invite_link`, `invite_enabled` hanya dikirim ke pengajar kelas.

Kode error: `401` belum login, `403` bukan pengajar / dilarang kebijakan forum / undangan nonaktif,
`404` tidak ditemukan atau bukan anggota kelas, `409` sudah bergabung, `422` validasi gagal.

## Contoh (curl)

```bash
# login
curl -X POST localhost:8000/api/login -H 'Accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{"email":"alfgame321@gmail.com","password":"password"}'

# buat kelas
curl -X POST localhost:8000/api/courses -H 'Accept: application/json' \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d '{"name":"test","section":"test","room":"test","subject":"aplikasi bergerak","level":"uts"}'

# akun lain bergabung dengan kode dari respons di atas
curl -X POST localhost:8000/api/courses/join -H 'Accept: application/json' \
  -H "Authorization: Bearer $TOKEN2" -H 'Content-Type: application/json' \
  -d '{"code":"kojmq6pd"}'
```
