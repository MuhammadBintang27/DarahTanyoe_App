import 'package:flutter/material.dart';
import 'package:darahtanyoe_app/service/toast_service.dart';
import 'package:intl/intl.dart';
import 'package:darahtanyoe_app/theme/theme.dart';
import '../../components/background_widget.dart';
import '../../service/auth_service.dart';
import '../../widget/header_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class EditProfilPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfilPage({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  final AuthService _authService = AuthService();
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController healthNotesController;
  
  bool isLoading = false;
  bool isLoadingLocation = false;
  double? newLatitude;
  double? newLongitude;
  String newAddress = '';
  final MapController mapController = MapController();
  LatLng? selectedLocation;
  bool showLocationPicker = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.userData['email'] ?? '');
    phoneController = TextEditingController(text: widget.userData['phone_number'] ?? '');
    addressController = TextEditingController(text: widget.userData['address'] ?? '');
    healthNotesController = TextEditingController(text: widget.userData['health_notes'] ?? '');
    newAddress = widget.userData['address'] ?? '';
    selectedLocation = const LatLng(-6.2088, 106.8456);
  }

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    healthNotesController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => isLoadingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Izin lokasi ditolak';
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw 'Izin lokasi ditolak secara permanen';
      }

      Position position = await Geolocator.getCurrentPosition();
      
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        if (mounted) {
          setState(() {
            newLatitude = position.latitude;
            newLongitude = position.longitude;
            newAddress = '${place.street}, ${place.locality}, ${place.country}';
            selectedLocation = LatLng(position.latitude, position.longitude);
            mapController.move(selectedLocation!, 15.0);
            addressController.text = newAddress;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError(context, message: 'Gagal mendapatkan lokasi: $e');
      }
    } finally {
      if (mounted) {
        setState(() => isLoadingLocation = false);
      }
    }
  }

  Future<void> _onMapTapped(LatLng tapPosition) async {
    setState(() {
      selectedLocation = tapPosition;
      newLatitude = tapPosition.latitude;
      newLongitude = tapPosition.longitude;
      mapController.move(selectedLocation!, 15.0);
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        tapPosition.latitude,
        tapPosition.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        if (mounted) {
          setState(() {
            newAddress = '${place.street}, ${place.locality}, ${place.country}';
            addressController.text = newAddress;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError(context, message: 'Gagal mendapatkan alamat: $e');
      }
    }
  }

  Future<void> _saveChanges() async {
    setState(() => isLoading = true);

    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? '';
      final userId = widget.userData['id'];
      
      print('🔍 DEBUG: Base URL: $baseUrl');
      print('🔍 DEBUG: User ID: $userId');
      print('🔍 DEBUG: User ID type: ${userId.runtimeType}');
      
      if (userId == null || userId.toString().isEmpty) {
        throw Exception('User ID tidak ditemukan');
      }

      final url = Uri.parse('$baseUrl/users/update/$userId');
      print('🔍 DEBUG: Full URL: $url');

      final Map<String, dynamic> updateData = {
        'email': emailController.text,
        'phone_number': phoneController.text,
        'address': addressController.text,
        'health_notes': healthNotesController.text,
      };

      // Include location if updated
      if (newLatitude != null && newLongitude != null) {
        updateData['latitude'] = newLatitude;
        updateData['longitude'] = newLongitude;
      }

      print('🔍 DEBUG: Update data: $updateData');

      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updateData),
      );

      print('🔍 DEBUG: Response status: ${response.statusCode}');
      print('🔍 DEBUG: Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Update localStorage dengan data terbaru
        final updatedUser = {
          ...widget.userData,
          'email': emailController.text,
          'phone_number': phoneController.text,
          'address': addressController.text,
          'health_notes': healthNotesController.text,
          if (newLatitude != null) 'latitude': newLatitude,
          if (newLongitude != null) 'longitude': newLongitude,
        };

        // Update di AuthService
        await _authService.updateUserData(updatedUser);

        if (mounted) {
          ToastService.showSuccess(context, message: 'Profil berhasil diperbarui');
          Navigator.pop(context, true); // Return true to indicate refresh needed
        }
      } else {
        throw Exception('Gagal mengupdate profil: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR: $e');
      if (mounted) {
        ToastService.showError(context, message: 'Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: SafeArea(
          child: Column(
            children: [
              HeaderWidget(),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Edit Profil',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Email Section
                        const Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            hintText: 'Email Anda',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Phone Section
                        const Text(
                          'Nomor Telepon',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: phoneController,
                          decoration: InputDecoration(
                            hintText: 'Nomor telepon Anda',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Address Section
                        const Text(
                          'Alamat',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: addressController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Alamat lengkap Anda',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() => showLocationPicker = !showLocationPicker);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.brand_02,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                            ),
                            label: Text(
                              showLocationPicker ? 'Tutup Peta' : 'Pilih di Peta',
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'DM Sans',
                              ),
                            ),
                          ),
                        ),

                        // Location Picker
                        if (showLocationPicker) ...[
                          const SizedBox(height: 16),
                          Container(
                            height: 240,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                children: [
                                  FlutterMap(
                                    mapController: mapController,
                                    options: MapOptions(
                                      initialCenter: selectedLocation ??
                                          const LatLng(-6.2088, 106.8456),
                                      initialZoom: 13.0,
                                      onTap: (tapPosition, newPosition) {
                                        _onMapTapped(newPosition);
                                      },
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      ),
                                      if (selectedLocation != null)
                                        MarkerLayer(
                                          markers: [
                                            Marker(
                                              point: selectedLocation!,
                                              width: 40,
                                              height: 40,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withValues(alpha: 0.3),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                                child: const Icon(
                                                  Icons.location_on,
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: isLoadingLocation ? null : _getCurrentLocation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.brand_02,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: isLoadingLocation
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                    ),
                              label: Text(
                                isLoadingLocation
                                    ? 'Mengambil Lokasi...'
                                    : 'Gunakan Lokasi Saat Ini',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'DM Sans',
                                ),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Health Notes Section
                        const Text(
                          'Catatan Kesehatan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: healthNotesController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Catatan kesehatan atau alergi',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _saveChanges,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.brand_03,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Simpan Perubahan',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      fontFamily: 'DM Sans',
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
