## Map Tiles Troubleshooting - DarahTanyoe App

### Problem
Map tiles tidak muncul (biru kosong) di physical device, terutama di jaringan lambat atau saat OpenStreetMap server sedang lambat/rate-limited.

### Solutions Implemented

#### 1. Loading Indicator
- Menampilkan loading overlay selama 5 detik pertama
- Auto-hide saat user tap map atau get location
- Memberikan feedback visual yang jelas

#### 2. Optimized Tile Configuration
- `backgroundColor: Colors.lightBlue.shade50` - Background saat tiles loading
- Simplified URL tanpa subdomains untuk mengurangi DNS lookup
- User agent header untuk avoid rate limiting

### Alternative Tile Providers

Jika OpenStreetMap masih lambat, bisa ganti dengan provider alternatif:

#### Option 1: OpenStreetMap Germany (Lebih stabil untuk Asia)
```dart
TileLayer(
  urlTemplate: 'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
  userAgentPackageName: 'com.darahtanyoe.app',
),
```

#### Option 2: Carto DB Voyager (Lebih cepat, modern style)
```dart
TileLayer(
  urlTemplate: 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
  userAgentPackageName: 'com.darahtanyoe.app',
),
```

#### Option 3: Stadia Maps (Free tier: 200K tiles/month)
```dart
TileLayer(
  urlTemplate: 'https://tiles.stadiamaps.com/tiles/osm_bright/{z}/{x}/{y}.png',
  userAgentPackageName: 'com.darahtanyoe.app',
),
```

#### Option 4: Google Maps (Berbayar, paling stabil)
Perlu setup Google Maps API key di AndroidManifest.xml dan menggunakan `google_maps_flutter` package.

### Network Optimization

#### 1. Add to AndroidManifest.xml
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

#### 2. Enable HTTP Cleartext (untuk debugging)
Di `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```

⚠️ **WARNING**: Jangan aktifkan `usesCleartextTraffic` di production!

### Testing Checklist

- [ ] Test di WiFi cepat
- [ ] Test di cellular data (3G/4G)
- [ ] Test di jaringan lambat
- [ ] Test dengan offline mode (harus tampilkan error yang jelas)
- [ ] Cek console log untuk tile loading errors

### Monitoring Performance

Tambahkan logging di initState:
```dart
@override
void initState() {
  super.initState();
  
  // Log untuk debug tile loading
  print('Map initialized at ${DateTime.now()}');
  
  mapController.mapEventStream.listen((event) {
    print('Map event: ${event.runtimeType}');
  });
}
```

### Long-term Solution

Untuk production, consider:
1. **Self-hosted tile server** - Cache tiles sendiri untuk performa konsisten
2. **Google Maps Platform** - Berbayar tapi paling reliable
3. **Mapbox** - Balance antara harga dan performa
4. **Hybrid approach** - Fallback ke multiple tile providers

### Current Implementation
File: `lib/pages/authentication/address_page.dart`
- Primary: OpenStreetMap.org tiles
- Loading indicator: 5 seconds auto-dismiss
- Manual dismiss: Tap map atau get location
- Background: Light blue untuk visual feedback
