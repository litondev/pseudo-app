import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppPlatform {
  // Platform detection
  static bool get isWeb => kIsWeb;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isLinux => !kIsWeb && Platform.isLinux;
  static bool get isFuchsia => !kIsWeb && Platform.isFuchsia;

  // Platform groups
  static bool get isMobile => isAndroid || isIOS;
  static bool get isDesktop => isWindows || isMacOS || isLinux;
  static bool get isApple => isIOS || isMacOS;
  static bool get isGoogle => isAndroid || isFuchsia;

  // Get platform name as string
  static String get platform {
    if (isWeb) return 'web';
    if (isAndroid) return 'android';
    if (isIOS) return 'ios';
    if (isWindows) return 'windows';
    if (isMacOS) return 'macos';
    if (isLinux) return 'linux';
    if (isFuchsia) return 'fuchsia';
    return 'unknown';
  }

  // Get platform display name
  static String get platformDisplayName {
    if (isWeb) return 'Web';
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    if (isWindows) return 'Windows';
    if (isMacOS) return 'macOS';
    if (isLinux) return 'Linux';
    if (isFuchsia) return 'Fuchsia';
    return 'Unknown';
  }

  // Get operating system version (if available)
  static String get operatingSystemVersion {
    if (kIsWeb) return 'Web';
    try {
      return Platform.operatingSystemVersion;
    } catch (e) {
      return 'Unknown';
    }
  }

  // Get number of processors (if available)
  static int get numberOfProcessors {
    if (kIsWeb) return 1;
    try {
      return Platform.numberOfProcessors;
    } catch (e) {
      return 1;
    }
  }

  // Get path separator
  static String get pathSeparator {
    if (kIsWeb) return '/';
    try {
      return Platform.pathSeparator;
    } catch (e) {
      return '/';
    }
  }

  // Get line terminator
  static String get lineTerminator {
    if (kIsWeb) return '\n';
    try {
      return Platform.lineTerminator;
    } catch (e) {
      return '\n';
    }
  }

  // Get locale name
  static String get localeName {
    if (kIsWeb) return 'en_US';
    try {
      return Platform.localeName;
    } catch (e) {
      return 'en_US';
    }
  }

  // Platform-specific features
  static bool get supportsFileSystem => !isWeb;
  static bool get supportsNativeCode => !isWeb;
  static bool get supportsBackgroundProcessing => isMobile || isDesktop;
  static bool get supportsNotifications => isMobile || isDesktop;
  static bool get supportsCamera => isMobile;
  static bool get supportsGPS => isMobile;
  static bool get supportsBiometrics => isMobile;
  static bool get supportsAppStore => isIOS || isMacOS;
  static bool get supportsPlayStore => isAndroid;
  static bool get supportsWindowsStore => isWindows;

  // Platform-specific UI considerations
  static bool get hasPhysicalBackButton => isAndroid;
  static bool get hasHomeIndicator => isIOS;
  static bool get hasNotch => isMobile; // This is a generalization
  static bool get hasKeyboard => isDesktop || isWeb;
  static bool get hasTouchScreen => isMobile || isWeb;
  static bool get hasMousePointer => isDesktop || isWeb;

  // Platform-specific constants
  static double get defaultAppBarHeight {
    if (isIOS) return 44.0;
    if (isAndroid) return 56.0;
    if (isDesktop || isWeb) return 64.0;
    return 56.0;
  }

  static double get defaultBottomNavigationBarHeight {
    if (isIOS) return 83.0; // Including safe area
    if (isAndroid) return 56.0;
    if (isDesktop || isWeb) return 60.0;
    return 56.0;
  }

  static double get defaultTabBarHeight {
    return 48.0; // Standard across platforms
  }

  // Platform-specific behavior helpers
  static bool get shouldUseNativeScrollPhysics => isIOS;
  static bool get shouldShowScrollbars => isDesktop || isWeb;
  static bool get shouldUseHapticFeedback => isMobile;
  static bool get shouldAutoFocusTextFields => isDesktop || isWeb;

  // Platform-specific file extensions
  static String get executableExtension {
    if (isWindows) return '.exe';
    return '';
  }

  static String get libraryExtension {
    if (isWindows) return '.dll';
    if (isMacOS) return '.dylib';
    if (isLinux) return '.so';
    return '';
  }

  // Platform-specific directories
  static String get homeDirectory {
    if (kIsWeb) return '/';
    try {
      return Platform.environment['HOME'] ?? 
             Platform.environment['USERPROFILE'] ?? 
             '/';
    } catch (e) {
      return '/';
    }
  }

  static String get tempDirectory {
    if (kIsWeb) return '/tmp';
    try {
      if (isWindows) {
        return Platform.environment['TEMP'] ?? 
               Platform.environment['TMP'] ?? 
               'C:\\temp';
      }
      return '/tmp';
    } catch (e) {
      return '/tmp';
    }
  }

  // Platform-specific network information
  static bool get isOnline {
    // This would typically require additional packages like connectivity_plus
    // For now, we assume online status
    return true;
  }

  // Debug information
  static Map<String, dynamic> get debugInfo {
    return {
      'platform': platform,
      'platformDisplayName': platformDisplayName,
      'isWeb': isWeb,
      'isMobile': isMobile,
      'isDesktop': isDesktop,
      'operatingSystemVersion': operatingSystemVersion,
      'numberOfProcessors': numberOfProcessors,
      'localeName': localeName,
      'supportsFileSystem': supportsFileSystem,
      'supportsNativeCode': supportsNativeCode,
    };
  }

  // Platform-specific initialization
  static void initialize() {
    // Platform-specific initialization code can go here
    // For example, setting up platform-specific services
  }

  // Platform-specific cleanup
  static void dispose() {
    // Platform-specific cleanup code can go here
  }
}