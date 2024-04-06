import 'package:flutter/material.dart';

class WarningMessages {
  static void show(BuildContext context, String message,
      {bool isSuccess = true}) {
    final color = isSuccess ? Colors.green : Colors.red;

    final overlay = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50.0,
        left: MediaQuery.of(context).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          ),
        ),
      ),
    );

    // Overlay'e widget'ı ekleyin ve belirli bir süre sonra kaldırın
    Overlay.of(context)?.insert(overlay);
    Future.delayed(const Duration(seconds: 2), () {
      overlay.remove();
    });
  }

  static void success(BuildContext context, String message) {
    show(context, message, isSuccess: true);
  }

  static void error(BuildContext context, String message) {
    show(context, message, isSuccess: false);
  }
}
