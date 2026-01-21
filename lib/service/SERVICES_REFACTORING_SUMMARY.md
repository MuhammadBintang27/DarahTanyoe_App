# Services Layer Refactoring Summary

## Overview
Services layer telah direfactor untuk align dengan model baru (PermintaanDarahModel, NotificationModel, DonorConfirmationModel) dan menghapus services yang sudah tidak digunakan.

---

## ✅ New Services Created

### 1. **CampaignService** (`campaign_service.dart`)
Menggantikan: `PermintaanDarahService` + `PermintaanTerdekat`

**Methods:**
- `getCampaignById(campaignId)` → Maps: GET `/campaigns/:id`
- `getAllActiveCampaigns()` → Maps: GET `/campaigns?status=active`
- `getNearestCampaigns(userId)` → Maps: GET `/campaigns/nearby/:userId`
- `getCampaignsByBloodType(bloodType)` → Maps: GET `/campaigns?blood_type=X`

**Returns:** `Future<PermintaanDarahModel>` atau `Future<List<PermintaanDarahModel>>`

---

### 2. **NotificationService V2** (`notification_service_v2.dart`)
Menggantikan: Old FCM-only notification service

**Methods:**
- `getNotifications(userId)` → Maps: GET `/notifications/:userId`
- `getUnreadNotifications(userId)` → Maps: GET `/notifications/:userId?unread=true`
- `getUnreadCount(userId)` → Maps: GET `/notifications/:userId/unread/count`
- `markAsRead(notificationId)` → Maps: PATCH `/notifications/:notificationId/read`
- `markAllAsRead(userId)` → Maps: PATCH `/notifications/user/:userId/read-all`
- `deleteNotification(notificationId)` → Maps: DELETE `/notifications/:notificationId`
- `deleteExpiredNotifications(userId)` → Maps: DELETE `/notifications/user/:userId/expired`

**Returns:** `Future<NotificationModel>` atau `Future<List<NotificationModel>>` atau `Future<int>` untuk count

---

### 3. **DonorConfirmationService** (`donor_confirmation_service.dart`)
Service baru untuk donor confirmation lifecycle

**Methods:**
- `confirmDonation(fulfillmentRequestId, campaignId, donorId)` → Maps: POST `/fulfillment/donor-confirm`
  - Returns unique code yang auto-generated dari backend
- `rejectDonation(fulfillmentRequestId, donorId, reason?)` → Maps: POST `/fulfillment/donor-reject`
- `getPendingConfirmations(donorId)` → Maps: GET `/donor-confirmations/pending/:donorId`
- `getConfirmationHistory(donorId)` → Maps: GET `/donor-confirmations/:donorId`
- `verifyCode(uniqueCode, pmiId)` → Maps: POST `/fulfillment/verify-code`
- `getConfirmationDetail(confirmationId)` → Maps: GET `/donor-confirmations/:confirmationId`
- `getConfirmationByCode(uniqueCode)` → Maps: GET `/donor-confirmations/code/:uniqueCode`

**Returns:** `Future<DonorConfirmationModel>` atau `Future<List<DonorConfirmationModel>>` atau `Future<bool>`

---

## 🗑️ Deprecated Services

### 1. **PermintaanDarahService** (DEPRECATED)
- **Status:** Converted to stub file dengan export ke `CampaignService`
- **Migration Path:** 
  - `getAllPermintaan()` → `CampaignService.getAllActiveCampaigns()`
  - `getPermintaanByUniqueCode()` → Use `DonorConfirmationService.getConfirmationByCode()` instead
  - `simpanPermintaan()` → Remove (old blood request creation, not in new flow)
  - `updatePermintaan()` → Remove (old flow)
  - `deletePermintaan()` → Remove (old flow)
- **Status Reason:** Old asset-based system replaced by API-driven notification system

### 2. **PermintaanTerdekat** (DEPRECATED)
- **Status:** Converted to stub file dengan export ke `CampaignService`
- **Migration Path:**
  - `fetchBloodRequests(userId)` → `CampaignService.getNearestCampaigns(userId)`
- **Status Reason:** Merged into unified `CampaignService`

### 3. **NotificationService** (Old version - DEPRECATED)
- **Status:** Converted to stub file dengan export ke `NotificationService V2`
- **Old Methods Removed:**
  - `initialize()`
  - `_initFirebaseMessaging()`
  - `_requestNotificationPermissions()`
  - `_initLocalNotifications()`
  - `_setupFCMHandlers()`
  - `showLocalNotification()`
  - `scheduleLocalNotification()`
  - `_firebaseMessagingBackgroundHandler()`
