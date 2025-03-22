import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

enum InputType { text, dropdown, date }

class MyTextField extends StatefulWidget {
  final String hintText;
  final String? initialValue;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final InputType inputType;
  final List<String>? dropdownItems;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  const MyTextField({
    Key? key,
    required this.hintText,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.inputType = InputType.text,
    this.dropdownItems,
    this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late TextEditingController _controller;
  String? _selectedDropdownValue;
  String? _selectedDate;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue ?? '');
    _selectedDropdownValue = widget.initialValue;
    _selectedDate = widget.initialValue;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pickDate() async {
    DateTime initialDate = _selectedDate != null
        ? DateFormat('yyyy-MM-dd').parse(_selectedDate!)
        : DateTime.now();

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        _selectedDate = formattedDate;
        _controller.text = formattedDate;
      });
      widget.onChanged?.call(formattedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: widget.inputType == InputType.text
          ? TextFormField(
              controller: _controller,
              style: GoogleFonts.dmSans(color: Colors.white),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: GoogleFonts.dmSans(color: Colors.white70),
                border: InputBorder.none,
              ),
              keyboardType: widget.keyboardType,
              onChanged: widget.onChanged,
              validator: widget.validator,
            )
          : widget.inputType == InputType.dropdown
              ? DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedDropdownValue,
                    hint: Text(
                      widget.hintText,
                      style: GoogleFonts.dmSans(color: Colors.white70),
                    ),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    style: GoogleFonts.dmSans(color: Colors.white), // Pastikan teks tetap putih
                    dropdownColor: Colors.black87.withOpacity(0.9), // Warna dropdown lebih lembut
                    items: widget.dropdownItems?.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: GoogleFonts.dmSans(color: Colors.white), // Teks tetap putih setelah dipilih
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDropdownValue = value;
                      });
                      widget.onChanged?.call(value!);
                    },
                  ),
                )
              : GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _controller,
                      style: GoogleFonts.dmSans(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: GoogleFonts.dmSans(color: Colors.white70),
                        border: InputBorder.none,
                        suffixIcon: const Icon(Icons.calendar_today, color: Colors.white),
                      ),
                      validator: widget.validator,
                    ),
                  ),
                ),
    );
  }
}
