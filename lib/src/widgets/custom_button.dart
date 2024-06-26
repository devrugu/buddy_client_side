import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final TextStyle textStyle;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color ??
            Theme.of(context)
                .primaryColor, // Use the primary color from the theme
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              30.0), // Matched to the borderRadius of the logo
        ),
        minimumSize:
            const Size(double.infinity, 50), // Consistent button height
        padding:
            const EdgeInsets.symmetric(vertical: 16.0), // Comfortable padding
        textStyle: textStyle,
      ),
      onPressed: onPressed,
      child: Text(text, style: textStyle),
    );
  }
}
