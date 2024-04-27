import 'dart:io';
import 'package:collection/collection.dart';
import 'package:xdg_directories/xdg_directories.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'setting_options.dart';

const List<String> configPathLookup = [
  '/yatta/config.yaml',
  '/yatta/config.yml',
  '/yatta/config.json',
];

/// Yatta configuration file
/// Configuration schema for [Yatta](https://github.com/yatta/yatta), on-demand video organizer application"
class UserConfig {
  UserConfig({
    required this.minimizedOnLaunch,
    required this.onPlay,
    required this.autofocusNavigation,
    required this.theme,
    required this.history,
    final String? filePath,
    final String? rawFile,
    this.videoPlayCommand,
    this.videoListenCommand,
    this.youtube,
  })  : _filePath = filePath ?? '${configHome.path}${configPathLookup[0]}',
        _rawFile = rawFile ?? '';

  /// Path of user configuration
  String _filePath;

  /// Raw YAML file
  String _rawFile;

  /// Launch application in minimized mode
  bool minimizedOnLaunch;

  /// Application behavior when play button is pressed
  OnPlayOptions onPlay;

  /// Autofocus on first item on a screen for easier keyboard navigation
  bool autofocusNavigation;

  /// Command executed on "Play" button
  List<String>? videoPlayCommand;

  /// Command executed on "Listen" button
  List<String>? videoListenCommand;

  /// YouTube related configuration
  _ConfigYoutube? youtube;

  /// Application theme related configuration
  _ConfigTheme theme;

  /// History and Saved Playlist related configuration
  _ConfigHistory history;

  factory UserConfig._defaultConfig() {
    return UserConfig(
      minimizedOnLaunch: false,
      onPlay: OnPlayOptions.nothing,
      autofocusNavigation: true,
      theme: const _ConfigTheme(),
      history: const _ConfigHistory(),
    );
  }

  factory UserConfig._fromYaml({
    required final String filePath,
    required final String rawFile,
    required final dynamic json,
  }) {
    if (!(json is Map)) {
      return UserConfig._defaultConfig();
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
    final history = switch (json['history']) {
      final Map<dynamic, dynamic>? value => value,
      _ => null
    };

    return UserConfig(
      filePath: filePath,
      rawFile: rawFile,
      minimizedOnLaunch: minimizedOnLaunch ?? false,
      onPlay: onPlay ?? OnPlayOptions.nothing,
      autofocusNavigation: autofocusNavigation ?? true,
      videoPlayCommand: videoPlayCommand,
      videoListenCommand: videoListenCommand,
      theme: _ConfigTheme.fromMap(theme),
      youtube: _ConfigYoutube.fromMap(youtube),
      history: _ConfigHistory.fromMap(history),
    );
  }

  static Future<UserConfig> load() async {
    final configLookupResult = configPathLookup.map((final path) {
      final filePath = '${configHome.path}$path';
      return (filePath, File(filePath));
    }).firstWhereOrNull((final configLookup) => configLookup.$2.existsSync());

    if (configLookupResult == null) {
      return UserConfig._defaultConfig();
    }

    final (path, file) = configLookupResult;
    return file.readAsString().then((final rawFile) => UserConfig._fromYaml(
          filePath: path,
          json: loadYaml(rawFile),
          rawFile: rawFile,
        ));
  }

  Future<void> _update(
    final Iterable<Object?> path,
    final Object? value,
  ) async {
    final yamlEditor = YamlEditor(_rawFile)..update(path, value);
    _rawFile = yamlEditor.toString();
    await File(_filePath).writeAsString(_rawFile);
  }

  Future<void> updateMinimizedOnLaunch(final bool newValue) async =>
      _update(['minimizedOnLaunch'], newValue)
          .whenComplete(() => this.minimizedOnLaunch = newValue);

  Future<void> updateOnPlay(final OnPlayOptions newValue) async =>
      _update(['onPlay'], newValue.name)
          .whenComplete(() => this.onPlay = newValue);

  Future<void> updateAutofocusNavigation(final bool newValue) async =>
      _update(['autofocusNavigation'], newValue)
          .whenComplete(() => this.autofocusNavigation = newValue);

  Future<void> updateVideoPlayCommand(final List<String>? newValue) async =>
      _update(['videoPlayCommand'], newValue)
          .whenComplete(() => this.videoPlayCommand = newValue);

  Future<void> updateVideoListenCommand(final List<String>? newValue) async =>
      _update(['videoListenCommand'], newValue)
          .whenComplete(() => this.videoListenCommand = newValue);
}

/// YouTube related configuration.
class _ConfigYoutube {
  const _ConfigYoutube({
    required this.apiKey,
    this.enablePublishDate = true,
    this.enableWatchCount = false,
    this.resultPerSearch = 10,
    this.infiniteScrollSearch = false,
    this.regionId,
  });

