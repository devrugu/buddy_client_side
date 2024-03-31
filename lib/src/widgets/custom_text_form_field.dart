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
  final String staticPrefix;

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
    this.staticPrefix = '',
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
    _labelColor = Colors.grey;

    _focusNode.addListener(() {
      setState(
          () => _labelColor = _focusNode.hasFocus ? Colors.blue : Colors.grey);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.staticPrefix.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child:
                Text(widget.staticPrefix, style: const TextStyle(fontSize: 16)),
          ),
        Expanded(
          child: TextFormField(
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
            inputFormatters: widget.phoneMaskFormatter != null
                ? [widget.phoneMaskFormatter!]
                : [], // Apply the formatter if provided
          ),
        ),
      ],
    );
  }
}
