import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal

enum InputType { text, dropdown, date }

class MyTextField extends StatefulWidget {
  final String hintText;
  final String? initialValue;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final InputType inputType;
  final List<String>? dropdownItems;
  final Function(String)? onChanged;

  const MyTextField({
    Key? key,
    required this.hintText,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.inputType = InputType.text,
    this.dropdownItems,
    this.onChanged,
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
    _selectedDropdownValue = widget.initialValue ?? (widget.dropdownItems?.isNotEmpty == true ? widget.dropdownItems!.first : null);
    _selectedDate = widget.initialValue;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        _selectedDate = formattedDate;
        _controller.text = formattedDate;
      });
      if (widget.onChanged != null) {
        widget.onChanged!(formattedDate);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Lebar penuh agar seragam
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: widget.inputType == InputType.text
          ? TextFormField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: const TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
              keyboardType: widget.keyboardType,
              onChanged: widget.onChanged,
            )
          : widget.inputType == InputType.dropdown
              ? SizedBox(
                  width: double.infinity,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true, // Membuat dropdown sesuai lebar parent
                      value: _selectedDropdownValue,
                      dropdownColor: Colors.black,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      style: const TextStyle(color: Colors.white),
                      items: widget.dropdownItems?.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDropdownValue = value!;
                        });
                        if (widget.onChanged != null) {
                          widget.onChanged!(value!);
                        }
                      },
                    ),
                  ),
                )
              : GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: const TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        suffixIcon: const Icon(Icons.calendar_today, color: Colors.white),
                      ),
                    ),
                  ),
                ),
    );
  }
}