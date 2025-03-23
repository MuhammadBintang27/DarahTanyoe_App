import 'package:darahtanyoe_app/widget/header_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import '../../components/my_navbar.dart';

class BloodMap extends StatefulWidget {
  const BloodMap({super.key});

  @override
  State<BloodMap> createState() => _BloodMapState();
}

class _BloodMapState extends State<BloodMap> {
  String selectedDistance = "<2KM";
  String selectedBloodType = "A+";
  LatLng? userLocation;
  MapController mapController = MapController();
  TextEditingController searchController = TextEditingController();

  final List<String> distanceOptions = ["<2KM", "<5KM", "<10KM"];
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
  String? _selectedBloodType;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _fetchBloodStock();
  }

  Future<void> _fetchBloodStock() async {
    final url = Uri.parse("https://darahtanyoe-api.vercel.app/partners/");

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
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                image: DecorationImage(
                  image: AssetImage('assets/images/batik_pattern.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HeaderWidget(),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, top: 16.0, bottom: 8.0),
                    child: Text(
                      "Peta Darah",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Divider(color: Colors.black26, thickness: 1),
                  ),
                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: Color(0xFFA9A9A9).withOpacity(0.21),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey[400]!),
                            ),
                            child: Row(
                              children: [
                                Text("Jarak RS/PMI",
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(width: 8),
                                Container(
                                  height: 20,
                                  width: 1,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: selectedDistance,
                                      items:
                                          distanceOptions.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedDistance = newValue!;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: Color(0xFFA9A9A9).withOpacity(0.21),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey[400]!),
                            ),
                            child: Row(
                              children: [
                                Text("Golongan Darah",
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(width: 8),
                                Container(
                                    height: 20,
                                    width: 1,
                                    color: Colors.grey[400]),
                                SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: selectedBloodType.isNotEmpty
                                          ? selectedBloodType
                                          : null,
                                      hint: Text("Pilih Golongan Darah"),
                                      items:
                                          bloodTypeOptions.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedBloodType = newValue ??
                                              ""; // Pastikan tidak null
                                        });
                                      },
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
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            FlutterMap(
                              mapController: mapController,
                              options: MapOptions(
                                initialCenter:
                                    userLocation ?? LatLng(-6.2088, 106.8456),
                                initialZoom: 13.0,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                  subdomains: ['a', 'b', 'c'],
                                ),
                              ],
                            ),
                            Positioned(
                              top: 10,
                              left: 10,
                              right: 10,
                              child: Column(
                                children: [
                                  SizedBox(height: 10),
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 5,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Ketersediaan Darah",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        // Tabel ketersediaan darah
                                        Table(
                                          border: TableBorder.all(
                                              color: Colors.black26),
                                          columnWidths: {
                                            0: FlexColumnWidth(2),
                                            1: FlexColumnWidth(1)
                                          },
                                          children: [
                                            // Header tabel
                                            TableRow(
                                              decoration: BoxDecoration(
                                                  color: Colors.grey[200]),
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    "Nama Rumah Sakit",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    "Jumlah",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // Isi tabel (filter berdasarkan selectedBloodType)
                                            ..._bloodStockData
                                                .map<TableRow>((hospital) {
                                              var selectedStock = hospital[
                                                      "blood_stock"]
                                                  .firstWhere(
                                                      (blood) =>
                                                          blood["blood_type"] ==
                                                          selectedBloodType, // Gunakan selectedBloodType
                                                      orElse: () => {
                                                            "quantity": 0
                                                          }); // Default 0 jika tidak ditemukan

                                              return TableRow(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child:
                                                        Text(hospital["name"]),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Text(
                                                      "${selectedStock["quantity"]}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
          ],
        ),
      ),
    );
  }
}
