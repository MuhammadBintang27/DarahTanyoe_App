import 'package:darahtanyoe_app/components/AppBarWithLogo.dart';
import 'package:darahtanyoe_app/components/LanjutButton.dart';
import 'package:darahtanyoe_app/components/background_widget.dart';
import 'package:darahtanyoe_app/components/kembali_button.dart';
import 'package:darahtanyoe_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../../components/dropdown_api.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:darahtanyoe_app/pages/notifikasi/Notifikasi.dart';
import 'validasi.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class JadwalLokasi extends StatefulWidget {
  final String nama;
  final String usia;
  final String nomorHP;
  final String golDarah;
  final String jumlahKantong;
  final String deskripsi;

  const JadwalLokasi({
    super.key,
    required this.nama,
    required this.usia,
    required this.nomorHP,
    required this.golDarah,
    required this.jumlahKantong,
    required this.deskripsi,
  });

  @override
  _JadwalLokasiState createState() => _JadwalLokasiState();
}

class _JadwalLokasiState extends State<JadwalLokasi> {
  late String selectedBloodType;
  LatLng? userLocation;
  MapController mapController = MapController();
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> locationSuggestions = [];
  List<Map<String, dynamic>> _bloodStockData = [];
  List<Map<String, dynamic>> _searchResults = [];
  int _selectedIndex = -1;

  final TextEditingController lokasiController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController tanggalDatabaseController = TextEditingController();
  final TextEditingController idLokasiController = TextEditingController();
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'https://default-url.com';

  @override
  void initState() {
    super.initState();
    selectedBloodType = widget.golDarah;
    _determinePosition();
    _fetchBloodStock();
  }

  void _searchHospitals(String query) {
    final results = _bloodStockData.where((hospital) {
      final hospitalName = hospital['name'].toLowerCase();
      final searchQuery = query.toLowerCase();
      return hospitalName.contains(searchQuery);
    }).toList();

    setState(() {
      _searchResults = results;
      _selectedIndex = -1;
    });
  }