  /// YouTube Data API v3 API key
  final String apiKey;

  /// Show Publish Date on search result (might cost more quota)
  final bool enablePublishDate;

  /// Show Watch Count on search result (might cost more quota)
  final bool enableWatchCount;

  /// Number of results fetched on each API call
  final int resultPerSearch;

  /// Enable infinite scroll on YouTube search (will cost more quota when
  /// enabled)
  final bool infiniteScrollSearch;

  /// Region of the search results
  final String? regionId;

  factory _ConfigYoutube.fromMap(final Map<dynamic, dynamic>? youtube) =>
      youtube == null
          ? const _ConfigYoutube(apiKey: '')
          : _ConfigYoutube(
              apiKey: switch (youtube['apiKey']) {
                final String apiKey => apiKey,
                _ => '',
              },
              enablePublishDate: switch (youtube['enablePublishDate']) {
                final bool enablePublishDate => enablePublishDate,
                _ => true,
              },
              enableWatchCount: switch (youtube['enableWatchCount']) {
                final bool enableWatchCount => enableWatchCount,
                _ => false
              },
              resultPerSearch: switch (youtube['resultPerSearch']) {
                final int resultPerSearch => resultPerSearch,
                _ => 10,
              },
              infiniteScrollSearch: switch (youtube['infiniteScrollSearch']) {
                final bool infiniteScrollSearch => infiniteScrollSearch,
                _ => false,
              },
              regionId: switch (youtube['regionId']) {
                final String regionId => regionId,
                _ => null,
              });
}

/// Application theme related configuration.
class _ConfigTheme {
  const _ConfigTheme({
    this.brightness = BrightnessOptions.system,
    this.visualDensity = VisualDensityOptions.standard,
  });

  final BrightnessOptions brightness;
  final VisualDensityOptions visualDensity;

  factory _ConfigTheme.fromMap(final Map<dynamic, dynamic>? theme) =>
      theme == null
          ? const _ConfigTheme()
          : _ConfigTheme(
              brightness: switch (theme['brightness']) {
                'light' => BrightnessOptions.light,
                'dark' => BrightnessOptions.dark,
                'system' => BrightnessOptions.system,
                _ => BrightnessOptions.system,
              },
              visualDensity: switch (theme['visualDensity']) {
                'compact' => VisualDensityOptions.compact,
                'standard' => VisualDensityOptions.standard,
                'comfort' => VisualDensityOptions.comfort,
                'adaptive' => VisualDensityOptions.adaptive,
                _ => VisualDensityOptions.adaptive,
              });
}

/// History and Saved Playlist related configuration.
class _ConfigHistory {
  const _ConfigHistory({
    this.pause = false,
    this.size = 2000,
  });

  /// Pause history, not receiving any more new playback history.
  final bool pause;

  /// Number of history to keep
  final int size;

  factory _ConfigHistory.fromMap(final Map<dynamic, dynamic>? history) =>
      history == null
          ? const _ConfigHistory()
          : _ConfigHistory(
              pause: switch (history['pause']) {
                final bool pause => pause,
                _ => false,
              },
              size: switch (history['size']) {
                final int size => size,
                _ => 2000,
              },
            );
}
