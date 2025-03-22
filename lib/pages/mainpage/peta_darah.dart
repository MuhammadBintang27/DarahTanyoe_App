import 'package:darahtanyoe_app/widget/header_widget.dart';
import 'package:flutter/material.dart';
import '../../components/my_navbar.dart';

class BloodMap extends StatefulWidget {
  const BloodMap({super.key});

  @override
  State<BloodMap> createState() => _BloodMapState();
}

class _BloodMapState extends State<BloodMap> {
  String selectedDistance = "<2KM";
  String selectedBloodType = "A+";

  final List<String> distanceOptions = ["<2KM", "<5KM", "<10KM"];
  final List<String> bloodTypeOptions = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
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
                padding: const EdgeInsets.only(left: 20.0, top: 16.0, bottom: 8.0),
                child: Text(
                  "Peta Darah",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  height: 1,
                  color: Colors.grey[400],
                ),
              ),

              const SizedBox(height: 28.0),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
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
                                  items: distanceOptions.map((String value) {
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
                        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
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
                              color: Colors.grey[400],
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: selectedBloodType,
                                  items: bloodTypeOptions.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedBloodType = newValue!;
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

              const SizedBox(height: 22.0),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Color(0xFFA9A9A9).withOpacity(0.21),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Cari RS / PMI",
                            hintStyle: TextStyle(color: Colors.black45),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                      SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Color(0xFFBE3A3A),
                        radius: 18,
                        child: Icon(Icons.search, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),
              ),

              // Container putih kosong berbentuk persegi panjang
              const SizedBox(height: 26.0),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                height: 390,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[400]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
  );
  }
}
