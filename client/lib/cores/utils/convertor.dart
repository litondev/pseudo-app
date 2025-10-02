class Convertor {
  // Convert string to bool
  static bool stringToBool(String? value) {
    if (value == null || value.isEmpty) return false;
    
    final String lowerValue = value.toLowerCase().trim();
    
    // Check for true values
    if (lowerValue == 'true' || 
        lowerValue == '1' || 
        lowerValue == 'yes' || 
        lowerValue == 'on' ||
        lowerValue == 'active') {
      return true;
    }
    
    // Check for false values
    if (lowerValue == 'false' || 
        lowerValue == '0' || 
        lowerValue == 'no' || 
        lowerValue == 'off' ||
        lowerValue == 'inactive') {
      return false;
    }
    
    // Default to false for unknown values
    return false;
  }

  // Convert bool to string
  static String boolToString(bool value, {String trueValue = 'true', String falseValue = 'false'}) {
    return value ? trueValue : falseValue;
  }

  // Convert string to int with default value
  static int stringToInt(String? value, {int defaultValue = 0}) {
    if (value == null || value.isEmpty) return defaultValue;
    
    try {
      return int.parse(value.trim());
    } catch (e) {
      return defaultValue;
    }
  }

  // Convert string to double with default value
  static double stringToDouble(String? value, {double defaultValue = 0.0}) {
    if (value == null || value.isEmpty) return defaultValue;
    
    try {
      return double.parse(value.trim());
    } catch (e) {
      return defaultValue;
    }
  }

  // Convert int to string
  static String intToString(int? value, {String defaultValue = '0'}) {
    return value?.toString() ?? defaultValue;
  }

  // Convert double to string
  static String doubleToString(double? value, {String defaultValue = '0.0'}) {
    return value?.toString() ?? defaultValue;
  }

  // Convert list to string with separator
  static String listToString(List<dynamic>? list, {String separator = ', '}) {
    if (list == null || list.isEmpty) return '';
    return list.map((e) => e.toString()).join(separator);
  }

  // Convert string to list with separator
  static List<String> stringToList(String? value, {String separator = ','}) {
    if (value == null || value.isEmpty) return [];
    
    return value
        .split(separator)
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  // Convert map to query string
  static String mapToQueryString(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) return '';
    
    final List<String> pairs = [];
    map.forEach((key, value) {
      if (value != null) {
        pairs.add('${Uri.encodeComponent(key)}=${Uri.encodeComponent(value.toString())}');
      }
    });
    
    return pairs.join('&');
  }

  // Convert bytes to human readable size
  static String bytesToHumanReadable(int bytes) {
    const List<String> units = ['B', 'KB', 'MB', 'GB', 'TB'];
    double size = bytes.toDouble();
    int unitIndex = 0;
    
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    
    return '${size.toStringAsFixed(2)} ${units[unitIndex]}';
  }

  // Convert milliseconds to duration string
  static String millisecondsToDuration(int milliseconds) {
    final Duration duration = Duration(milliseconds: milliseconds);
    
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    final int seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  // Convert hex color to Color object (returns hex string for now)
  static String hexToColorString(String hex) {
    // Remove # if present
    hex = hex.replaceAll('#', '');
    
    // Ensure 6 characters
    if (hex.length == 3) {
      hex = hex.split('').map((char) => char + char).join();
    }
    
    // Add alpha if not present
    if (hex.length == 6) {
      hex = 'FF' + hex;
    }
    
    return hex.toUpperCase();
  }

  // Convert enum to string
  static String enumToString(dynamic enumValue) {
    return enumValue.toString().split('.').last;
  }

  // Convert string to enum (generic helper)
  static T? stringToEnum<T>(String value, List<T> enumValues) {
    try {
      return enumValues.firstWhere(
        (e) => enumToString(e).toLowerCase() == value.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Sanitize string for file names
  static String sanitizeFileName(String fileName) {
    // Remove or replace invalid characters
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }

  // Convert camelCase to snake_case
  static String camelToSnake(String camelCase) {
    return camelCase
        .replaceAllMapped(RegExp(r'[A-Z]'), (match) => '_${match.group(0)!.toLowerCase()}')
        .replaceAll(RegExp(r'^_'), '');
  }

  // Convert snake_case to camelCase
  static String snakeToCamel(String snakeCase) {
    final List<String> parts = snakeCase.split('_');
    if (parts.isEmpty) return snakeCase;
    
    String result = parts.first;
    for (int i = 1; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        result += parts[i][0].toUpperCase() + parts[i].substring(1);
      }
    }
    
    return result;
  }
}