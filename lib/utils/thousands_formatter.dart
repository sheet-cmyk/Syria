import 'package:flutter/services.dart';

/// يضيف فارزة تلقائية كل 3 أرقام: 1000000 → 1,000,000
class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(',', '');
    if (digits.isEmpty) return newValue.copyWith(text: '');

    final formatted = _format(digits);

    // حساب موضع المؤشر بعد إعادة التنسيق
    int rawCursor = newValue.selection.end;
    int digitsBeforeCursor = 0;
    for (int i = 0; i < rawCursor && i < newValue.text.length; i++) {
      if (newValue.text[i] != ',') digitsBeforeCursor++;
    }
    int pos = 0, count = 0;
    while (pos < formatted.length && count < digitsBeforeCursor) {
      if (formatted[pos] != ',') count++;
      pos++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: pos),
    );
  }

  static String _format(String digits) {
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    return buf.toString();
  }

  /// يحوّل نص به فوارز إلى رقم نظيف للحفظ في Firestore
  static String clean(String text) => text.replaceAll(',', '');

  /// يُنسّق رقم نصي موجود (مثلاً عند تحميل بيانات التعديل)
  static String formatExisting(String raw) {
    final digits = raw.replaceAll(',', '');
    if (digits.isEmpty || int.tryParse(digits) == null) return raw;
    return _format(digits);
  }
}
