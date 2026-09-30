# Bab 13 — Fitur Aplikasi yang Lebih Realistis

Dasar: `ch12-auth-integration`. Stack dan satu Dio tetap digunakan.

- `GET /api/tasks`: search pada title, status pending/completed, priority low/medium/high, page; paginate(10), orderBy(id), data/links/meta.
- Search saat submit; filter dan Reset memuat page 1; Muat lagi menambahkan ID unik; kegagalan halaman lanjutan mempertahankan data dan nomor halaman.
- Pull-to-refresh memuat page 1 dan mempertahankan query. CRUD memuat ulang page 1 setelah server mengonfirmasi mutasi.
- Dashboard: Total hasil berasal dari meta.total untuk query aktif; Selesai dimuat berasal dari snapshot yang sudah dimuat. Label tidak mengklaim statistik global.
- Profil destination ketiga; AuthProvider satu pemilik user. PUT /api/user untuk nama/email; POST /api/user/avatar multipart avatar JPG/PNG maksimal 2048 KB.
- avatar_url merupakan URL publik, bukan path lokal. Kolom avatar sudah ada dari Bab 7. Gambar menggunakan nama baru saat upload; avatar lama dihapus setelah DB tersimpan.
- Android API 24+; image_picker 1.2.3. Galeri saja. Pilihan yang terputus saat proses dihentikan dibersihkan pada startup; pengguna memilih ulang sesudah sesi dipulihkan.

## Jalankan

Backend: composer install, siapkan .env dan MySQL seperti Bab 7, php artisan migrate, php artisan storage:link. APP_URL harus alamat backend yang dapat dibuka perangkat. php artisan config:clear, lalu php artisan serve --host=0.0.0.0 --port=8000.

Flutter: flutter pub get, flutter analyze, flutter test, flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api.

Untuk pagination, gunakan minimal 12 task milik satu akun. Uji kombinasi filter, refresh, kegagalan Muat lagi, email duplikat, upload valid/invalid dan logout saat operasi berjalan. Empat screenshot mengikuti blueprint: Search Task; Filter Task; Profile; Edit Profile. Screenshot 13.2 mencakup Muat lagi; 13.4 mencakup avatar.

Verifikasi otomatis: .github/workflows/verify-ch13.yml. Uji nyata MySQL, perangkat, galeri dan akses URL storage tetap merupakan acceptance check terpisah.
