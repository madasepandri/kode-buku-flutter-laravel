# Buku Flutter Laravel — Checkpoint Bab 14

Repository pendamping buku *Flutter untuk Aplikasi Mobile: Dari UI hingga Integrasi Backend Laravel*.

Branch: **ch14-final**, melanjutkan **ch13-advanced-features**.

Task Management App memakai Flutter, Provider, Dio, Flutter Secure Storage, Laravel 13, Sanctum dan MySQL. CRUD, sesi, search/filter/pagination/refresh, profil dan avatar tetap mengikuti bab sebelumnya.

- Flutter: `mobile/task_manager`
- Laravel: `backend/task_api`
- [Setup, testing, signing dan build](docs/ch14-final.md)
- [Panduan fitur Bab 13](docs/ch13-advanced-features.md)
- [Verifikasi otomatis Bab 14](.github/workflows/verify-ch14.yml)

Jalankan analyzer dan test. Untuk release, siapkan server HTTPS yang dapat diakses perangkat dan keystore pribadi; salin template key.properties.example lalu isi secara lokal. Keystore, key.properties, .env dan token tidak disimpan di repository. Tidak menggunakan DEMO_API_TOKEN.

Workflow membangun APK/AAB dengan kunci sementara khusus verifikasi dan tidak mengunggah hasil build. Build tersebut bukan paket distribusi pemilik dan tidak membuktikan backend contoh online. Uji perangkat, Postman, MySQL, galeri dan HTTPS tujuan mengikuti acceptance naskah.

Screenshot Bab 14: Hasil Testing; Build APK/AAB; Final Task Management App. main belum dinyatakan final stabil sebelum acceptance lengkap.
