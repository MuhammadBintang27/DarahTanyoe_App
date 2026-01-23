# Push Notification Implementation untuk DarahTanyoe

## Overview

Implementasi push notifications menggunakan Firebase Cloud Messaging (FCM) untuk mengirim notifikasi real-time ke mobile app saat campaign (fulfillment) dikirim.

## Arsitektur

```
Backend (Node.js/Express)
    ↓
    └─ sendNotificationsToSelectedDonors()
        ↓
        └─ Save FCM tokens dari mobile app
        ↓
        └─ Send via Firebase Admin SDK
        ↓
Mobile App (Flutter)
    ↓
    └─ PushNotificationService
        ↓
        ├─ Register & get FCM token
        ├─ Save token ke backend
        ├─ Listen untuk incoming notifications
        └─ Display local notifications
```

## Setup Instructions

### 1. Backend Setup

#### Firebase Credentials
Pastikan `.env` memiliki Firebase credentials:

```env
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_PRIVATE_KEY_ID=your_private_key_id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----"
FIREBASE_CLIENT_EMAIL=your_service_account@...
FIREBASE_CLIENT_ID=your_client_id
```

#### Database Migration
Pastikan `push_tokens` table sudah ada:

```sql
CREATE TABLE push_tokens (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  fcm_token TEXT NOT NULL,
  platform VARCHAR(10) CHECK (platform IN ('android', 'ios')),
  last_used_at TIMESTAMPTZ,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(user_id, fcm_token)
);
```

### 2. Mobile App Setup

#### Add Dependencies
```yaml
dependencies:
  firebase_messaging: ^14.0.0
  flutter_local_notifications: ^17.0.0
  http: ^1.1.0
```

#### Firebase Configuration
1. Create Firebase project di [Firebase Console](https://console.firebase.google.com)
2. Add Android app:
   - Package: com.example.darahtanyoe_app
   - Download `google-services.json` ke `android/app/`
3. Add iOS app:
   - Bundle ID: com.example.darahTanyoeApp
   - Download `GoogleService-Info.plist` ke `ios/Runner/`

#### Android Setup
Update `android/app/build.gradle`:

```gradle
plugins {
    id 'com.android.application'
    id 'kotlin-android'
    id 'com.google.gms.google-services'
}

dependencies {
    implementation 'com.google.firebase:firebase-messaging'
}
```

Update `android/build.gradle`:

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

#### iOS Setup
Update `ios/Podfile`:

```ruby
platform :ios, '12.0'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_CAMERA=1'
      ]
    end
  end
end
```

### 3. Initialize Service

Di `main.dart`:

```dart
import 'service/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize push notifications
  final pushService = PushNotificationService();
  await pushService.initialize();
  
  runApp(const MyApp());
}
```

## Flow Diagram

### 1. Donor Notification Flow

```
Step 1: Frontend (Web) - Create Fulfillment
┌─────────────────────────────┐
│ POST /fulfillment/search... │
│ (Create campaign & get      │
│  eligible donors)           │
└──────────────┬──────────────┘
               ↓
Step 2: Slider Selection
┌──────────────────────────────┐
│ User selects N donors        │
│ POST /fulfillment/.../send.. │
└──────────────┬───────────────┘
               ↓
Step 3: Backend - Send Notifications
┌──────────────────────────────────┐
│ 1. Get N donors from             │
│    donor_confirmations (status   │
│    = pending_notification)       │
│ 2. Get their FCM tokens from     │
│    push_tokens table             │
│ 3. Send via Firebase Admin SDK   │
│ 4. Update status → pending       │
└──────────────┬───────────────────┘
               ↓
Step 4: Mobile App - Receive & Display
┌──────────────────────────────────┐
│ 1. FCM receives notification     │
│ 2. Show local notification       │
│ 3. User taps → navigate to       │
│    campaign detail               │
│ 4. Display in Notifikasi page    │
└──────────────────────────────────┘
```

### 2. Token Lifecycle

```
App Startup
    ↓
Initialize PushNotificationService
    ↓
Get FCM token from Firebase
    ↓
Save to backend: POST /notification/save-token
    ↓
Token stored in push_tokens table
    ↓
Token refreshed automatically by Firebase
    ↓
Update backend with new token
```

## API Endpoints

### Save FCM Token
```http
POST /notification/save-token
Content-Type: application/json

{
  "user_id": "uuid",
  "fcm_token": "token_string",
  "platform": "android" | "ios"
}
```

Response:
```json
{
  "status": "SUCCESS",
  "message": "FCM token saved successfully",
  "data": {
    "id": "uuid",
    "user_id": "uuid",
    "fcm_token": "token_string",
    "platform": "android"
  }
}
```

## Notification Payload

### Campaign Fulfillment Notification

```json
{
  "notification": {
    "title": "Donor Darah Dibutuhkan!",
    "body": "Rahman membutuhkan darah O+ di Banda Aceh"
  },
  "data": {
    "type": "blood_campaign",
    "relatedType": "fulfillment",
    "campaign_id": "uuid",
    "fulfillment_id": "uuid",
    "blood_type": "O+",
    "urgency": "high",
    "patient_name": "Rahman",
    "location": "Banda Aceh"
  }
}
```

## Testing

### Manual Test dengan cURL

```bash
# Save token
curl -X POST http://localhost:4000/notification/save-token \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "user-uuid",
    "fcm_token": "test_fcm_token",
    "platform": "android"
  }'
```

### Test dengan Postman
1. Import collection dari Firebase Console
2. Use "Send to Device" endpoint dengan FCM token dari mobile app

### Emulator Testing
```bash
# Android
flutter run -d emulator-5554

# iOS
flutter run -d simulator
```

Monitor logs:
```bash
flutter logs
```

## Troubleshooting

### Token not saved
- Check if user is authenticated
- Verify API URL is correct
- Check network connectivity

### Notifications not received
- Ensure FCM token is saved to backend
- Check Firebase credentials in .env
- Verify notification permissions on device
- Check Android notification channel settings

### Can't initialize Firebase
- Download `google-services.json` again
- Verify Firebase project ID matches
- Check iOS pod installation

## Database Schema

```sql
-- Push tokens untuk menyimpan FCM tokens dari mobile devices
CREATE TABLE push_tokens (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  fcm_token TEXT NOT NULL UNIQUE,
  platform VARCHAR(10) NOT NULL CHECK (platform IN ('android', 'ios')),
  last_used_at TIMESTAMPTZ,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_push_tokens_user_id ON push_tokens(user_id);
CREATE INDEX idx_push_tokens_active ON push_tokens(active);
```

## Next Steps

1. ✅ Implement PushNotificationService
2. ✅ Create saveFCMToken endpoint
3. ⏳ Integrate with fulfillmentController (send notifications)
4. ⏳ Update Notifikasi.dart to show fulfillment notifications
5. ⏳ Add notification tap handling for navigation
6. ⏳ Test end-to-end flow

## Referensi

- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- [firebase_messaging for Flutter](https://pub.dev/packages/firebase_messaging)
