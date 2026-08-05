import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    String cleanString = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanString.isEmpty) {
      return newValue.copyWith(text: '');
    }

    double value = double.parse(cleanString);

    final formatter = NumberFormat('#,###', 'en_US');

    String newText = formatter.format(value);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
