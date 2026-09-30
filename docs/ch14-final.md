# Bab 14 — Testing, keamanan dasar, dan build

Branch: ch14-final. Dasar: ch13-advanced-features.

## Perubahan
- Unit test TaskPage.fromJson: item, due_date, metadata dan hasil kosong.
- DebugApiLogger: method/path/status saja, tanpa query/header/body; hanya kDebugMode.
- ApiConfig.validate dijalankan sebelum membuat Dio; startup release menolak URL non-HTTPS.
- Manifest src/release menolak cleartext; konfigurasi HTTP lokal tetap khusus src/debug.
- Gradle release signing membaca android/key.properties; tidak lagi memakai debug signing.
- key.properties.example dan gitignore untuk keystore serta properties pribadi.
- CRUD, query, refresh snapshot, sesi, profil dan avatar tetap mengikuti Bab 13.

## Flutter
Dari mobile/task_manager:
```bash
flutter pub get
flutter analyze
flutter test
```

test/widget_test.dart memakai LoginScreen dan dependency yang sudah ada. Form kosong berhenti sebelum API/storage. task_provider_test.dart dan task_pagination_test.dart tetap dijalankan.

## API
Postman tetap alat pengujian utama buku. Gunakan dua akun latihan, satu task A dengan ID diketahui, lalu periksa 401 tanpa token, 422 input invalid, dan 404 saat B mencoba GET/PUT/DELETE task A. Periksa CRUD, search/filter/page, profil/avatar, dan token yang dicabut sesudah logout. Jangan ekspor token/password ke repository.

Regresi backend dari Bab 13:
```bash
php artisan config:clear
php artisan test --filter=AdvancedFeaturesTest
```
phpunit.xml memakai SQLite :memory: khusus pengujian; MySQL tetap database aplikasi. Gunakan environment testing terpisah, APP_KEY lokal yang sah, dependency dev dan extension pdo_sqlite/gd. Jangan memakai konfigurasi cache produksi. Uji MySQL/Postman/perangkat tetap terpisah.

## Signing dan release
Buat keystore pribadi di luar repository memakai keytool. Salin android/key.properties.example ke android/key.properties; isi password, alias dan path absolut. Template bukan credentials aktif. Jangan commit keystore/properties.
Sesudah perubahan Gradle: flutter clean, flutter pub get.

Ganti domain contoh dengan URL HTTPS backend nyata:
```bash
flutter build apk --release --dart-define=API_BASE_URL=https://api.example.org/api
flutter build appbundle --release --dart-define=API_BASE_URL=https://api.example.org/api
```
Output:
- build/app/outputs/flutter-apk/app-release.apk
- build/app/outputs/bundle/release/app-release.aab

APK dapat dipasang melalui adb install -r; signature harus cocok dengan aplikasi sebelumnya. AAB tidak dipasang langsung dengan adb. URL API dan avatar harus dapat diakses perangkat melalui HTTPS. APP_DEBUG server false. Keberhasilan build tidak membuktikan koneksi server; validasi URL aplikasi terjadi saat startup.

## Verifikasi checkpoint
Workflow .github/workflows/verify-ch14.yml menjalankan analyzer, semua test Flutter, regresi backend dan build APK/AAB. Keystore runner hanya untuk verifikasi, dibuat sementara dan tidak diunggah; tidak memakai kunci pemilik. Domain contoh hanya input build, bukan server aktif. Workflow tidak mengunggah paket hasil build.

Bukti eksekusi dan status akhir dicatat setelah run selesai. Acceptance pada perangkat, Secure Storage, galeri, MySQL, HTTPS server nyata dan Postman belum dilakukan oleh penyusun checkpoint. Placeholder screenshot 14.1 testing, 14.2 build dan 14.3 final app harus diambil dari hasil nyata. main hanya dinyatakan final stabil sesudah acceptance lengkap; ch14-final memuat source persiapan final.

Lampiran A: memilih checkpoint. B: endpoint. C: struktur. D: materi pendukung.
