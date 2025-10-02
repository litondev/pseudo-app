import 'package:flutter/material.dart';
import 'platform.dart';

class AppDimension {
  // Breakpoints for responsive design
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 1024;
  static const double desktopMinWidth = 1025;

  // Small screen breakpoints
  static const double smallMobileMaxWidth = 360;
  static const double mediumMobileMaxWidth = 480;

  // Large screen breakpoints
  static const double largeTabletMaxWidth = 1200;
  static const double extraLargeDesktopMinWidth = 1440;

  // Get screen dimensions
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Device type detection based on screen width
  static bool isDesktop(BuildContext context) {
    if (AppPlatform.isDesktop || AppPlatform.isWeb) {
      return getScreenWidth(context) >= desktopMinWidth;
    }
    return false;
  }

  static bool isTablet(BuildContext context) {
    final width = getScreenWidth(context);
    return width > mobileMaxWidth && width <= tabletMaxWidth;
  }

  static bool isMobile(BuildContext context) {
    return getScreenWidth(context) <= mobileMaxWidth;
  }

  // More specific device type detection
  static bool isSmallMobile(BuildContext context) {
    return getScreenWidth(context) <= smallMobileMaxWidth;
  }

  static bool isMediumMobile(BuildContext context) {
    final width = getScreenWidth(context);
    return width > smallMobileMaxWidth && width <= mediumMobileMaxWidth;
  }

  static bool isLargeMobile(BuildContext context) {
    final width = getScreenWidth(context);
    return width > mediumMobileMaxWidth && width <= mobileMaxWidth;
  }

  static bool isSmallTablet(BuildContext context) {
    final width = getScreenWidth(context);
    return width > mobileMaxWidth && width <= 800;
  }

  static bool isLargeTablet(BuildContext context) {
    final width = getScreenWidth(context);
    return width > 800 && width <= tabletMaxWidth;
  }

  static bool isSmallDesktop(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= desktopMinWidth && width < largeTabletMaxWidth;
  }

  static bool isLargeDesktop(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= largeTabletMaxWidth && width < extraLargeDesktopMinWidth;
  }

  static bool isExtraLargeDesktop(BuildContext context) {
    return getScreenWidth(context) >= extraLargeDesktopMinWidth;
  }

  // Platform type as string
  static String platformType(BuildContext context) {
    if (isDesktop(context)) return 'desktop';
    if (isTablet(context)) return 'tablet';
    if (isMobile(context)) return 'mobile';
    return 'unknown';
  }

  // Get detailed platform type
  static String detailedPlatformType(BuildContext context) {
    if (isExtraLargeDesktop(context)) return 'extra_large_desktop';
    if (isLargeDesktop(context)) return 'large_desktop';
    if (isSmallDesktop(context)) return 'small_desktop';
    if (isLargeTablet(context)) return 'large_tablet';
    if (isSmallTablet(context)) return 'small_tablet';
    if (isLargeMobile(context)) return 'large_mobile';
    if (isMediumMobile(context)) return 'medium_mobile';
    if (isSmallMobile(context)) return 'small_mobile';
    return 'unknown';
  }

  // Orientation detection
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  // Aspect ratio
  static double getAspectRatio(BuildContext context) {
    final size = getScreenSize(context);
    return size.width / size.height;
  }

  // Safe area information
  static EdgeInsets getSafeArea(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  static double getTopSafeArea(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  static double getBottomSafeArea(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  // Device pixel ratio
  static double getDevicePixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  // Text scale factor
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor;
  }

  // Responsive values based on screen size
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }

  // Responsive values with more granular control
  static T responsiveDetailed<T>(
    BuildContext context, {
    required T mobile,
    T? smallMobile,
    T? mediumMobile,
    T? largeMobile,
    T? tablet,
    T? smallTablet,
    T? largeTablet,
    T? desktop,
    T? smallDesktop,
    T? largeDesktop,
    T? extraLargeDesktop,
  }) {
    if (isExtraLargeDesktop(context) && extraLargeDesktop != null) return extraLargeDesktop;
    if (isLargeDesktop(context) && largeDesktop != null) return largeDesktop;
    if (isSmallDesktop(context) && smallDesktop != null) return smallDesktop;
    if (isDesktop(context) && desktop != null) return desktop;
    
    if (isLargeTablet(context) && largeTablet != null) return largeTablet;
    if (isSmallTablet(context) && smallTablet != null) return smallTablet;
    if (isTablet(context) && tablet != null) return tablet;
    
    if (isLargeMobile(context) && largeMobile != null) return largeMobile;
    if (isMediumMobile(context) && mediumMobile != null) return mediumMobile;
    if (isSmallMobile(context) && smallMobile != null) return smallMobile;
    
    return mobile;
  }

  // Column count for grid layouts
  static int getGridColumnCount(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 3;
    return 2;
  }

  // Responsive column count with custom values
  static int responsiveColumnCount(
    BuildContext context, {
    int mobile = 1,
    int? tablet,
    int? desktop,
  }) {
    return responsive(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 2,
      desktop: desktop ?? mobile * 3,
    );
  }

  // Maximum content width for readability
  static double getMaxContentWidth(BuildContext context) {
    if (isDesktop(context)) return 1200;
    if (isTablet(context)) return 800;
    return double.infinity;
  }

  // Sidebar width
  static double getSidebarWidth(BuildContext context) {
    if (isDesktop(context)) return 280;
    if (isTablet(context)) return 240;
    return 200;
  }

  // Navigation rail width
  static double getNavigationRailWidth(BuildContext context) {
    return responsive(
      context,
      mobile: 56,
      tablet: 72,
      desktop: 80,
    );
  }

  // Debug information
  static Map<String, dynamic> debugInfo(BuildContext context) {
    return {
      'screenSize': getScreenSize(context).toString(),
      'screenWidth': getScreenWidth(context),
      'screenHeight': getScreenHeight(context),
      'platformType': platformType(context),
      'detailedPlatformType': detailedPlatformType(context),
      'isPortrait': isPortrait(context),
      'isLandscape': isLandscape(context),
      'aspectRatio': getAspectRatio(context),
      'devicePixelRatio': getDevicePixelRatio(context),
      'textScaleFactor': getTextScaleFactor(context),
      'safeArea': getSafeArea(context).toString(),
    };
  }
}