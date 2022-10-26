import 'package:flutter/rendering.dart';

class AppTheme {
  final Color background;
  final Color backgroundDarker;
  final Color text;
  final Color primary;

  AppTheme({
    required this.background,
    required this.backgroundDarker,
    required this.text,
    required this.primary,
  });

  static AppTheme archDark() {
    return AppTheme(
      background: const Color.fromRGBO(64, 69, 82, 1.0), // #404552
      backgroundDarker: const Color.fromRGBO(47, 52, 63, 1.0), // #2F343F
      text: const Color.fromRGBO(211, 218, 227, 1.0), // #D3DAE3
      primary: const Color.fromRGBO(81, 144, 219, 1.0), // #5294E2
    );
  }

  static AppTheme? from(String themeName) {
    switch (themeName) {
      case 'Arc-Dark':
        return archDark();
      default:
        return null;
    }
  }
}