  Future<void> _fetchBloodStock() async {
    final url = Uri.parse("$baseUrl/partners/");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _bloodStockData = List<Map<String, dynamic>>.from(data["data"].map((hospital) => {
            "id": hospital["id"],
            "name": hospital["name"],
            "latitude": hospital["latitude"],
            "longitude": hospital["longitude"],
            "blood_stock": List<Map<String, dynamic>>.from(hospital["blood_stock"]),
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
  void dispose() {
    lokasiController.dispose();
    tanggalController.dispose();
    tanggalDatabaseController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithLogo(
        title: 'Data Permintaan Darah',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: BackgroundWidget(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Image.asset(
                    'assets/images/alur_permintaan_3.png',
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Flexible(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                            decoration: BoxDecoration(
                              color: AppTheme.brand_01,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey[400]!),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFE3E3E3),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        bottomLeft: Radius.circular(20),
                                        topRight: Radius.circular(0),
                                        bottomRight: Radius.circular(0),
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
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(0),
                                        bottomLeft: Radius.circular(0),
                                        topRight: Radius.circular(20),
                                        bottomRight: Radius.circular(20),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        widget.golDarah.isNotEmpty ? widget.golDarah : "N/A",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Flexible(
                          flex: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: Color(0xFFE3E3E3),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey[400]!),
                            ),
                            child: Row(
                              children: [
                                Expanded(
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
                                      _searchHospitals(value);
                                    },
                                  ),
                                ),
                                SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    _searchHospitals(searchController.text);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red[200]!,
                                          offset: Offset(0, 0),
                                          blurRadius: 12,
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      'assets/images/search_button.png',
                                      width: 30,
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
                    const SizedBox(height: 26.0),
                    SizedBox(
                      height: 400,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 2,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
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
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      SizedBox(height: 20),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Wrap(
                                            spacing: 15.0,
                                            runSpacing: 15.0,
                                            children: (_searchResults.isEmpty ? _bloodStockData : _searchResults)
                                                .asMap()
                                                .entries
                                                .map<Widget>((entry) {
                                              int index = entry.key;
                                              var hospital = entry.value;

                                              var selectedStock = hospital["blood_stock"].firstWhere(
                                                    (blood) => blood["blood_type"] == selectedBloodType,
                                                orElse: () => {"quantity": 0},
                                              );

                                              bool isSelected = _selectedIndex == index;

                                              return GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedIndex = isSelected ? -1 : index;
                                                    if (!isSelected) {
                                                      idLokasiController.text = hospital['id'].toString();
                                                      lokasiController.text = hospital['name'];
                                                    } else {
                                                      idLokasiController.text = '';
                                                      lokasiController.text = '';
                                                    }
                                                  });
                                                  print("ID Rumah Sakit/PMI: ${hospital['id']}");
                                                  print("Nama Rumah Sakit/PMI: ${hospital['name']}");
                                                },
                                                child: AnimatedScale(
                                                  scale: isSelected ? 1.12 : 1.0,
                                                  duration: Duration(milliseconds: 200),
                                                  curve: Curves.easeInOut,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          color: isSelected
                                                              ? AppTheme.brand_02.withOpacity(0.8)
                                                              : Color(0xFF7B7B7B),
                                                          shape: BoxShape.circle,
                                                        ),
                                                        padding: EdgeInsets.all(20),
                                                        width: 100,
                                                        height: 100,
                                                        child: FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Image.asset(
                                                                'assets/images/icon_rs.png',
                                                                width: 32,
                                                                height: 32,
                                                              ),
                                                              SizedBox(height: 4),
                                                              Container(
                                                                constraints: BoxConstraints(
                                                                  maxWidth: 60,
                                                                  maxHeight: 32,
                                                                ),
                                                                child: Text(
                                                                  hospital["name"],
                                                                  textAlign: TextAlign.center,
                                                                  maxLines: 2,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  style: TextStyle(
                                                                    color: Colors.white,
                                                                    fontSize: 11,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 8),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          border: Border.all(color: Color(0xFF359B5E)),
                                                          borderRadius: BorderRadius.circular(20),
                                                        ),
                                                        padding: EdgeInsets.symmetric(
                                                          vertical: 6,
                                                          horizontal: 12,
                                                        ),
                                                        child: Text(
                                                          "Tersedia ${hospital["quantity"] ?? selectedStock["quantity"]} Kantong",
                                                          style: TextStyle(
                                                            color: Colors.black87,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    _datePickerField(),
                    SizedBox(height: 20),
                    _navigationButtons(context),
                    SizedBox(height: 20),
                    Text(
                      '© 2025 Beyond. Hak Cipta Dilindungi.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700]),
        ),
        SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _datePickerField() {
    // Define the formatter for day names in Indonesian
    final dayFormatter = DateFormat('EEEE', 'id_ID'); // Day name (e.g., "Senin")
    final dateFormatter = DateFormat('d MMMM yyyy', 'id_ID'); // Date (e.g., "12 April 2025")

    // Calculate tomorrow's date as minimum allowed date
    final DateTime tomorrow = DateTime.now().add(Duration(days: 1));

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Jadwal Berakhir Permintaan",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neutral_01,
                ),
              ),
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          GestureDetector(
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: tomorrow, // Set initial date to tomorrow
                firstDate: tomorrow, // Set minimum date to tomorrow
                lastDate: DateTime(2100),
              );

              if (pickedDate != null) {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(hour: 12, minute: 0), // Set default time to noon
                  builder: (BuildContext context, Widget? child) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                      child: child!,
                    );
                  },
                );

                if (pickedTime != null) {
                  setState(() {
                    // Create a DateTime object that combines the date and time
                    final combinedDateTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );

                    // Format for display (Indonesian format)
                    String dayName = dayFormatter.format(combinedDateTime);
                    String datePart = dateFormatter.format(combinedDateTime);
                    String timePart = "${pickedTime.hour}.${pickedTime.minute.toString().padLeft(2, '0')}";

                    // Store the display format in the text controller for the UI
                    tanggalController.text = "$dayName, $datePart, $timePart";

                    // Store the database format in a separate variable
                    String databaseFormat = "${pickedDate.day}-${pickedDate.month}-${pickedDate.year} ${pickedTime.hour}:${pickedTime.minute.toString().padLeft(2, '0')}";

                    // You can store this in a separate controller or variable to use when sending to database
                    tanggalDatabaseController.text = databaseFormat;
                    // Or if you prefer to use a variable instead of a controller:
                    // tanggalDatabaseValue = databaseFormat;
                  });
                }
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white60,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.neutral_01.withOpacity(0.53),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tanggalController.text.isEmpty
                        ? "Jadwal Berakhir Permintaan"
                        : tanggalController.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: tanggalController.text.isEmpty
                          ? AppTheme.neutral_01.withOpacity(0.4)
                          : AppTheme.neutral_01,
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: AppTheme.neutral_01.withOpacity(0.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navigationButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width / 2.5,
          child: KembaliButton(onPressed: () => Navigator.pop(context)),
        ),
        SizedBox(width: 16),
        SizedBox(
          width: MediaQuery.of(context).size.width / 2.5,
          child: LanjutButton(
            onPressed: () {
              // Validation check
              if (lokasiController.text.isEmpty || tanggalDatabaseController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Harap isi Lokasi dan Jadwal Berakhir sebelum melanjutkan!",
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Validasi(
                      nama: widget.nama,
                      usia: widget.usia,
                      nomorHP: widget.nomorHP,
                      golDarah: widget.golDarah,
                      lokasi: lokasiController.text,
                      tanggal: tanggalController.text,
                      tanggalDatabase: tanggalDatabaseController.text,
                      jumlahKantong: widget.jumlahKantong,
                      idLokasi: idLokasiController.text,
                      deskripsi: widget.deskripsi,
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}