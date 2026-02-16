# Custom Notification Assets Setup Guide

## Overview

Panduan ini menjelaskan cara mendapatkan dan menambahkan **custom notification icon** dan **custom notification sound** untuk DarahTanyoe App.

Status implementasi:
- ✅ Struktur folder sudah dibuat
- ✅ Code sudah diupdate di `push_notification_service.dart`
- ⏳ **Perlu action**: Download dan tambahkan asset files yang proper

---

## 1. Custom Notification Icon (Android)

### Mengapa Perlu Icon Khusus?

Notification icon berbeda dari app icon:
- **App icon** (`ic_launcher`): Full color, dipakai untuk launcher
- **Notification icon** (`ic_notification`): Monochrome, tampil di status bar & notification tray

### Design Requirements

- **Format**: PNG dengan alpha channel
- **Warna**: Putih (#FFFFFF) dengan background transparan
- **Style**: Flat silhouette, tanpa gradient, tanpa anti-aliasing
- **Design**: Simpel dan recognizable (contoh: tetesan darah, logo +, hati)

### Cara Generate Icon dengan Android Asset Studio

#### Option 1: Menggunakan Web Tool (Recommended)

1. **Buka Android Asset Studio**
   - URL: https://romannurik.github.io/AndroidAssetStudio/icons-notification.html

2. **Upload Source Image**
   - Gunakan `assets/images/logo_aplikasi.png` atau design custom
   - Atau buat design sederhana (blood drop silhouette)

3. **Adjust Settings**
   - Name: `ic_notification` (JANGAN diubah)
   - Trim: Yes
   - Padding: 25%
   - Color: White (default)

4. **Download ZIP**
   - Klik "Download" button
   - Extract file ZIP

5. **Copy Files ke Project**
   ```
   Dari ZIP:                           →  Ke Project:
   ├── res/
   │   ├── drawable-mdpi/
   │   │   └── ic_notification.png    →  android/app/src/main/res/drawable-mdpi/ic_notification.png
   │   ├── drawable-hdpi/
   │   │   └── ic_notification.png    →  android/app/src/main/res/drawable-hdpi/ic_notification.png
   │   ├── drawable-xhdpi/
   │   │   └── ic_notification.png    →  android/app/src/main/res/drawable-xhdpi/ic_notification.png
   │   ├── drawable-xxhdpi/
   │   │   └── ic_notification.png    →  android/app/src/main/res/drawable-xxhdpi/ic_notification.png
   │   └── drawable-xxxhdpi/
   │       └── ic_notification.png    →  android/app/src/main/res/drawable-xxxhdpi/ic_notification.png
   ```

   **PowerShell command untuk copy (dari Downloads):**
   ```powershell
   # Adjust path sesuai lokasi extract ZIP
   $source = "$env:USERPROFILE\Downloads\ic_notification\res"
   $dest = "d:\Skripsi\CODE\DarahTanyoe_App\android\app\src\main\res"
   
   Copy-Item "$source\drawable-mdpi\ic_notification.png" "$dest\drawable-mdpi\" -Force
   Copy-Item "$source\drawable-hdpi\ic_notification.png" "$dest\drawable-hdpi\" -Force
   Copy-Item "$source\drawable-xhdpi\ic_notification.png" "$dest\drawable-xhdpi\" -Force
   Copy-Item "$source\drawable-xxhdpi\ic_notification.png" "$dest\drawable-xxhdpi\" -Force
   Copy-Item "$source\drawable-xxxhdpi\ic_notification.png" "$dest\drawable-xxxhdpi\" -Force
   ```

#### Option 2: Manual Design (Advanced)

Jika ingin design sendiri:

**Size per Density:**
- `drawable-mdpi`: 24x24 px
- `drawable-hdpi`: 36x36 px
- `drawable-xhdpi`: 48x48 px
- `drawable-xxhdpi`: 72x72 px
- `drawable-xxxhdpi`: 96x96 px

**Gunakan tool:**
- Adobe Illustrator / Photoshop
- Figma (export as PNG)
- Inkscape (free)

**Export settings:**
- PNG-24 with alpha
- No background
- White foreground only

---

## 2. Custom Notification Sound

### Audio Requirements

**Android:**
- Format: **OGG** (recommended) atau MP3, WAV
- Duration: 2-10 detik
- File size: < 1 MB (ideally 100-500 KB)
- Nama file: `notification_sound.ogg`

**iOS:**
- Format: **CAF** (Core Audio Format) - required!
- Duration: 2-10 detik
- Nama file: `notification_sound.caf`

### Cara Mendapatkan Notification Sound

#### Option 1: Download dari Free Sound Library

**Recommended Sites:**
1. **Pixabay Audio** (https://pixabay.com/sound-effects/)
   - Cari: "notification", "alert", "medical"
   - License: Free for commercial use
   - Download format OGG/MP3

2. **Freesound** (https://freesound.org/)
   - Cari: "notification beep", "alert tone"
   - Filter: Creative Commons 0 (Public Domain)
   - Download format OGG/WAV

3. **Zapsplat** (https://www.zapsplat.com/)
   - Category: UI / Notifications
   - Free account needed
   - Download format MP3/WAV

**Keyword Search:**
- "medical alert"
- "emergency notification"
- "hospital beep"
- "soft notification"
- "blood donation alert"

#### Option 2: Generate Custom Sound (Audacity)

1. Download **Audacity** (free): https://www.audacityteam.org/

2. Create simple beep:
   - Generate → Tone
   - Waveform: Sine
   - Frequency: 800 Hz (untuk urgent) atau 550 Hz (untuk gentle)
   - Duration: 0.3 - 0.5 seconds
   - Amplitude: 0.8

3. Add pattern (optional):
   - Generate 2-3 tones dengan jeda 0.1s
   - Contoh pattern: Beep - Beep - Beep (urgent)

4. Export:
   - **Android**: File → Export → Export as OGG Vorbis
   - **iOS**: File → Export → Export Audio → WAV, lalu convert ke CAF (lihat di bawah)

### Setup Sound Files

#### Android Setup

1. **Place Sound File**
   ```
   DarahTanyoe_App/
   └── android/
       └── app/
           └── src/
               └── main/
                   └── res/
                       └── raw/
                           └── notification_sound.ogg  ← Place file here
   ```

2. **PowerShell command:**
   ```powershell
   # Copy dari Downloads ke raw folder
   Copy-Item "$env:USERPROFILE\Downloads\notification_sound.ogg" "d:\Skripsi\CODE\DarahTanyoe_App\android\app\src\main\res\raw\" -Force
   ```

#### iOS Setup

1. **Convert OGG/MP3 to CAF format**

   **Menggunakan Online Converter:**
   - https://convertio.co/ogg-caf/
   - https://cloudconvert.com/ogg-to-caf
   - Upload file, convert, download

   **Atau menggunakan macOS (jika punya Mac):**
   ```bash
   afconvert -f caff -d LEI16 notification_sound.ogg notification_sound.caf
   ```

2. **Place CAF File**
   ```
   DarahTanyoe_App/
   └── ios/
       └── Runner/
           └── Resources/
               └── notification_sound.caf  ← Place file here
   ```

3. **Add to Xcode Project** (Perlu Mac + Xcode):
   - Buka project di Xcode
   - Right-click `Runner` folder
   - Select "Add Files to Runner"
   - Navigate ke `ios/Runner/Resources/`
   - Select `notification_sound.caf`
   - Check "Copy items if needed"
   - Click "Add"

   **Note**: Jika tidak punya Mac sekarang, file sudah ada di folder yang benar. Nanti saat build iOS, bisa ditambahkan.

---

## 3. Verification after Adding Assets

### Rebuild App

Setelah menambahkan icon & sound files:

```powershell
cd d:\Skripsi\CODE\DarahTanyoe_App

# Clean build
flutter clean

# Get dependencies
flutter pub get

# Run on Android
flutter run
```

### Testing Checklist

1. **Test Custom Icon**
   - Trigger notification (via backend atau Firebase Console)
   - Cek status bar → harus tampil icon kustom (bukan logo app biasa)
   - Pull down notification drawer → icon harus monochrome/putih

2. **Test Custom Sound**
   - Pastikan device/emulator volume ON
   - Trigger notification
   - Harus bunyi sound custom (bukan default ringtone)
   - Test di foreground dan background

3. **Test Scenarios**
   - App in foreground (open)
   - App in background (minimized)
   - App terminated (fully closed)
   - Different Android versions (8.0+, 12+)

### Troubleshooting

**Icon tidak berubah:**
- Pastikan nama file **EXACT**: `ic_notification.png` (lowercase, underscore)
- Clean build: `flutter clean`
- Uninstall app dari device, rebuild
- Cek Android notification channel di Settings → atur ulang permission

**Sound tidak keluar:**
- Pastikan nama file **EXACT**: `notification_sound.ogg` (Android) 
- Cek volume device (Media, Notification, Ringer)
- Test sound file dengan media player dulu (pastikan file valid)
- Android 8.0+: Notification channel sudah terdaftar? Hapus data app & reinstall
- Cek format: OGG untuk Android, CAF untuk iOS

**Build error "resource not found":**
- Pastikan file ada di path yang benar
- Nama file harus lowercase dengan underscore only
- No spaces, no special characters
- Run `flutter clean` dan rebuild

---

## 4. Quick Reference

### File Locations Summary

```
DarahTanyoe_App/
├── android/app/src/main/res/
│   ├── drawable-mdpi/ic_notification.png      (24x24)
│   ├── drawable-hdpi/ic_notification.png      (36x36)
│   ├── drawable-xhdpi/ic_notification.png     (48x48)
│   ├── drawable-xxhdpi/ic_notification.png    (72x72)
│   ├── drawable-xxxhdpi/ic_notification.png   (96x96)
│   └── raw/notification_sound.ogg
│
└── ios/Runner/Resources/
    └── notification_sound.caf
```

### Code Changes (Already Done ✅)

- ✅ `lib/service/push_notification_service.dart` - Line 60: Icon reference
- ✅ `lib/service/push_notification_service.dart` - Line 67-77: Channel sound
- ✅ `lib/service/push_notification_service.dart` - Line 292-310: Notification details

### No Changes Needed

- ❌ `pubspec.yaml` - Native resources tidak perlu declare
- ❌ `AndroidManifest.xml` - No changes required
- ❌ `Info.plist` - No changes required

---

## 5. Recommended Assets

### Icon Design Ideas

Untuk blood donation app, recommended designs:
1. ☑️ **Tetesan darah** (blood drop silhouette) - MOST RECOGNIZABLE
2. ☑️ **Logo +** atau Red Cross symbol
3. ☑️ **Hati** (heart) symbol
4. ☐ Logo DarahTanyoe simplified (ambil dari logo_aplikasi.png)

### Sound Characteristics

Recommended sound type:
- **Urgent campaign**: Double beep (short-short) - 1 detik
- **Info notification**: Single soft ding - 0.5 detik
- **Medical theme**: Hospital beep style - 0.8 detik

Avoid:
- ❌ Terlalu lama (> 10 detik)
- ❌ Terlalu keras (annoying)
- ❌ Multiple instruments (terlalu complex)
- ❌ Voice/speech (language barrier)

---

## Next Steps

1. ✅ Struktur folder sudah siap
2. ✅ Code sudah diupdate
3. ⏳ **TO DO**: Generate icon dari Android Asset Studio
4. ⏳ **TO DO**: Download/create notification sound (OGG)
5. ⏳ **TO DO**: (Optional) Convert sound ke CAF untuk iOS
6. ⏳ **TO DO**: Copy files ke folder yang benar
7. ⏳ **TO DO**: Run `flutter clean && flutter run`
8. ⏳ **TO DO**: Test notification dengan backend/Firebase Console

---

## Support

Jika ada masalah:
1. Cek file naming (harus exact match)
2. Cek file format (OGG untuk Android, CAF untuk iOS)
3. Run `flutter clean` sebelum rebuild
4. Uninstall app dari device, reinstall
5. Cek Android notification channel settings di device Settings

**References:**
- Android Asset Studio: https://romannurik.github.io/AndroidAssetStudio/
- Pixabay Audio: https://pixabay.com/sound-effects/
- OGG to CAF Converter: https://convertio.co/ogg-caf/
- Flutter Local Notifications Docs: https://pub.dev/packages/flutter_local_notifications

