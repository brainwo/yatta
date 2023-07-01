import 'dart:ui';

class AppTheme {
  final Brightness brightness;
  final Color background;
  final Color backgroundHighlight;
  final Color backgroundDarker;
  final Color text;
  final Color primary;

  const AppTheme({
    required this.brightness,
    required this.background,
    required this.backgroundHighlight,
    required this.backgroundDarker,
    required this.text,
    required this.primary,
  });

  factory AppTheme.arc() {
    return const AppTheme(
      brightness: Brightness.light,
      background: Color.fromRGBO(64, 69, 82, 1), // #404552
      backgroundHighlight: Color.fromRGBO(80, 86, 102, 1), // #505666
      backgroundDarker: Color.fromRGBO(47, 52, 63, 1), // #2F343F`
      text: Color.fromRGBO(211, 218, 227, 1), // #D3DAE3
      primary: Color.fromRGBO(81, 144, 219, 1), // #5294E2
    );
  }

  factory AppTheme.arcDarker() {
    return const AppTheme(
      brightness: Brightness.light,
      background: Color.fromRGBO(64, 69, 82, 1), // #404552
      backgroundHighlight: Color.fromRGBO(80, 86, 102, 1), // #505666
      backgroundDarker: Color.fromRGBO(47, 52, 63, 1), // #2F343F`
      text: Color.fromRGBO(211, 218, 227, 1), // #D3DAE3
      primary: Color.fromRGBO(81, 144, 219, 1), // #5294E2
    );
  }

  factory AppTheme.arcDark() {
    return const AppTheme(
      brightness: Brightness.dark,
      background: Color.fromRGBO(64, 69, 82, 1), // #404552
      backgroundHighlight: Color.fromRGBO(80, 86, 102, 1), // #505666
      backgroundDarker: Color.fromRGBO(47, 52, 63, 1), // #2F343F`
      text: Color.fromRGBO(211, 218, 227, 1), // #D3DAE3
      primary: Color.fromRGBO(81, 144, 219, 1), // #5294E2
    );
  }

  factory AppTheme.from(final String themeName) {
    return switch (themeName) {
      'Arc' => AppTheme.arc(),
      'Arc-Darker' => AppTheme.arcDarker(),
      'Arc-Dark' => AppTheme.arcDark(),
      _ => AppTheme.arcDark(),
    };
  }
}
