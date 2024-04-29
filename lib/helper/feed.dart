import 'dart:io';

import 'package:collection/collection.dart';
import 'package:xdg_directories/xdg_directories.dart' as xdg;
import 'package:yaml_edit/yaml_edit.dart';

import '../const.dart';

Future<String> loadFeedList() async =>
    await feedPathLookup
        .map((final path) => File('${xdg.configHome.path}$path'))
        .firstWhereOrNull((final feedLookup) => feedLookup.existsSync())
        ?.readAsString() ??
    '';

Future<void> updateFeedList(
    final String feedList, final List<String> newFeedList) async {
  final yamlEditor = YamlEditor(feedList)..update([], newFeedList);
  final rawFile = yamlEditor.toString();

  final file = feedPathLookup
      .map((final path) => File('${xdg.configHome.path}$path'))
      .firstWhereOrNull((final feedLookup) => feedLookup.existsSync());
  if (file == null) {
    await File('${xdg.configHome.path}${feedPathLookup[0]}')
        .writeAsString(rawFile);
    return;
  }

  await file.writeAsString(rawFile);
}
