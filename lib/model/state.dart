import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'setting_options.dart';

class BrightnessMode extends StateNotifier<BrightnessOptions> {
  BrightnessMode() : super(BrightnessOptions.dark);

  void switchMode(final BrightnessOptions option) => state = option;

  void switchModeFromString(final String option) =>
      state = BrightnessOptions.fromString(option);
}