- **Status Reason:** Replaced with proper API-driven notification service layer

---

## 📝 Code Usage Examples

### Getting Campaign Details
```dart
// Old way (DEPRECATED)
// final campaign = await PermintaanDarahService.getAllPermintaan();

// New way
final campaign = await CampaignService.getCampaignById(campaignId);
```

### Getting Nearby Campaigns
```dart
// Old way (DEPRECATED)
// final campaigns = await PermintaanTerdekat().fetchBloodRequests(userId);

// New way
final campaigns = await CampaignService.getNearestCampaigns(userId);
```

### Managing Notifications
```dart
// Old way (DEPRECATED)
// Direct FCM handling only

// New way
final notifications = await NotificationService.getNotifications(userId);
final unreadCount = await NotificationService.getUnreadCount(userId);
await NotificationService.markAsRead(notificationId);
```

### Donor Confirmation Flow
```dart
// Confirm donation when donor taps notification
final confirmation = await DonorConfirmationService.confirmDonation(
  fulfillmentRequestId: fulfillmentId,
  campaignId: campaignId,
  donorId: donorId,
);
// confirmation.uniqueCode contains the auto-generated code

// Get pending confirmations for donor
final pending = await DonorConfirmationService.getPendingConfirmations(donorId);

// PMI verifies code
final verified = await DonorConfirmationService.verifyCode(
  uniqueCode: confirmation.uniqueCode,
  pmiId: pmiId,
);
```

---

## 📊 Service Architecture

```
┌─────────────────────────────────────┐
│       UI Layer (Pages/Widgets)      │
└────────────┬────────────────────────┘
             │
    ┌────────┴──────────┬──────────────────┐
    │                   │                  │
    ▼                   ▼                  ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────────┐
│   Campaign   │  │Notification  │  │  DonorConfirm    │
│   Service    │  │   Service    │  │   Service        │
└──────────────┘  └──────────────┘  └──────────────────┘
    │                   │                  │
    ▼                   ▼                  ▼
┌────────────────────────────────────────────────────────┐
│                  HTTP Client (http package)            │
└────────────────────────────────────────────────────────┘
    │
    ▼
┌────────────────────────────────────────────────────────┐
│         Backend API (Node.js/Express)                  │
│   - /campaigns endpoints                               │
│   - /notifications endpoints                           │
│   - /fulfillment & /donor-confirmations endpoints      │
└────────────────────────────────────────────────────────┘
```

---

## 🔄 Model-Service Alignment

| Model | Service | Endpoints |
|-------|---------|-----------|
| `PermintaanDarahModel` | `CampaignService` | GET `/campaigns/:id`, GET `/campaigns`, GET `/campaigns/nearby/:userId`, GET `/campaigns?blood_type=X` |
| `NotificationModel` | `NotificationService` | GET `/notifications/:userId`, PATCH `/notifications/:id/read`, DELETE `/notifications/:id` |
| `DonorConfirmationModel` | `DonorConfirmationService` | POST `/fulfillment/donor-confirm`, GET `/donor-confirmations/:id`, GET `/donor-confirmations/code/:code`, POST `/fulfillment/verify-code` |

---

## ⚠️ Files Still Using Old Services (Need Update)

1. **home_screen.dart** - Uses `PermintaanTerdekat`
2. **permintaan_darah_terdekat.dart** - Uses `PermintaanTerdekat`
3. **validasi.dart** - Uses `PermintaanDarahService`
4. **transaksi.dart** - Has commented `PermintaanDarahService` usage

These files should be refactored to use the new services:
- Replace `PermintaanTerdekat` with `CampaignService`
- Replace `PermintaanDarahService` with `CampaignService` or `DonorConfirmationService`

---

## ✨ Benefits of New Architecture

1. **Unified API Interface:** Satu entry point untuk setiap domain (Campaign, Notification, Confirmation)
2. **Type Safety:** Semua methods return properly typed models
3. **Consistent Error Handling:** Semua service methods handle errors consistently
4. **Scalability:** Easy untuk menambah methods tanpa mengubah existing code
5. **Testability:** Services dapat di-mock untuk unit testing
6. **Alignment with Backend:** Services langsung map ke API endpoints, zero mismatch
7. **Backwards Compatibility:** Old service files masih ada sebagai stubs (re-exports)

---

## 🚀 Next Steps

1. Update screens yang masih menggunakan old services
2. Implement notification UI screens dengan NotificationService
3. Implement campaign detail screens dengan CampaignService
4. Implement confirmation flow screens dengan DonorConfirmationService
5. Add error handling dan retry logic ke services
6. Add local caching untuk frequently accessed data
7. Add request timeout dan connection error handling
