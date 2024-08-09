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
      background: Color(0xFFFFFFFF),
      backgroundHighlight: Color(0xFFFAFBFC),
      backgroundDarker: Color(0xFFF5F6F7),
      text: Color(0xFFD3DAE3),
      primary: Color(0xFF5294E2),
    );
  }

  factory AppTheme.arcDarker() {
    return const AppTheme(
      brightness: Brightness.light,
      background: Color(0xFF404552),
      backgroundHighlight: Color(0xFF505666),
      backgroundDarker: Color(0xFF2F343F),
      text: Color(0xFFD3DAE3),
      primary: Color(0xFF5294E2),
    );
  }

  factory AppTheme.arcDark() {
    return const AppTheme(
      brightness: Brightness.dark,
      background: Color(0xFF404552),
      backgroundHighlight: Color(0xFF505666),
      backgroundDarker: Color(0xFF2F343F),
      text: Color(0xFFD3DAE3),
      primary: Color(0xFF5294E2),
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
