import 'dart:ui';

class AppTheme {
  final Brightness brightness;
  final Color background;
  final Color backgroundHighlight;
  final Color backgroundDarker;
  final Color text;
  final Color primary;

  AppTheme({
    required this.brightness,
    required this.background,
    required this.backgroundHighlight,
    required this.backgroundDarker,
    required this.text,
    required this.primary,
  });

  static AppTheme arc() {
    return AppTheme(
      brightness: Brightness.light,
      background: const Color.fromRGBO(64, 69, 82, 1), // #404552
      backgroundHighlight: const Color.fromRGBO(80, 86, 102, 1), // #505666
      backgroundDarker: const Color.fromRGBO(47, 52, 63, 1), // #2F343F`
      text: const Color.fromRGBO(211, 218, 227, 1), // #D3DAE3
      primary: const Color.fromRGBO(81, 144, 219, 1), // #5294E2
    );
  }

  static AppTheme arcDarker() {
    return AppTheme(
      brightness: Brightness.light,
      background: const Color.fromRGBO(64, 69, 82, 1), // #404552
      backgroundHighlight: const Color.fromRGBO(80, 86, 102, 1), // #505666
      backgroundDarker: const Color.fromRGBO(47, 52, 63, 1), // #2F343F`
      text: const Color.fromRGBO(211, 218, 227, 1), // #D3DAE3
      primary: const Color.fromRGBO(81, 144, 219, 1), // #5294E2
    );
  }

  static AppTheme arcDark() {
    return AppTheme(
      brightness: Brightness.dark,
      background: const Color.fromRGBO(64, 69, 82, 1), // #404552
      backgroundHighlight: const Color.fromRGBO(80, 86, 102, 1), // #505666
      backgroundDarker: const Color.fromRGBO(47, 52, 63, 1), // #2F343F`
      text: const Color.fromRGBO(211, 218, 227, 1), // #D3DAE3
      primary: const Color.fromRGBO(81, 144, 219, 1), // #5294E2
    );
  }

  static AppTheme from(final String themeName) {
    return switch (themeName) {
      'Arc' => arc(),
      'Arc-Darker' => arcDarker(),
      'Arc-Dark' => arcDark(),
      _ => arcDark(),
    };
  }
}
