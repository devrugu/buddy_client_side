import 'package:flutter/services.dart';

class CustomPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Eğer kullanıcı +90 önekini silmeye çalışırsa, eski değeri koru
    if (!newValue.text.startsWith('+90')) {
      return oldValue;
    }

    // Kullanıcıdan sadece rakamları al ve baştaki +90 'ı çıkar
    String numericOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Rakamların sayısını 10 ile sınırla
    if (numericOnly.length > 10) {
      numericOnly = numericOnly.substring(0, 10);
    }

    // Yeni metni formatla
    String formattedText = '+90';
    if (numericOnly.isNotEmpty) {
      formattedText +=
          ' (${numericOnly.substring(0, numericOnly.length > 3 ? 3 : numericOnly.length)})';
    }
    if (numericOnly.length > 3) {
      formattedText +=
          ' ${numericOnly.substring(3, numericOnly.length > 6 ? 6 : numericOnly.length)}';
    }
    if (numericOnly.length > 6) {
      formattedText +=
          '-${numericOnly.substring(6, numericOnly.length > 8 ? 8 : numericOnly.length)}';
    }
    if (numericOnly.length > 8) {
      formattedText += '-${numericOnly.substring(8, 10)}';
    }

    // TextEditingValue'i güncelle
    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
