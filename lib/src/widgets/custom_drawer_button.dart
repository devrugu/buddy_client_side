import 'package:flutter/material.dart';

class CustomDrawerButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final TextStyle textStyle;

  const CustomDrawerButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,  // Butonun genişliğinin tamamını kaplaması için
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context)
              .primaryColor,  // Temanın birincil rengini kullan
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius
                .zero,  // Çekmece butonlarının tipik olarak yuvarlak köşesi olmaz
          ),
          padding: const EdgeInsets.symmetric(vertical: 20.0),  // Rahat tıklama için yeterli dolgu
          textStyle: textStyle,  // Text stilini parametre olarak al
        ),
        onPressed: onPressed,  // Tıklanınca çalışacak fonksiyon
        child: Text(text, style: textStyle),  // Buton metni ve stili
      ),
    );
  }
}
