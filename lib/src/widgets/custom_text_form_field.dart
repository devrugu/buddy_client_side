import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CustomTextFormField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      inputFormatters: phoneMaskFormatter != null ? [phoneMaskFormatter!] : [],
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      onTap: onTap,
      readOnly: readOnly,
    );
  }
}
