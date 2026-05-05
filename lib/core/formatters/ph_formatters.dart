class PhFormatters {
  /// Philippine-specific formatters for currency, phone numbers, and dates
  /// Formats a double amount as Philippine Peso currency
  /// Example: 1500.50 → ₱1,500.50
  static String peso(double amount) {
    final formatted = amount.toStringAsFixed(2);
    final parts = formatted.split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];

    // Add comma separators for thousands
    final withCommas = _addThousandsSeparator(integerPart);

    return '₱$withCommas.$decimalPart';
  }

  /// Formats amount as Philippine Peso without decimals
  /// Example: 1500 → ₱1,500
  static String pesoWhole(int amount) {
    final withCommas = _addThousandsSeparator(amount.toString());
    return '₱$withCommas';
  }

  /// Formats Philippine phone number
  /// Example: 639123456789 → +63 (912) 345-6789
  static String phone(String number) {
    // Remove all non-digits
    final digits = number.replaceAll(RegExp(r'\D'), '');

    // Handle +63 country code
    String cleaned = digits;
    if (digits.startsWith('63')) {
      cleaned = digits.substring(2);
    } else if (digits.startsWith('0')) {
      cleaned = digits.substring(1);
    }

    // Format: (XXX) XXX-XXXX
    if (cleaned.length >= 10) {
      final areaCode = cleaned.substring(0, 3);
      final middleSection = cleaned.substring(3, 6);
      final lastSection = cleaned.substring(6, 10);
      return '+63 ($areaCode) $middleSection-$lastSection';
    }

    return digits;
  }

  /// Parses Philippine peso string to double
  /// Example: "₱1,500.50" → 1500.50
  static double parsePeso(String pesoString) {
    final cleaned = pesoString.replaceAll('₱', '').replaceAll(',', '').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  /// Formats distance in kilometers
  /// Example: 1234 → 1.2 km
  static String distance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    }
    final km = meters / 1000;
    return '${km.toStringAsFixed(1)} km';
  }

  /// Formats rating with stars
  /// Example: 4.5 → 4.5 ⭐ (5)
  static String rating(double rating, int totalReviews) {
    return '$rating ⭐ ($totalReviews)';
  }

  /// Helper: Add commas for thousands separator
  static String _addThousandsSeparator(String number) {
    final regex = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
    return number.replaceAllMapped(regex, (match) => '${match[1]},');
  }
}
