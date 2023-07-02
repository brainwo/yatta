abstract class SettingOptions {
  int size();
  List<(SettingOptions, String)> options();
  int currentIndex();
}

/// Application behavior when a content is played.
///
/// - `nothing`: do nothing
/// - `minimize`: app window is minimized, may not work on some desktop
/// environment
/// - `tray`: close app window and leave the system tray available
/// - `exit`: kill app entirely, will not leave the system tray
enum OnPlayOptions implements SettingOptions {
  nothing,
  minimize,
  tray,
  exit;

  @override
  int size() => OnPlayOptions.values.length;

  @override
  List<(OnPlayOptions, String)> options() => OnPlayOptions.values
      .map((final e) => (e, '${e.name[0].toUpperCase()}${e.name.substring(1)}'))
      .toList();

  @override
  int currentIndex() => super.index;

  factory OnPlayOptions.fromString(final String option) {
    return switch (option) {
      'nothing' => OnPlayOptions.nothing,
      'minimize' => OnPlayOptions.minimize,
      'tray' => OnPlayOptions.tray,
      'exit' => OnPlayOptions.exit,
      _ => OnPlayOptions.nothing,
    };
  }
}

/// Theme brightness mode.
///
/// `light`: set app to light mode immediately
/// `dark`: set app to dark mode immediately
/// `system`: set app to system light/dark mode immediately, currently there is
///         no implementation available for Linux in Flutter's engine
enum BrightnessOptions implements SettingOptions {
  light,
  dark,
  system;

  @override
  int size() => BrightnessOptions.values.length;

  @override
  List<(BrightnessOptions, String)> options() => BrightnessOptions.values
      .map((final e) => (e, '${e.name[0].toUpperCase()}${e.name.substring(1)}'))
      .toList();

  @override
  int currentIndex() => super.index;

  factory BrightnessOptions.fromString(final String option) {
    return switch (option) {
      'light' => BrightnessOptions.light,
      'dark' => BrightnessOptions.dark,
      'system' => BrightnessOptions.system,
      _ => BrightnessOptions.dark,
    };
  }
}

/// Visual desity mode controls how dense the UI looks. The densier the UI is,
/// the more information can present in one screen. The less densier the UI is,
/// the more whitespaces present in the screen, making it more comfortable to
/// look at.
///
/// TODO
enum VisualDensityOptions implements SettingOptions {
  compact,
  standard,
  comfort,
  adaptive;

  @override
  int size() => VisualDensityOptions.values.length;

  @override
  List<(VisualDensityOptions, String)> options() => VisualDensityOptions.values
      .map((final e) => (e, '${e.name[0].toUpperCase()}${e.name.substring(1)}'))
      .toList();

  @override
  int currentIndex() => super.index;

  factory VisualDensityOptions.fromString(final String option) {
    return switch (option) {
      'compact' => VisualDensityOptions.compact,
      'standard' => VisualDensityOptions.standard,
      'comfort' => VisualDensityOptions.comfort,
      'adaptive' => VisualDensityOptions.adaptive,
      _ => VisualDensityOptions.adaptive,
    };
  }
}
