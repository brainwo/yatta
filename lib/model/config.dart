import 'dart:io';
import 'package:collection/collection.dart';
import 'package:xdg_directories/xdg_directories.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import '../const.dart';
import '../util/dynamic.dart';
import 'setting_options.dart';

abstract class YamlConfig {
  YamlConfig({
    final String? filePath,
    final String? rawFile,
  })  : _filePath = filePath ?? '${configHome.path}${configPathLookup[0]}',
        _rawFile = rawFile ?? '';

  final String _filePath;
  String _rawFile;

  Future<void> _update(
    final Iterable<Object?> path,
    final Object? value,
  ) async {
    final yamlEditor = YamlEditor(_rawFile)..update(path, value);
    _rawFile = yamlEditor.toString();
    await File(_filePath).writeAsString(_rawFile);
  }
}

/// Yatta configuration file
/// Configuration schema for [Yatta](https://github.com/yatta/yatta), on-demand video organizer application"
class UserConfig extends YamlConfig {
  UserConfig({
    required this.minimizedOnLaunch,
    required this.onPlay,
    required this.autofocusNavigation,
    required this.theme,
    required this.history,
    this.videoPlayCommand,
    this.videoListenCommand,
    this.youtube,
    super.filePath,
    super.rawFile,
  });

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
      theme: _ConfigTheme(),
      history: _ConfigHistory(),
    );
  }

  factory UserConfig._fromYaml({
    required final String filePath,
    required final String rawFile,
    required final dynamic json,
  }) {
    if (json is! Map<String, Object>) {
      return UserConfig._defaultConfig();
    }

    final minimizedOnLaunch = json['minimizedOnLaunch']?.unwrapOrNull<bool>();

    final onPlay = switch (json['onPlay']) {
      'nothing' => OnPlayOptions.nothing,
      'minimize' => OnPlayOptions.minimize,
      'tray' => OnPlayOptions.tray,
      'exit' => OnPlayOptions.exit,
      _ => null
    };
    final autofocusNavigation =
        json['autofocusNavigation']?.unwrapOrNull<bool>();

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
    final youtube = json['youtube']?.unwrapOrNull<Map<Object, Object>>();
    // final youtube = switch (json['youtube']) {
    // final Map<dynamic, dynamic>? value => value,
    // _ => null
    // };
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
      youtube: _ConfigYoutube.fromMap(
        filePath: filePath,
        rawFile: rawFile,
        youtube: youtube,
      ),
      theme: _ConfigTheme.fromMap(
        filePath: filePath,
        rawFile: rawFile,
        theme: theme,
      ),
      history: _ConfigHistory.fromMap(
        filePath: filePath,
        rawFile: rawFile,
        history: history,
      ),
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
class _ConfigYoutube extends YamlConfig {
  _ConfigYoutube({
    required this.apiKey,
    this.enablePublishDate = true,
    this.enableWatchCount = false,
    this.resultPerSearch = 10,
    this.infiniteScrollSearch = false,
    this.regionId,
    super.filePath,
    super.rawFile,
  });

  /// YouTube Data API v3 API key
  String apiKey;

  /// Show Publish Date on search result (might cost more quota)
  bool enablePublishDate;

  /// Show Watch Count on search result (might cost more quota)
  bool enableWatchCount;

  /// Number of results fetched on each API call
  int resultPerSearch;

  /// Enable infinite scroll on YouTube search (will cost more quota when
  /// enabled)
  bool infiniteScrollSearch;

  /// Region of the search results
  String? regionId;

  factory _ConfigYoutube.fromMap({
    required final String filePath,
    required final String rawFile,
    final Map<Object, Object>? youtube,
  }) =>
      youtube == null
          ? _ConfigYoutube(apiKey: '')
          : _ConfigYoutube(
              filePath: filePath,
              rawFile: rawFile,
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
              },
            );

  Future<void> updateApiKey(final String newValue) async =>
      _update(['youtube', 'apiKey'], newValue)
          .whenComplete(() => this.apiKey = newValue);

  Future<void> updateEnablePublishDate(final bool newValue) async =>
      _update(['youtube', 'enablePublishDate'], newValue)
          .whenComplete(() => this.enablePublishDate = newValue);

  Future<void> updateEnableWatchCount(final bool newValue) async =>
      _update(['youtube', 'enableWatchCount'], newValue)
          .whenComplete(() => this.enableWatchCount = newValue);

  Future<void> updateResultPerSearch(final int newValue) async =>
      _update(['youtube', 'resultPerSearch'], newValue)
          .whenComplete(() => this.resultPerSearch = newValue);

  Future<void> updateInfiniteScrollSearch(final bool newValue) async =>
      _update(['youtube', 'infiniteScrollSearch'], newValue)
          .whenComplete(() => this.infiniteScrollSearch = newValue);

  Future<void> updateRegionId(final String newValue) async =>
      _update(['youtube', 'regionId'], newValue)
          .whenComplete(() => this.regionId = newValue);
}

/// Application theme related configuration.
class _ConfigTheme extends YamlConfig {
  _ConfigTheme({
    this.brightness = BrightnessOptions.system,
    this.visualDensity = VisualDensityOptions.standard,
    super.filePath,
    super.rawFile,
  });

  BrightnessOptions brightness;
  VisualDensityOptions visualDensity;

  factory _ConfigTheme.fromMap({
    required final String filePath,
    required final String rawFile,
    final Map<dynamic, dynamic>? theme,
  }) =>
      theme == null
          ? _ConfigTheme()
          : _ConfigTheme(
              filePath: filePath,
              rawFile: rawFile,
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

  Future<void> updateBrightness(final BrightnessOptions newValue) async =>
      _update(['theme', 'brightness'], newValue.name)
          .whenComplete(() => this.brightness = newValue);

  Future<void> updateVisualDensity(final VisualDensityOptions newValue) async =>
      _update(['theme', 'visualDensity'], newValue.name)
          .whenComplete(() => this.visualDensity = newValue);
}

/// History and Saved Playlist related configuration.
class _ConfigHistory extends YamlConfig {
  _ConfigHistory({
    this.pause = false,
    this.size = 2000,
    super.filePath,
    super.rawFile,
  });

  /// Pause history, not receiving any more new playback history.
  bool pause;

  /// Number of history to keep
  int size;

  factory _ConfigHistory.fromMap({
    required final String filePath,
    required final String rawFile,
    final Map<dynamic, dynamic>? history,
  }) =>
      history == null
          ? _ConfigHistory()
          : _ConfigHistory(
              filePath: filePath,
              rawFile: rawFile,
              pause: switch (history['pause']) {
                final bool pause => pause,
                _ => false,
              },
              size: switch (history['size']) {
                final int size => size,
                _ => 2000,
              },
            );

  Future<void> updatePause(final bool newValue) async =>
      _update(['history', 'pause'], newValue)
          .whenComplete(() => this.pause = newValue);

  Future<void> updateSize(final int newValue) async =>
      _update(['history', 'size'], newValue)
          .whenComplete(() => this.size = newValue);
}
