import 'dart:io';

import 'package:xdg_directories/xdg_directories.dart';

import 'setting_options.dart';

/// Yatta configuration file
/// Configuration schema for [Yatta](https://github.com/yatta/yatta), on-demand video organizer application"
class ConfigSchema {
  const ConfigSchema({
    required this.minimizedOnLaunch,
    required this.onPlay,
    required this.autofocusNavigation,
    required this.theme,
    required this.history,
    this.videoPlayCommand,
    this.videoListenCommand,
    this.youtube,
  });

  /// Launch application in minimized mode.
  final bool minimizedOnLaunch;

  /// Application behavior when play button is pressed.
  final OnPlayOptions onPlay;

  /// Autofocus on first item on a screen for easier keyboard navigation.
  final bool autofocusNavigation;

  /// Command executed on "Play" button.
  final List<String>? videoPlayCommand;

  /// Command executed on "Listen" button.
  final List<String>? videoListenCommand;

  /// YouTube related configuration.
  final ConfigYoutube? youtube;

  /// Application theme related configuration.
  final ConfigTheme theme;

  /// History and Saved Playlist related configuration.
  final ConfigHistory history;

  factory ConfigSchema.defaultConfig() {
    return const ConfigSchema(
      minimizedOnLaunch: false,
      onPlay: OnPlayOptions.nothing,
      autofocusNavigation: true,
      theme: ConfigTheme(),
      history: ConfigHistory(),
    );
  }

  factory ConfigSchema.fromJson(final dynamic json) {
    if (!(json is Map)) {
      return ConfigSchema.defaultConfig();
    }

    final minimizedOnLaunch = switch (json['minimizedOnLaunch']) {
      final bool value => value,
      _ => null
    };
    final onPlay = switch (json['onPlay']) {
      'nothing' => OnPlayOptions.nothing,
      'minimize' => OnPlayOptions.minimize,
      'tray' => OnPlayOptions.tray,
      'exit' => OnPlayOptions.exit,
      _ => null
    };
    final autofocusNavigation = switch (json['autofocusNavigation']) {
      final bool value => value,
      _ => null
    };
    final videoPlayCommand = switch (json['videoPlayCommand']) {
      final List<dynamic> value =>
        value.map((final command) => command.toString()).toList(),
      _ => null
    };

    final videoListenCommand = switch (json['videoListenCommand']) {
      final List<dynamic> value =>
        value.map((final command) => command.toString()).toList(),
      _ => null
    };
    final youtube = switch (json['youtube']) {
      final Map<dynamic, dynamic>? value => value,
      _ => null
    };
    final theme = switch (json['theme']) {
      final Map<dynamic, dynamic>? value => value,
      _ => null
    };

    return ConfigSchema(
      minimizedOnLaunch: minimizedOnLaunch ?? false,
      onPlay: onPlay ?? OnPlayOptions.nothing,
      autofocusNavigation: autofocusNavigation ?? true,
      videoPlayCommand: videoPlayCommand,
      videoListenCommand: videoListenCommand,
      theme: ConfigTheme.fromMap(theme),
      youtube: ConfigYoutube.fromMap(youtube),
      history: const ConfigHistory(),
    );
  }
}

/// YouTube related configuration.
class ConfigYoutube {
  const ConfigYoutube({
    required this.apiKey,
    this.resultPerSearch = 10,
    this.regionId,
  });

  /// YouTube Data API v3 API key.
  final String apiKey;

  /// Number of results fetched on each API call.
  final int resultPerSearch;

  /// Region of the search results.
  final String? regionId;

  factory ConfigYoutube.fromMap(final Map<dynamic, dynamic>? youtube) =>
      youtube == null
          ? const ConfigYoutube(apiKey: '')
          : ConfigYoutube(
              apiKey: switch (youtube['apiKey']) {
                final String value => value,
                _ => '',
              },
              resultPerSearch: switch (youtube['resultPerSearch']) {
                final int value => value,
                _ => 10,
              },
            );
}

/// Application theme related configuration.
class ConfigTheme {
  const ConfigTheme({
    this.brightness = BrightnessOptions.system,
    this.visualDensity = VisualDensityOptions.standard,
  });

  final BrightnessOptions brightness;
  final VisualDensityOptions visualDensity;

  factory ConfigTheme.fromMap(final Map<dynamic, dynamic>? theme) =>
      theme == null
          ? const ConfigTheme()
          : ConfigTheme(
              brightness: switch (theme['brightness']) {
                'light' => BrightnessOptions.light,
                'dark' => BrightnessOptions.dark,
                'system' => BrightnessOptions.system,
                _ => BrightnessOptions.system,
              },
            );
}

/// History and Saved Playlist related configuration.
class ConfigHistory {
  const ConfigHistory({
    this.pause = false,
    this.size = 2000,
  });

  /// Pause history, not receiving any more new playback history.
  final bool pause;

  /// Number of history to keep
  final int size;
}
