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
  TextEditingController _searchLocationController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLoadingLocation = false;
  final AuthService _authService = AuthService();
  bool _showMap = false;

  @override

  void initState() {
    super.initState();
    _authService.loadingCallback = (isLoading) {
      setState(() {
        _isLoading = isLoading;
      });
    };
    _authService.errorCallback = (message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    };
    _authService.successCallback = () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BloodInfo()),
      );
    };
  }

  LatLng? userLocation;
  LatLng? selectedLocation;
  final MapController mapController = MapController();
  List<Map<String, dynamic>> _suggestions = [];
  Timer? _debounce;

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

        setState(() {
          _addressController.text =
          '${place.street}, ${place.locality}, ${place.country}';

          userLocation = LatLng(position.latitude, position.longitude);
          selectedLocation =
              userLocation; // Awalnya titik peta sama dengan lokasi asli

          mapController.move(userLocation!, 15.0);
        });
      } else {
        throw 'Gagal mendapatkan alamat';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mendapatkan lokasi: $e')),
      );
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _searchLocation(String query) async {
    final uri = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        setState(() {
          _suggestions = data
              .map((item) => {
            "display_name": item["display_name"],
            "lat": double.parse(item["lat"]),
            "lon": double.parse(item["lon"]),
          })
              .toList();
        });
      }
    } catch (e) {
      print("Error search location: $e");
    }
  }


  Future<void> _onMapTapped(LatLng tapPosition) async {
    // Set lokasi yang dipilih sesuai tap pada peta
    setState(() {
      selectedLocation = tapPosition;
      mapController.move(selectedLocation!, 15.0);
    });

    // Dapatkan alamat dari lokasi yang dipilih
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        tapPosition.latitude,
        tapPosition.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        setState(() {
          _addressController.text =
          '${place.street}, ${place.locality}, ${place.country}';
        });
      } else {
        throw 'Gagal mendapatkan alamat';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mendapatkan alamat: $e')),
      );
    }
  }

  Widget _buildLabel(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: GoogleFonts.dmSans(
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
        ),
        const SizedBox(height: 8),
      ],
    );
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
                image: AssetImage('assets/images/batik_pattern.png'),
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
              Container(
                width: screenWidth,
                height: screenHeight * 0.81,
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
                      color: Colors.black26, // Warna shadow
                      blurRadius: 10, // Efek blur
                      spreadRadius: 3, // Seberapa jauh shadow menyebar
                      offset: Offset(0, -8), // Menggeser shadow ke atas
                    ),
                  ],
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Center(
                            child: Text('ALAMAT',
                                style: GoogleFonts.dmSans(
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ))),
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
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Search TextField
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: TextField(
                                controller: _searchLocationController,
                                onChanged: (value) {
                                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                                  _debounce = Timer(Duration(milliseconds: 500), () {
                                    if (value.trim().isNotEmpty) {
                                      _searchLocation(value.trim());
                                    } else {
                                      setState(() => _suggestions = []);
                                    }
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Cari lokasi...',
                                  contentPadding: EdgeInsets.all(12),
                                  border: InputBorder.none,
                                  prefixIcon: Icon(Icons.search),
                                ),
                              ),
                            ),

                            // Dropdown Suggestion - Ditampilkan di bawah search box saja
                            // Ini dropdown suggestion, MUNCUL di atas map juga
                            if (_suggestions.isNotEmpty)
                              Positioned(
                                left: 20,
                                right: 20,
                                top: 110, // Atur sesuai posisi TextField + padding
                                child: Container(
                                  constraints: BoxConstraints(maxHeight: 200),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: _suggestions.length,
                                    itemBuilder: (context, index) {
                                      final suggestion = _suggestions[index];
                                      return ListTile(
                                        dense: true,
                                        title: Text(
                                          suggestion['display_name'],
                                          style: TextStyle(fontSize: 13),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        onTap: () async {
                                          final lat = suggestion['lat'];
                                          final lon = suggestion['lon'];

                                          setState(() {
                                            selectedLocation = LatLng(lat, lon);
                                            _suggestions.clear();
                                            mapController.move(selectedLocation!, 15.0);
                                          });

                                          try {
                                            List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
                                            if (placemarks.isNotEmpty) {
                                              Placemark place = placemarks.first;
                                              setState(() {
                                                _addressController.text =
                                                '${place.street}, ${place.locality}, ${place.country}';
                                              });
                                            }
                                          } catch (e) {
                                            print("Gagal reverse geocoding: $e");
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),

                      SizedBox(
                        height: 260,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: FlutterMap(
                                  mapController: mapController,
                                  options: MapOptions(
                                    initialCenter: userLocation ??
                                        LatLng(-6.2088, 106.8456),
                                    initialZoom: 13.0,
                                    onTap: _showMap
                                        ? (tapPosition,
                                        LatLng newPosition) async {
                                      setState(() {
                                        selectedLocation = newPosition;
                                        mapController.move(
                                            selectedLocation!, 15.0);
                                      });

                                      // Melakukan reverse geocoding untuk mendapatkan alamat dari koordinat
                                      try {
                                        List<Placemark> placemarks =
                                        await placemarkFromCoordinates(
                                          newPosition.latitude,
                                          newPosition.longitude,
                                        );

                                        if (placemarks.isNotEmpty) {
                                          Placemark place =
                                              placemarks.first;

                                          // Menampilkan alamat pada controller text
                                          setState(() {
                                            _addressController.text =
                                            '${place.street}, ${place.locality}, ${place.country}';
                                          });
                                        } else {
                                          throw 'Gagal mendapatkan alamat';
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Gagal mendapatkan alamat: $e')),
                                        );
                                      }
                                    }
                                        : null,
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate:
                                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                      subdomains: ['a', 'b', 'c'],
                                    ),
                                    if (selectedLocation != null)
                                      MarkerLayer(
                                        markers: [
                                          Marker(
                                            point: selectedLocation!,
                                            width: 50,
                                            height: 50,
                                            child: Icon(Icons.location_on,
                                                color: Colors.red, size: 40),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              // Jika peta belum dapat diklik, beri overlay dengan transparansi gelap
                              if (!_showMap)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black
                                        .withOpacity(0.6), // Transparansi gelap
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white, // Warna border putih
                                      width: 0.5, // Ketebalan border 0.5
                                    ),
                                  ),
                                  child: Center(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _showMap =
                                          true; // Mengizinkan interaksi peta
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 20),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(16),
                                        ),
                                        side: BorderSide(
                                          color: Colors
                                              .white, // Warna border putih
                                          width: 0.5, // Ketebalan border 0.8
                                        ),
                                        backgroundColor: Color(
                                            0xFFAB4545), // Mengganti primary dengan backgroundColor
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize
                                            .min, // Agar tombol tidak meluas lebih lebar
                                        children: [
                                          Icon(Icons.location_on,
                                              color:
                                              Colors.white), // Pin lokasi
                                          SizedBox(
                                              width:
                                              8), // Memberikan jarak antara icon dan teks
                                          Text(
                                            "Tentukan Pada Peta",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 50,
                        width: double
                            .infinity, // Mengatur lebar mengikuti container lainnya
                        child: ElevatedButton.icon(
                          onPressed:
                          _isLoadingLocation ? null : _getCurrentLocation,
                          icon: const Icon(Icons.location_on,
                              color: Colors.white), // Ikon putih
                          label: _isLoadingLocation
                              ? const Text(
                            'Mendapatkan lokasi...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ), // Ukuran teks besar
                          )
                              : const Text(
                            'Gunakan Lokasi Saat Ini',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ), // Ukuran teks besar
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD29A42),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(
                                color: Colors.white, // Warna border putih
                                width: 0.5, // Ketebalan border 0.5
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _addressController,
                        maxLines: 4,
                        readOnly: true,
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.bold), // Warna teks putih
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white
                              .withOpacity(0.11), // Warna latar belakang
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                                color: Colors.white), // Warna border putih
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                                color: Colors.white,
                                width: 0.5), // Border putih saat tidak fokus
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                                color: Colors.white,
                                width: 0.5), // Border putih saat fokus
                          ),
                          hintText: 'Alamat lengkap',
                          hintStyle: TextStyle(
                              color: Colors.white.withOpacity(
                                  0.6)), // Warna hint putih transparan
                        ),
                      ),
                      const SizedBox(height: 26),
                      MyButton(
                        text: _isLoading ? "Memproses..." : "Lanjut",
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (_addressController.text.isEmpty) {
                              // Menampilkan pesan kesalahan jika alamat kosong
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Alamat harus dipilih terlebih dahulu!')),
                              );
                            } else {

                              _authService.saveAddress(
                                  _addressController.text, 95.123, 4.123, context);
                            }
                          }
                        },
                      ),
                      const Spacer(),
                      CopyrightWidget(),
                    ],
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
