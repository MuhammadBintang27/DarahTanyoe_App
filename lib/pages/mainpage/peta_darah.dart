import 'package:darahtanyoe_app/components/background_widget.dart';
import 'package:darahtanyoe_app/theme/theme.dart';
import 'package:darahtanyoe_app/widget/header_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class BloodMap extends StatefulWidget {
  const BloodMap({super.key});

  @override
  State<BloodMap> createState() => _BloodMapState();
}

class _BloodMapState extends State<BloodMap> {
  String selectedBloodType = "A+";
  LatLng? userLocation;
  MapController mapController = MapController();
  TextEditingController searchController = TextEditingController();

  final List<String> bloodTypeOptions = [
    "A+",
    "A-",
    "B+",
    "B-",
    "AB+",
    "AB-",
    "O+",
    "O-"
  ];
  List<Map<String, dynamic>> locationSuggestions = [];
  List<Map<String, dynamic>> _bloodStockData = [];

  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _fetchBloodStock();
  }

  List<Map<String, dynamic>> _searchResults = []; // Hasil pencarian

// Fungsi untuk memfilter rumah sakit berdasarkan nama
  void _searchHospitals(String query) {
    final results = _bloodStockData.where((hospital) {
      final hospitalName = hospital['name'].toLowerCase();
      final searchQuery = query.toLowerCase();

      return hospitalName.contains(searchQuery); // Pencarian nama rumah sakit
    }).toList();

    setState(() {
      _searchResults = results; // Menyimpan hasil pencarian
    });
  }

  Future<void> _fetchBloodStock() async {
    final String baseUrl = dotenv.env['BASE_URL'] ?? 'https://default-url.com';

    final url = Uri.parse("$baseUrl/partners/");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _bloodStockData =
          List<Map<String, dynamic>>.from(data["data"].map((hospital) => {
            "name": hospital["name"],
            "latitude": hospital["latitude"],
            "longitude": hospital["longitude"],
            "blood_stock": List<Map<String, dynamic>>.from(
                hospital["blood_stock"]),
          }));
        });
      }
    } catch (e) {
      print("Error fetching blood stock data: $e");
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Layanan lokasi tidak aktif.')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin lokasi ditolak.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Izin lokasi diblokir secara permanen.')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
    });

    mapController.move(userLocation!, 13.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BackgroundWidget(
          child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeaderWidget(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Peta Darah",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.neutral_01),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 16.0, left: 16.0, right: 16.0),
                child: Divider(color: Colors.black26, thickness: 0.8),
              ),

              /// Row untuk Golongan Darah & Search Lokasi
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    /// Dropdown Golongan Darah (30%)
                    Flexible(
                      flex: 4, // 30%
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 0),
                        decoration: BoxDecoration(
                          color: Colors
                              .transparent, // Set agar tidak ada warna default di luar
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(
                                20), // Kiri atas dengan radius 20
                            bottomLeft: Radius.circular(
                                20), // Kiri bawah dengan radius 20
                            topRight: Radius.circular(
                                20), // Kanan atas tanpa radius
                            bottomRight: Radius.circular(
                                20), // Kanan bawah tanpa radius
                          ),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: Row(
                          children: [
                            // Bagian kiri (60% lebar) - Tetap dengan warna dan gaya yang sama
                            Expanded(
                              flex: 6, // 60%
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Color(0xFFA9A9A9).withOpacity(
                                      0.21), // Warna bagian kiri
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(
                                        20), // Kiri atas dengan radius 20
                                    bottomLeft: Radius.circular(
                                        20), // Kiri bawah dengan radius 20
                                    topRight: Radius.circular(
                                        0), // Kanan atas tanpa radius
                                    bottomRight: Radius.circular(
                                        0), // Kanan bawah tanpa radius
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "Golongan\nDarah",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Bagian kanan (40% lebar) - Dropdown dengan warna merah dan teks putih
                            Expanded(
                              flex: 4, // 40%
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Color(
                                      0xFFAB4545), // Warna merah untuk bagian kanan
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(
                                        0), // Kiri atas tanpa radius
                                    bottomLeft: Radius.circular(
                                        0), // Kiri bawah tanpa radius
                                    topRight: Radius.circular(
                                        20), // Kanan atas dengan radius 20
                                    bottomRight: Radius.circular(
                                        20), // Kanan bawah dengan radius 20
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: selectedBloodType.isNotEmpty ? selectedBloodType : null,
                                    dropdownColor: const Color(0xFFAB4545),
                                    icon: const Icon(
                                      Icons.arrow_drop_down, // atau Icons.arrow_drop_down_circle
                                      color: Colors.white,   // ubah warna icon jadi putih
                                    ),
                                    items: bloodTypeOptions.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedBloodType = newValue ?? "";
                                      });
                                    },
                                    selectedItemBuilder: (BuildContext context) {
                                      return bloodTypeOptions.map<Widget>((String value) {
                                        return Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            value,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      }).toList();
                                    },
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 10.0),

                    /// Inputan Search Lokasi (70%)
                    Flexible(
                      flex: 6, // 70%
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Color(0xFFA9A9A9).withOpacity(0.21),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              // TextField untuk pencarian rumah sakit
                              child: TextField(
                                controller: searchController,
                                decoration: InputDecoration(
                                  hintText: "Cari RS / PMI",
                                  hintStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black26,
                                  ),
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                                onChanged: (value) {
                                  // Melakukan pencarian rumah sakit berdasarkan inputan
                                  _searchHospitals(value);
                                },
                              ),
                            ),
                            SizedBox(
                                width:
                                8), // Jarak antara inputan dan tombol search
                            GestureDetector(
                              onTap: () {
                                // Pencarian dilakukan saat tombol search ditekan
                                _searchHospitals(searchController.text);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red[
                                      200]!, // Shadow dengan warna merah gelap
                                      offset: Offset(0,
                                          0), // Posisi shadow (horizontal, vertikal)
                                      blurRadius: 12, // Jarak sebar shadow
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/images/search_button.png',
                                  width: 30, // Sesuaikan ukuran gambar
                                  height: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26.0),
              SizedBox(
                height: 460,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(0.25), // Shadow lebih gelap
                          blurRadius: 2, // Blur lebih halus
                          offset: Offset(
                              0, 6), // Shadow ke bawah untuk efek depth
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          // Ganti peta dengan gambar statis
                          Image.asset(
                            'assets/images/bg_peta.png',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),

                          Positioned(
                            top: 10,
                            left: 10,
                            right: 10,
                            child: Column(
                              children: [
                                SizedBox(height: 20),
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    // Wrap untuk menampilkan semua rumah sakit atau hasil pencarian
                                    Wrap(
                                      spacing: 10.0, // Jarak antar item
                                      runSpacing: 10.0, // Jarak antar baris
                                      children: (_searchResults.isEmpty
                                          ? _bloodStockData
                                          : _searchResults)
                                          .map<Widget>((hospital) {
                                        var selectedStock =
                                        hospital["blood_stock"]
                                            .firstWhere(
                                              (blood) =>
                                          blood["blood_type"] ==
                                              selectedBloodType,
                                          orElse: () => {"quantity": 0},
                                        ); // Default 0 jika tidak ditemukan

                                        int hospitalIndex =
                                        _bloodStockData.indexOf(
                                            hospital); // Mendapatkan indeks rumah sakit

                                        return StatefulBuilder(
                                          builder: (context, setState) {
                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _selectedIndex =
                                                  _selectedIndex ==
                                                      hospitalIndex
                                                      ? -1
                                                      : hospitalIndex; // Toggle visibility
                                                });
                                              },
                                              child: Container(
                                                child: Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .center,
                                                  children: [
                                                    // Lingkaran dengan nama Rumah Sakit di dalamnya
                                                    Container(
                                                      decoration:
                                                      BoxDecoration(
                                                        color: Color(
                                                            0xFF7B7B7B),
                                                        shape:
                                                        BoxShape.circle,
                                                      ),
                                                      padding:
                                                      EdgeInsets.all(
                                                          15),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                        children: [
                                                          // Menambahkan ikon di atas teks
                                                          Image.asset(
                                                            'assets/images/icon_rs.png', // Ganti dengan nama file ikon Anda
                                                            width:
                                                            28, // Ukuran ikon bisa disesuaikan
                                                            height:
                                                            28, // Ukuran ikon bisa disesuaikan
                                                          ),
                                                          SizedBox(
                                                              height:
                                                              0), // Jarak antara ikon dan teks
                                                          // Menampilkan nama rumah sakit
                                                          Text(
                                                            hospital[
                                                            "name"],
                                                            textAlign:
                                                            TextAlign
                                                                .center,
                                                            style:
                                                            TextStyle(
                                                              color: Colors
                                                                  .white,
                                                              fontSize:
                                                              6, // Ukuran font lebih kecil
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    SizedBox(height: 5),
                                                    // Menampilkan jumlah kantong darah
                                                    Container(
                                                      decoration:
                                                      BoxDecoration(
                                                        border: Border.all(
                                                          color: Color(
                                                              0xFF359B5E), // Warna border
                                                        ),
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                            20),
                                                      ),
                                                      padding: EdgeInsets
                                                          .symmetric(
                                                          vertical: 5,
                                                          horizontal:
                                                          10),
                                                      child: Text(
                                                        "${selectedStock["quantity"]} Kantong",
                                                        style: TextStyle(
                                                          color: Colors
                                                              .black87,
                                                          fontSize:
                                                          10, // Ukuran font jumlah kantong
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                        ),
                                                      ),
                                                    ),
                                                    // Menampilkan tombol jika lingkaran ditekan
                                                    if (_selectedIndex ==
                                                        hospitalIndex) ...[
                                                      Positioned(
                                                        child: Container(
                                                          color: Colors
                                                              .transparent, // Transparan agar tidak mengganggu tampilan
                                                          child: Column(
                                                            children: [
                                                              GestureDetector(
                                                                onTap: () {
                                                                  // Aksi untuk Minta Darah
                                                                  print(
                                                                      "Minta Darah");
                                                                },
                                                                child:
                                                                Column(
                                                                  children: [
                                                                    SizedBox(
                                                                        height:
                                                                        8),
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        // Aksi untuk Minta Darah
                                                                        print("Minta Darah");
                                                                      },
                                                                      child:
                                                                      Container(
                                                                        decoration:
                                                                        BoxDecoration(
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                              color: Colors.red.withOpacity(0.2), // Warna merah dengan transparansi
                                                                              spreadRadius: 5,
                                                                              blurRadius: 12,
                                                                              offset: Offset(0, 0),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        child:
                                                                        Image.asset(
                                                                          'assets/images/minta_darah.png', // Gambar tombol Minta Darah
                                                                          width: 70,
                                                                          height: 20,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                        6),
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        // Aksi untuk Donor Darah
                                                                        print("Donor Darah");
                                                                      },
                                                                      child:
                                                                      Container(
                                                                        decoration:
                                                                        BoxDecoration(
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                              color: Colors.green.withOpacity(0.2), // Warna hijau dengan transparansi
                                                                              spreadRadius: 6,
                                                                              blurRadius: 12,
                                                                              offset: Offset(0, 0),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        child:
                                                                        Image.asset(
                                                                          'assets/images/donor_darah.png', // Gambar tombol Donor Darah
                                                                          width: 70,
                                                                          height: 20,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }).toList(),

                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

