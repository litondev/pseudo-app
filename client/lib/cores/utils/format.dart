import 'package:intl/intl.dart';

class Format {
  // Format currency (100000 -> 100.000,00)
  static String formatCurrency(double amount, {String symbol = 'Rp ', int decimalDigits = 2}) {
    final NumberFormat formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return formatter.format(amount);
  }

  // Format currency without symbol (100000 -> 100.000,00)
  static String formatCurrencyWithoutSymbol(double amount, {int decimalDigits = 2}) {
    final NumberFormat formatter = NumberFormat('#,##0.${'0' * decimalDigits}', 'id_ID');
    return formatter.format(amount).replaceAll(',', '.');
  }

  // Format number with thousand separator (100000 -> 100.000)
  static String formatNumber(num number) {
    final NumberFormat formatter = NumberFormat('#,##0', 'id_ID');
    return formatter.format(number).replaceAll(',', '.');
  }

  // Format date (d M YYYY)
  static String formatDate(DateTime date, {String pattern = 'd MMM yyyy'}) {
    final DateFormat formatter = DateFormat(pattern, 'id_ID');
    return formatter.format(date);
  }

  // Format date with time (d M YYYY HH:mm)
  static String formatDateTime(DateTime dateTime, {String pattern = 'd MMM yyyy HH:mm'}) {
    final DateFormat formatter = DateFormat(pattern, 'id_ID');
    return formatter.format(dateTime);
  }

  // Format time only (HH:mm)
  static String formatTime(DateTime time, {String pattern = 'HH:mm'}) {
    final DateFormat formatter = DateFormat(pattern);
    return formatter.format(time);
  }

  // Format date for API (yyyy-MM-dd)
  static String formatDateForApi(DateTime date) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date);
  }

  // Format datetime for API (yyyy-MM-dd HH:mm:ss)
  static String formatDateTimeForApi(DateTime dateTime) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(dateTime);
  }

  // Format relative time (2 hours ago, yesterday, etc.)
  static String formatRelativeTime(DateTime dateTime) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final int years = (difference.inDays / 365).floor();
      return '$years tahun yang lalu';
    } else if (difference.inDays > 30) {
      final int months = (difference.inDays / 30).floor();
      return '$months bulan yang lalu';
    } else if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'kemarin';
      }
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'baru saja';
    }
  }

  // Format percentage (0.15 -> 15%)
  static String formatPercentage(double value, {int decimalDigits = 1}) {
    final NumberFormat formatter = NumberFormat.percentPattern('id_ID');
    formatter.maximumFractionDigits = decimalDigits;
    return formatter.format(value);
  }

  // Format file size (1024 -> 1 KB)
  static String formatFileSize(int bytes) {
    const List<String> units = ['B', 'KB', 'MB', 'GB', 'TB'];
    double size = bytes.toDouble();
    int unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(size < 10 ? 1 : 0)} ${units[unitIndex]}';
  }

  // Format phone number (08123456789 -> 0812-3456-789)
  static String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    final String digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    if (digits.length < 10) return phoneNumber;
    
    // Format Indonesian phone number
    if (digits.startsWith('62')) {
      // International format
      return '+62 ${digits.substring(2, 5)}-${digits.substring(5, 9)}-${digits.substring(9)}';
    } else if (digits.startsWith('0')) {
      // Local format
      return '${digits.substring(0, 4)}-${digits.substring(4, 8)}-${digits.substring(8)}';
    }
    
    return phoneNumber;
  }

  // Format duration (90 seconds -> 1m 30s)
  static String formatDuration(Duration duration) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    final int seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}j ${minutes}m ${seconds}d';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}d';
    } else {
      return '${seconds}d';
    }
  }

  // Capitalize first letter of each word
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // Capitalize first letter only
  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  // Format text to sentence case
  static String toSentenceCase(String text) {
    if (text.isEmpty) return text;
    
    return text.split('. ').map((sentence) {
      if (sentence.isEmpty) return sentence;
      return sentence[0].toUpperCase() + sentence.substring(1).toLowerCase();
    }).join('. ');
  }

  // Truncate text with ellipsis
  static String truncateText(String text, int maxLength, {String ellipsis = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - ellipsis.length) + ellipsis;
  }

  // Format decimal places
  static String formatDecimal(double value, int decimalPlaces) {
    return value.toStringAsFixed(decimalPlaces);
  }

  // Parse Indonesian currency string back to double
  static double parseCurrency(String currencyString) {
    // Remove currency symbol and spaces
    String cleaned = currencyString
        .replaceAll('Rp', '')
        .replaceAll(' ', '')
        .trim();
    
    // Replace Indonesian decimal separator
    cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
    
    try {
      return double.parse(cleaned);
    } catch (e) {
      return 0.0;
    }
  }
}