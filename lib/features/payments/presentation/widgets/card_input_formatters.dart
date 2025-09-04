import 'package:flutter/services.dart';

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }

    return TextEditingValue(text: buffer.toString(), selection: TextSelection.collapsed(offset: buffer.length));
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length && i < 4; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(text[i]);
    }

    return TextEditingValue(text: buffer.toString(), selection: TextSelection.collapsed(offset: buffer.length));
  }
}

class CVVInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Limit CVV to 4 digits
    if (newValue.text.length <= 4) {
      return newValue;
    }

    return TextEditingValue(text: newValue.text.substring(0, 4), selection: TextSelection.collapsed(offset: 4));
  }
}
