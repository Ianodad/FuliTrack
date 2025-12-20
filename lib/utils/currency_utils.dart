import 'package:intl/intl.dart';

/// Utility functions for currency formatting
class CurrencyUtils {
  static final _kshFormat = NumberFormat.currency(
    symbol: 'Ksh ',
    decimalDigits: 2,
    locale: 'en_KE',
  );

  static final _compactFormat = NumberFormat.compactCurrency(
    symbol: 'Ksh ',
    decimalDigits: 0,
    locale: 'en_KE',
  );

  /// Format amount as Kenyan Shillings (e.g., "Ksh 1,234.56")
  static String formatKsh(double amount) {
    return _kshFormat.format(amount);
  }

  /// Format amount in compact form (e.g., "Ksh 1.2K")
  static String formatKshCompact(double amount) {
    if (amount < 1000) {
      return formatKsh(amount);
    }
    return _compactFormat.format(amount);
  }

  /// Format as percentage
  static String formatPercentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  /// Format as signed percentage (with + for positive)
  static String formatSignedPercentage(double value) {
    final sign = value >= 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(1)}%';
  }

  /// Parse Ksh string to double (handles "Ksh 1,234.56" format)
  static double? parseKsh(String value) {
    final cleaned = value
        .replaceAll('Ksh', '')
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .trim();
    return double.tryParse(cleaned);
  }
}
