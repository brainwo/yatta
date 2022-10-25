import 'package:flutter/painting.dart';

/// Arc Dark theme for YTHacker
/// Adapted from https://github.com/arc-design/arc-theme
///
/// For community submitted theme and related information, refer to this forum:
/// https://github.com/brainwo/ythacker/discussions/1
class AppTheme {
  /// This class is not meant to be instatiated or extended; this constructor
  /// prevents instantiation and extension.
  AppTheme._();

  static const Color background =
      Color.fromRGBO(64, 69, 82, 1.0); // #404552
  static const Color backgroundDarker = Color.fromRGBO(47, 52, 63, 1.0); // #2F343F
  static const Color text = Color.fromRGBO(211, 218, 227, 1.0); // #D3DAE3
  static const Color primary =
      Color.fromRGBO(81, 144, 219, 1.0); // #5294E2
}
