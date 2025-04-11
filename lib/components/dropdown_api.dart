import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Model untuk Lokasi
class Lokasi {
  final String id;
  final String name;

  Lokasi({required this.id, required this.name});

  factory Lokasi.fromJson(Map<String, dynamic> json) {
    return Lokasi(
      id: json['id'].toString(),
      name: json['name'].toString(),
    );
  }
}

class DropdownApi extends StatefulWidget {
  final String apiUrl;
  final String hintText;
  final Function(Lokasi?) onChanged;

  const DropdownApi({
    super.key,
    required this.apiUrl,
    required this.hintText,
    required this.onChanged,
  });

  @override
  _DropdownApiState createState() => _DropdownApiState();
}

class _DropdownApiState extends State<DropdownApi> {
  Lokasi? selectedItem;
  List<Lokasi> options = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchOptions();
  }

  Future<void> fetchOptions() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(widget.apiUrl),
        headers: {
          "ngrok-skip-browser-warning": "true",
          "Accept": "application/json"
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        List<dynamic> partners = responseData['data'];

        setState(() {
          options = partners.map((item) => Lokasi.fromJson(item)).toList();
        });
      } else {
        throw Exception('Gagal mengambil data, status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton<Lokasi>(
          value: selectedItem,
          isExpanded: true,
          hint: Text(widget.hintText),
          underline: SizedBox(),
          onChanged: isLoading
              ? null
              : (Lokasi? newValue) {
            setState(() {
              selectedItem = newValue;
            });
            widget.onChanged(newValue);
            print('Selected: ${newValue?.id} - ${newValue?.name}');
          },
          items: options.map((Lokasi option) {
            return DropdownMenuItem<Lokasi>(
              value: option,
              child: Text(option.name), // Menampilkan nama di dropdown
            );
          }).toList(),
        ),
        if (isLoading)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
