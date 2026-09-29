# Buku Flutter Laravel

Repository pendamping buku *Flutter untuk Aplikasi Mobile: Dari UI hingga Integrasi Backend Laravel*. Satu studi kasus, **Task Management App**, dikembangkan bertahap dari proyek Flutter awal sampai aplikasi Android yang terhubung dengan REST API Laravel dan MySQL.

## Struktur yang direncanakan

```text
mobile/task_manager/   Proyek Flutter (mulai Bab 2)
backend/task_api/      Proyek Laravel (mulai Bab 7)
docs/                  Catatan pendamping buku
screenshots/           Gambar hasil praktik bila diperlukan
```

Folder akan ditambahkan pada bab yang membuat isinya. Bab 2 menggunakan proyek Flutter bawaan; backend belum dibuat.

## Stack buku

Flutter dan Dart, Material Design, Provider, Dio, Flutter Secure Storage, Laravel REST API, Sanctum, Eloquent, MySQL, Postman, Git, dan GitHub. Versi SDK dan dependency akan dicatat pada checkpoint teknis setelah proyek dihasilkan dan diperiksa.

## Checkpoint

`ch02-project-init` menandai proyek Flutter awal yang berhasil dijalankan pada Android. Branch tersebut dibuat setelah `flutter create --platforms=android task_manager` dijalankan dari folder `mobile/` dan hasilnya diverifikasi dengan `flutter doctor`, `flutter devices`, serta `flutter run`.

## Menjalankan proyek Bab 2

Setelah branch `ch02-project-init` tersedia:

```bash
cd mobile/task_manager
flutter pub get
flutter run
```

Panduan instalasi khusus sistem operasi: [Flutter](https://docs.flutter.dev/install) dan [Flutter untuk Android](https://docs.flutter.dev/platform-integration/android/setup).
