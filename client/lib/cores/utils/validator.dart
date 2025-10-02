class Validator {
  // Required field validation
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Field'} wajib diisi';
    }
    return null;
  }

  // Minimum length validation
  static String? minLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.length < minLength) {
      return '${fieldName ?? 'Field'} minimal $minLength karakter';
    }
    return null;
  }

  // Maximum length validation
  static String? maxLength(String? value, int maxLength, {String? fieldName}) {
    if (value != null && value.length > maxLength) {
      return '${fieldName ?? 'Field'} maksimal $maxLength karakter';
    }
    return null;
  }

  // Email validation
  static String? email(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Email'} wajib diisi';
    }
    
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value.trim())) {
      return '${fieldName ?? 'Email'} tidak valid';
    }
    
    return null;
  }

  // Phone number validation (Indonesian format)
  static String? phoneNumber(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Nomor telepon'} wajib diisi';
    }
    
    // Remove all non-digit characters for validation
    final String digits = value.replaceAll(RegExp(r'\D'), '');
    
    // Check Indonesian phone number patterns
    final RegExp phoneRegex = RegExp(r'^(0|62)[0-9]{9,12}$');
    
    if (!phoneRegex.hasMatch(digits)) {
      return '${fieldName ?? 'Nomor telepon'} tidak valid';
    }
    
    return null;
  }

  // Password validation
  static String? password(String? value, {String? fieldName, int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Password'} wajib diisi';
    }
    
    if (value.length < minLength) {
      return '${fieldName ?? 'Password'} minimal $minLength karakter';
    }
    
    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return '${fieldName ?? 'Password'} harus mengandung huruf besar';
    }
    
    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return '${fieldName ?? 'Password'} harus mengandung huruf kecil';
    }
    
    // Check for at least one digit
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return '${fieldName ?? 'Password'} harus mengandung angka';
    }
    
    return null;
  }

  // Confirm password validation
  static String? confirmPassword(String? value, String? originalPassword, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Konfirmasi password'} wajib diisi';
    }
    
    if (value != originalPassword) {
      return '${fieldName ?? 'Konfirmasi password'} tidak sama';
    }
    
    return null;
  }

  // Numeric validation
  static String? numeric(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Field'} wajib diisi';
    }
    
    if (double.tryParse(value.trim()) == null) {
      return '${fieldName ?? 'Field'} harus berupa angka';
    }
    
    return null;
  }

  // Integer validation
  static String? integer(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Field'} wajib diisi';
    }
    
    if (int.tryParse(value.trim()) == null) {
      return '${fieldName ?? 'Field'} harus berupa bilangan bulat';
    }
    
    return null;
  }

  // Minimum value validation
  static String? minValue(String? value, double minValue, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Field'} wajib diisi';
    }
    
    final double? numValue = double.tryParse(value.trim());
    if (numValue == null) {
      return '${fieldName ?? 'Field'} harus berupa angka';
    }
    
    if (numValue < minValue) {
      return '${fieldName ?? 'Field'} minimal $minValue';
    }
    
    return null;
  }

  // Maximum value validation
  static String? maxValue(String? value, double maxValue, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Field'} wajib diisi';
    }
    
    final double? numValue = double.tryParse(value.trim());
    if (numValue == null) {
      return '${fieldName ?? 'Field'} harus berupa angka';
    }
    
    if (numValue > maxValue) {
      return '${fieldName ?? 'Field'} maksimal $maxValue';
    }
    
    return null;
  }

  // URL validation
  static String? url(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'URL'} wajib diisi';
    }
    
    final RegExp urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    
    if (!urlRegex.hasMatch(value.trim())) {
      return '${fieldName ?? 'URL'} tidak valid';
    }
    
    return null;
  }

  // Date validation
  static String? date(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Tanggal'} wajib diisi';
    }
    
    try {
      DateTime.parse(value.trim());
      return null;
    } catch (e) {
      return '${fieldName ?? 'Tanggal'} tidak valid';
    }
  }

  // Custom regex validation
  static String? regex(String? value, RegExp pattern, String errorMessage, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Field'} wajib diisi';
    }
    
    if (!pattern.hasMatch(value.trim())) {
      return errorMessage;
    }
    
    return null;
  }

  // Combine multiple validators
  static String? combine(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final String? error = validator(value);
      if (error != null) {
        return error;
      }
    }
    return null;
  }

  // Indonesian ID number (NIK) validation
  static String? indonesianId(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'NIK'} wajib diisi';
    }
    
    final String digits = value.replaceAll(RegExp(r'\D'), '');
    
    if (digits.length != 16) {
      return '${fieldName ?? 'NIK'} harus 16 digit';
    }
    
    return null;
  }

  // Credit card validation (Luhn algorithm)
  static String? creditCard(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Nomor kartu'} wajib diisi';
    }
    
    final String digits = value.replaceAll(RegExp(r'\D'), '');
    
    if (digits.length < 13 || digits.length > 19) {
      return '${fieldName ?? 'Nomor kartu'} tidak valid';
    }
    
    // Luhn algorithm
    int sum = 0;
    bool alternate = false;
    
    for (int i = digits.length - 1; i >= 0; i--) {
      int digit = int.parse(digits[i]);
      
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }
      
      sum += digit;
      alternate = !alternate;
    }
    
    if (sum % 10 != 0) {
      return '${fieldName ?? 'Nomor kartu'} tidak valid';
    }
    
    return null;
  }
}