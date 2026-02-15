import 'package:darahtanyoe_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


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
  final bool isAuth;
  final bool readOnly;

  const MyTextField({
    super.key,
    required this.hintText,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.inputType = InputType.text,
    this.dropdownItems,
    this.onChanged,
    this.validator,
    this.isAuth = true,
    this.readOnly = false,
  });

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
    _controller = widget.controller ??
        TextEditingController(text: widget.initialValue ?? '');
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
    final Color textColor = widget.isAuth ? Colors.white : AppTheme.neutral_01;
    final Color borderColor =
    widget.isAuth ? Colors.white : AppTheme.neutral_01.withOpacity(0.53);

    return Container(
      width: double.infinity,
      clipBehavior: Clip.none,
      decoration: BoxDecoration(
        color: widget.isAuth ? textColor.withOpacity(0.11) : Colors.white60,
        boxShadow: widget.isAuth == false
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 4,
            offset: const Offset(0, 4),
          )
        ] : [],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: widget.inputType == InputType.text
          ? TextFormField(
        controller: _controller,
        readOnly: widget.readOnly,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: textColor.withOpacity(0.4)),
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
            style: TextStyle(color: textColor.withOpacity(0.4)),
          ),
          icon: Icon(Icons.arrow_drop_down, color: textColor),
          style: TextStyle(color: textColor),
          dropdownColor: Colors.black87.withOpacity(0.9),
          items: widget.dropdownItems?.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: TextStyle(color: textColor)),
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
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle:
              TextStyle(color: textColor.withOpacity(0.7)),
              border: InputBorder.none,
              suffixIcon: Icon(Icons.calendar_today, color: textColor),
            ),
            validator: widget.validator,
          ),
        ),
      ),
    );
  }
}
