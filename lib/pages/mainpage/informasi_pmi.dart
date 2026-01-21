import 'package:darahtanyoe_app/components/background_widget.dart';
import 'package:darahtanyoe_app/theme/theme.dart';
import 'package:darahtanyoe_app/widget/header_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InformasiPMI extends StatefulWidget {
  const InformasiPMI({super.key});

  @override
  State<InformasiPMI> createState() => _InformasiPMIState();
}

class _InformasiPMIState extends State<InformasiPMI> {
  List<Map<String, dynamic>> _pmiList = [];
  String? _selectedPMIId;
  bool _isLoading = false;

  final List<String> bloodTypes = [
    "A+",
    "A-",
    "B+",
    "B-",
    "AB+",
    "AB-",
    "O+",
    "O-"
  ];

  @override
  void initState() {
    super.initState();
    _fetchPMIList();
  }

  Future<void> _fetchPMIList() async {
    final String baseUrl = dotenv.env['BASE_URL'] ?? 'https://default-url.com';
    final url = Uri.parse("$baseUrl/partners/");

    try {
      setState(() => _isLoading = true);
      final response = await http.get(url);

      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> allInstitutions = data["data"];

        debugPrint("Total institutions: ${allInstitutions.length}");

        // Filter hanya PMI
        final pmiInstitutions = allInstitutions
            .where((inst) => inst["institution_type"] == "pmi")
            .toList();

        debugPrint("PMI institutions: ${pmiInstitutions.length}");

        setState(() {
          _pmiList =
              List<Map<String, dynamic>>.from(pmiInstitutions.map((pmi) => {
                    "id": pmi["id"]?.toString() ?? "",
                    "name": pmi["name"]?.toString() ?? "Nama PMI",
                    "address": pmi["address"]?.toString() ?? "Alamat tidak tersedia",
                    "phone_number": pmi["phone_number"]?.toString(),
                    "email": pmi["email"]?.toString(),
                    "blood_stock":
                        List<Map<String, dynamic>>.from(pmi["blood_stock"] ?? []),
                  }));

          if (_pmiList.isNotEmpty && _pmiList[0]["id"] != null && _pmiList[0]["id"] != "") {
            _selectedPMIId = _pmiList[0]["id"];
          }
        });
      }
    } catch (e, stackTrace) {
      debugPrint("Error fetching PMI list: $e");
      debugPrint("Stack trace: $stackTrace");
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memuat data PMI: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic>? get _selectedPMI {
    if (_selectedPMIId == null) return null;
    try {
      return _pmiList.firstWhere((pmi) => pmi["id"] == _selectedPMIId);
    } catch (e) {
      return null;
    }
  }

  int _getStockQuantity(String bloodType) {
    if (_selectedPMI == null) return 0;

    try {
      final stock = (_selectedPMI!["blood_stock"] as List).firstWhere(
        (s) => s["blood_type"] == bloodType,
        orElse: () => {"quantity": 0},
      );
      return stock["quantity"] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Color _getStockColor(int quantity) {
    if (quantity == 0) return Color(0xFFEF5350); // Red
    if (quantity < 10) return Color(0xFFFFA726); // Yellow
    if (quantity < 20) return Color(0xFF42A5F5); // Blue
    return Color(0xFF66BB6A); // Green
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BackgroundWidget(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeaderWidget(),

              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Informasi PMI",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neutral_01,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 4.0, bottom: 16.0, left: 16.0, right: 16.0),
                child: Divider(color: Colors.black26, thickness: 0.8),
              ),

              // Loading State
              if (_isLoading)
                Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.brand_01,
                    ),
                  ),
                )
              else if (_pmiList.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline,
                            size: 80, color: Colors.grey[400]),
                        SizedBox(height: 16),
                        Text(
                          "Tidak ada data PMI",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Dropdown Pilih PMI
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _selectedPMIId,
                                hint: Text(
                                  "Pilih Lokasi PMI",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                icon: Icon(Icons.arrow_drop_down,
                                    color: AppTheme.brand_01),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                items: _pmiList.map((pmi) {
                                  return DropdownMenuItem<String>(
                                    value: pmi["id"],
                                    child: Text(pmi["name"]),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedPMIId = newValue;
                                  });
                                },
                              ),
                            ),
                          ),

                          SizedBox(height: 20),

                          // Info PMI
                          if (_selectedPMI != null) ...[
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Alamat
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.location_on,
                                          color: AppTheme.brand_01, size: 18),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Alamat",
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              _selectedPMI!["address"],
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  if (_selectedPMI!["phone_number"] != null) ...[
                                    SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Icon(Icons.phone,
                                            color: AppTheme.brand_01, size: 18),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Telepon",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(height: 2),
                                              Text(
                                                _selectedPMI!["phone_number"],
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],

                                  if (_selectedPMI!["email"] != null) ...[
                                    SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Icon(Icons.email,
                                            color: AppTheme.brand_01, size: 18),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Email",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(height: 2),
                                              Text(
                                                _selectedPMI!["email"],
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            SizedBox(height: 20),

                            // Stok Darah
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.water_drop,
                                          color: AppTheme.brand_01, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        "Stok Darah Tersedia",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),

                                  // Grid Stok Darah
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 0.85,
                                    ),
                                    itemCount: bloodTypes.length,
                                    itemBuilder: (context, index) {
                                      String bloodType = bloodTypes[index];
                                      int quantity =
                                          _getStockQuantity(bloodType);
                                      Color statusColor =
                                          _getStockColor(quantity);

                                      return Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 6),
                                        decoration: BoxDecoration(
                                          color: statusColor
                                              .withValues(alpha: 0.1),
                                          border: Border.all(
                                            color: statusColor
                                                .withValues(alpha: 0.3),
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              bloodType,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: statusColor,
                                              ),
                                            ),
                                            SizedBox(height: 6),
                                            Text(
                                              "$quantity",
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: statusColor,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              "Kantong",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),

                                  SizedBox(height: 16),

                                  // Legend
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 8,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      _buildLegend(
                                          Color(0xFFEF5350), "Kosong"),
                                      _buildLegend(
                                          Color(0xFFFFA726), "Rendah"),
                                      _buildLegend(
                                          Color(0xFF42A5F5), "Sedang"),
                                      _buildLegend(
                                          Color(0xFF66BB6A), "Cukup"),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 20),
                          ],
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

  Widget _buildLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
