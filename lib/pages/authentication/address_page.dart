import 'dart:async';
import 'dart:convert';

import 'package:darahtanyoe_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:darahtanyoe_app/components/copyright.dart';
import 'package:darahtanyoe_app/components/my_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../service/auth_service.dart';
import 'blood_info.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  _AddressPageState createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final TextEditingController _addressController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLoadingLocation = false;
  final AuthService _authService = AuthService();

  LatLng? userLocation;
  LatLng? selectedLocation;
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    _authService.loadingCallback = (isLoading) {
      if (mounted) {
        setState(() {
          _isLoading = isLoading;
        });
      }
    };

    _authService.errorCallback = (message) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    };

    _authService.successCallback = () {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BloodInfo()),
        );
      }
    };
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
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
            _addressController.text =
                '${place.street}, ${place.locality}, ${place.country}';
            userLocation = LatLng(position.latitude, position.longitude);
            selectedLocation = userLocation;
            mapController.move(userLocation!, 15.0);
          });
        }
      } else {
        throw 'Gagal mendapatkan alamat';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mendapatkan lokasi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  Future<void> _onMapTapped(LatLng tapPosition) async {
    setState(() {
      selectedLocation = tapPosition;
      mapController.move(selectedLocation!, 15.0);
    });

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(
        tapPosition.latitude,
        tapPosition.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        if (mounted) {
          setState(() {
            _addressController.text =
                '${place.street}, ${place.locality}, ${place.country}';
          });
        }
      } else {
        throw 'Gagal mendapatkan alamat';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mendapatkan alamat: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: const AssetImage('assets/images/batik_pattern.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: SafeArea(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Image.asset(
                        'assets/images/darah_tanyoe_logo.png',
                        width: 300,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  width: screenWidth,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.brand_01,
                        Color(0xFFCC8888),
                        Color(0xFFF8F0F0),
                      ],
                      stops: [0.2, 0.7, 1.0],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 3,
                        offset: Offset(0, -8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Stack(
                            children: [
                              Center(
                                child: Text(
                                  'ALAMAT',
                                  style: GoogleFonts.dmSans(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Map Section
                          Container(
                            height: 240,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
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
                                      initialCenter: userLocation ??
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
                                                          .withOpacity(0.3),
                                                      blurRadius: 8,
                                                      offset:
                                                          const Offset(0, 4),
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
                                  // Button Overlay on Map
                                  Positioned(
                                    bottom: 12,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          // Button untuk perubahan lokasi pada peta
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Klik pada peta untuk memilih lokasi',
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFD1495A),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.location_on,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        label: Text(
                                          'Perubahan Pada Peta',
                                          style: GoogleFonts.dmSans(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Current Location Button (Yellow)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoadingLocation
                                  ? null
                                  : _getCurrentLocation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD4A574),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledBackgroundColor:
                                    const Color(0xFFD4A574).withOpacity(0.5),
                              ),
                              icon: _isLoadingLocation
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                              label: Text(
                                _isLoadingLocation
                                    ? 'Mengambil Lokasi...'
                                    : 'Gunakan Lokasi Saat Ini',
                                style: GoogleFonts.dmSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Address Display Box (Pink)
                          if (selectedLocation != null)
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8C4C8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: Color(0xFFC1666B),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _addressController.text.isNotEmpty
                                              ? _addressController.text
                                              : 'Mengambil alamat...',
                                          style: GoogleFonts.dmSans(
                                            color: const Color(0xFF5A3A3F),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8C4C8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'Pilih lokasi di peta atau gunakan lokasi saat ini',
                                  style: GoogleFonts.dmSans(
                                    color: const Color(0xFF5A3A3F),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),

                          // Continue Button
                          MyButton(
                            text: _isLoading ? 'Memproses...' : 'Lanjut',
                            onPressed: () {
                              if (selectedLocation == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Pilih lokasi terlebih dahulu',
                                    ),
                                  ),
                                );
                                return;
                              }

                              if (_formKey.currentState!.validate()) {
                                setState(() => _isLoading = true);
                                _authService.saveAddress(
                                  _addressController.text,
                                  selectedLocation!.latitude,
                                  selectedLocation!.longitude,
                                  context,
                                );
                              }
                            },
                            color: const Color(0xFF476EB6),
                          ),
                          const SizedBox(height: 20),
                          CopyrightWidget(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
