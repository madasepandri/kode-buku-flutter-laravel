# Task Management API

Backend Laravel untuk Bab 7 buku *Flutter untuk Aplikasi Mobile Dari UI hingga Integrasi Backend Laravel*.

## Menjalankan checkpoint

Persyaratan: PHP 8.3+, Composer, MySQL. Dari `backend/task_api`:

```bash
composer install
cp .env.example .env
php artisan key:generate
```

Buat database MySQL `task_management` dan akun lokal yang berizin pada database itu. Isi `DB_USERNAME` serta `DB_PASSWORD` pada `.env`, lalu jalankan:

```bash
php artisan migrate
php artisan db:seed
php artisan migrate:status
php artisan tinker
```

Dalam Tinker, periksa `App\Models\User::where('email', 'demo@example.test')->firstOrFail()->tasks()->count()` bernilai 5. Seeder memberi password contoh `DemoTask2026!` hanya untuk pengembangan lokal. Ganti sebelum penggunaan nyata. `.env` tidak dikomit. `composer.lock` belum disertakan dalam checkpoint; jalankan `composer install` untuk menyelesaikan versi dari `composer.json` pada lingkungan lokal dan simpan lock file ketika menyiapkan reproduksi yang ketat.

Bab 7 berhenti pada migration, model, relasi, dan seeder. Route API, controller, dan autentikasi disusun pada Bab 8–9. Flutter dari Bab 6 tetap memakai data lokal sementara.
