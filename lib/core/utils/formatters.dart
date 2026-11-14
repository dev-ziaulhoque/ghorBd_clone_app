class AppFormatters {
  static const Map<String, String> _englishToBanglaDigits = {
    '0': '০',
    '1': '১',
    '2': '২',
    '3': '৩',
    '4': '৪',
    '5': '৫',
    '6': '৬',
    '7': '৭',
    '8': '৮',
    '9': '৯',
  };

  static const Map<String, String> _banglaToEnglishDigits = {
    '০': '0',
    '১': '1',
    '২': '2',
    '৩': '3',
    '৪': '4',
    '৫': '5',
    '৬': '6',
    '৭': '7',
    '৮': '8',
    '৯': '9',
  };

  /// Converts English digits (0-9) in any string to Bangla digits (০-৯)
  static String toBanglaDigits(dynamic input) {
    if (input == null) return '';
    final str = input.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final char = str[i];
      buffer.write(_englishToBanglaDigits[char] ?? char);
    }
    return buffer.toString();
  }

  /// Converts Bangla digits (০-৯) in any string to English digits (0-9)
  static String fromBanglaDigits(String input) {
    final buffer = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final char = input[i];
      buffer.write(_banglaToEnglishDigits[char] ?? char);
    }
    return buffer.toString();
  }

  /// Formats an amount using South Asian numbering system (lakh, crore grouping: 2,2,3)
  /// e.g. 7200000 -> "৭২,০০,০০০ ৳" (Bangla) or "72,00,000 ৳" (English)
  static String formatBdt(
    num amount, {
    bool isBangla = true,
    bool includeSymbol = true,
  }) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();

    final int integerPart = absAmount.toInt();
    final double fractionalPart = (absAmount - integerPart).toDouble();

    final grouped = _groupSouthAsian(integerPart.toString());

    String result;
    if (fractionalPart > 0) {
      final fractionString =
          (fractionalPart * 100).round().toString().padLeft(2, '0');
      result = '$grouped.$fractionString';
    } else {
      result = grouped;
    }

    if (isBangla) {
      result = toBanglaDigits(result);
    }

    if (isNegative) {
      result = '-$result';
    }

    if (includeSymbol) {
      result = '$result ৳';
    }

    return result;
  }

  /// South Asian digit grouping helper:
  /// Grouping: first 3 digits from right, then groups of 2.
  /// 7200000 -> "72,00,000"
  static String _groupSouthAsian(String digits) {
    if (digits.length <= 3) return digits;

    final lastThree = digits.substring(digits.length - 3);
    final remaining = digits.substring(0, digits.length - 3);

    final parts = <String>[];
    var current = remaining;
    while (current.length > 2) {
      parts.insert(0, current.substring(current.length - 2));
      current = current.substring(0, current.length - 2);
    }
    if (current.isNotEmpty) {
      parts.insert(0, current);
    }

    return '${parts.join(',')},$lastThree';
  }
}
