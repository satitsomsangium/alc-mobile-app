import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class PriceInputFormatter extends TextInputFormatter {
  final NumberFormat _numberFormat;

  PriceInputFormatter(this._numberFormat);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // ลบทุกอย่างยกเว้นตัวเลขและจุดทศนิยม
    final onlyNumbersAndDot = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');

    // แยกส่วนจำนวนเต็มและทศนิยม
    final parts = onlyNumbersAndDot.split('.');
    var integerPart = parts[0];
    var fractionalPart = parts.length > 1 ? '.${parts[1]}' : '';

    // จัดรูปแบบส่วนจำนวนเต็ม
    var formattedInteger = _numberFormat.format(int.parse(integerPart));

    // รวมส่วนจำนวนเต็มและทศนิยม
    final formattedPrice = '$formattedInteger$fractionalPart';

    return TextEditingValue(
      text: formattedPrice,
      selection: TextSelection.collapsed(offset: formattedPrice.length),
    );
  }
}