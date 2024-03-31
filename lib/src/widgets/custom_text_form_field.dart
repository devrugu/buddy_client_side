import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CustomTextFormField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextEditingController? controller;
  final MaskTextInputFormatter? phoneMaskFormatter;

  const CustomTextFormField({
    super.key,
    required this.labelText,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.onTap,
    this.readOnly = false,
    this.controller,
    this.phoneMaskFormatter,
  });

  @override
  CustomTextFormFieldState createState() => CustomTextFormFieldState();
}

class CustomTextFormFieldState extends State<CustomTextFormField> {
  late FocusNode _focusNode;
  late Color _labelColor;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _labelColor = Colors.grey; // Başlangıçta etiket rengi

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() => _labelColor = Colors.blue); // Odaklanıldığında mavi
      } else {
        setState(() => _labelColor = Colors.grey); // Odaklanılmadığında gri
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Colors.blue,
      controller: widget.controller,
      focusNode: _focusNode,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(color: _labelColor),
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      onTap: widget.onTap,
      readOnly: widget.readOnly,
    );
  }
}
