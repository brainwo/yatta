import 'dart:collection';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_api/youtube_api.dart';

import '../model/config.dart';
import '../model/database.dart';

List<String> _defaultData(final Object fromObject, final String command) {
  late final String url;
  late final String title;
  late final String description;
  late final String type;
  late final String preview;
  late final String thumbnail;
  late final String icon;

  switch (fromObject) {
    case YoutubeVideo():
      url = fromObject.url;
      title = fromObject.title;
      description = fromObject.description ?? '';
      type = fromObject.kind ?? 'video';
      preview = fromObject.thumbnail.high.url ?? '';
      thumbnail = fromObject.thumbnail.medium.url ?? '';
      icon = fromObject.thumbnail.small.url ?? '';
    case HistoryModel():
      url = fromObject.url;
      title = fromObject.title;
      description = fromObject.description;
      type = fromObject.type.name;
      preview = fromObject.previewUrl;
      thumbnail = fromObject.thumbnailUrl;
      icon = fromObject.iconUrl;
    case String():
      url = fromObject;
      title = '';
      description = '';
      type = 'url';
      preview = '';
      thumbnail = '';
      icon = '';
    default:
      throw Exception('Unexpected fromObject type');
  }

  return parseCommand(command,
      url: url,
      title: title,
      description: description,
      type: type,
      preview: preview,
      thumbnail: thumbnail,
      icon: icon);
}

Future<void> playFromHistory(
  final HistoryModel history, {
  final PlayMode mode = PlayMode.play,
}) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setStringList('history', [
    ...?prefs.getStringList('history'),
    // TODO
  ]);

  final config = await UserConfig.load();

  final commands = switch (mode) {
    PlayMode.play => config.videoPlayCommand,
    PlayMode.listen => config.videoListenCommand,
  };

  if (commands == null) return;

  for (final command in commands) {
    final parsedCommand = _defaultData(history, command);

    await Process.start(
      parsedCommand[0],
      [...parsedCommand.skip(1)],
      mode: ProcessStartMode.detached,
    );
  }
}

Future<void> playFromUrl(
  final String url, {
  final PlayMode mode = PlayMode.play,
}) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setStringList('history', [
    ...?prefs.getStringList('history'),
    // TODO
  ]);

  final config = await UserConfig.load();

  final commands = switch (mode) {
    PlayMode.play => config.videoPlayCommand,
    PlayMode.listen => config.videoListenCommand,
  };

  if (commands == null) return;

  for (final command in commands) {
    final parsedCommand = _defaultData(url, command);

    await Process.start(
      parsedCommand[0],
      [...parsedCommand.skip(1)],
      mode: ProcessStartMode.detached,
    );
  }
}

enum PlayMode { play, listen }

Future<void> playFromYoutubeVideo(
  final YoutubeVideo youtubeVideo, {
  final bool fromHistory = false,
  final PlayMode mode = PlayMode.play,
}) async {
  final prefs = await SharedPreferences.getInstance();

  if (!fromHistory && (prefs.getBool('enable_history') ?? true)) {
    final historyQueue = Queue.of(
      prefs.getStringList('history') ?? <String>[],
    );

    if (historyQueue.length >= (prefs.getInt('history_to_keep') ?? 200)) {
      historyQueue.removeFirst();
    }
    historyQueue.add(youtubeVideo.toString());

    await prefs.setStringList('history', historyQueue.toList());
  }

  final config = await UserConfig.load();

  final commands = switch (mode) {
    PlayMode.play => config.videoPlayCommand,
    PlayMode.listen => config.videoListenCommand,
  };

  if (commands == null) return;

  for (final command in commands) {
    final parsedCommand = _defaultData(youtubeVideo, command);

    await Process.start(
      parsedCommand[0],
      [...parsedCommand.skip(1)],
      mode: ProcessStartMode.detached,
    );
  }
}

List<String> parseCommand(
  final String command, {
  final String url = '',
  final String title = '',
  final String description = '',
  final String type = '',
  final String preview = '',
  final String thumbnail = '',
  final String icon = '',
}) {
  var buff = <String>[''];
  var inQuotationMark = false;
  var dollarSignStack = '';

  final popDollarSignStack = () {
    buff.last += switch (dollarSignStack) {
      '\$url' => url,
      '\$title' => title,
      '\$description' => description,
      '\$type' => type,
      '\$preview' => preview,
      '\$thumbnail' => thumbnail,
      '\$icon' => icon,
      final _ => '',
    };
    dollarSignStack = '';
  };

  const englishAlphabet =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

  for (var i = 0; i < command.length; i++) {
    if (dollarSignStack.isNotEmpty) {
      if (englishAlphabet.contains(command[i])) {
        dollarSignStack += command[i];

        final isLastCharacter = i == command.length - 1;
        if (isLastCharacter) popDollarSignStack();

        continue;
      }
      popDollarSignStack();
    }

    if (command[i] == '\$') {
      dollarSignStack += '\$';
      continue;
    }

    if (command[i] == ' ' && !inQuotationMark) {
      buff = [...buff, ''];
      continue;
    }

    if (command[i] == '"') {
      inQuotationMark = !inQuotationMark;
      continue;
    }

    buff.last += command[i];
  }
  if (buff.last == '') buff = buff.take(buff.length - 1).toList();
  return buff;
}

extension HtmlCharacterEntitiesParsing on String {
  String parseHtmlEntities() {
    return this.replaceAllMapped(
      RegExp(r'&(#?)([a-zA-Z0-9]+?);'),
      (final match) {
        return switch (match[0]) {
          '&amp;' => '&',
          '&#39;' => "'",
          '&quot;' => '"',
          _ => '',
        };
      },
    );
  }
}
