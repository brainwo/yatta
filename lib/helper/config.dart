import 'dart:io';

import 'package:collection/collection.dart';
import 'package:xdg_directories/xdg_directories.dart';
import 'package:yaml/yaml.dart';

import '../model/config.dart';

const List<String> configPathLookup = [
  '/yatta/config.yaml',
  '/yatta/config.yml',
  '/yatta/config.json',
];

/// Replacement for SharedPreferences
class Configuration {
  Future<ConfigSchema> loadSchema() async =>
      await configPathLookup
          .map((final path) => File('${configHome.path}$path'))
          .firstWhereOrNull((final file) => file.existsSync())
          ?.readAsString()
          .then((final yaml) => ConfigSchema.fromJson(loadYaml(yaml))) ??
      ConfigSchema.defaultConfig();
}
