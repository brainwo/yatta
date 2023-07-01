import 'dart:collection';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_api/youtube_api.dart';

/// Used to calculate YouTube video age
/// Returns [String]
/// ```dart
/// timeSince(DateTime., DateTime.now());
/// ```
String timeSince(final DateTime startTime, final DateTime endTime) {
  final duration = startTime.difference(endTime);

  const daysInYear = 365.25; // Average days in a year
  const daysInMonth = 30.4375; // Average days in a month
  const daysInWeek = 7;

  final days = duration.inDays.abs();
  final hours = duration.inHours.abs();
  final minutes = duration.inMinutes.abs();
  final seconds = duration.inSeconds.abs();

  var buff = '';

  if (!duration.isNegative) {
    buff += 'in ';
  }

  if (days >= daysInYear * 2) {
    buff += '${(days / daysInYear).floor()} years';
  } else if (days >= daysInYear) {
    buff += '1 year';
  } else if (days >= daysInMonth * 2) {
    buff += '${(days / daysInMonth).floor()} months';
  } else if (days >= daysInMonth) {
    buff += '1 month';
  } else if (days >= daysInWeek * 2) {
    buff += '${(days / daysInWeek).floor()} weeks';
  } else if (days >= daysInWeek) {
    buff += '1 week';
  } else if (days >= 2) {
    buff += '$days days';
  } else if (days == 1) {
    buff += '1 day';
  } else if (hours >= 2) {
    buff += '$hours hours';
  } else if (hours == 1) {
    buff += '$hours hour';
  } else if (minutes >= 2) {
    buff += '$minutes minutes';
  } else if (minutes == 1) {
    buff += '1 minute';
  } else if (seconds >= 2) {
    buff += '$seconds seconds';
  } else if (seconds == 1) {
    buff += '1 second';
  } else {
    buff += 'less than a second';
  }

  if (duration.isNegative) {
    buff += ' ago';
  }

  return buff;
}

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

Future<void> playFromUrl(final String url) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setStringList('history', [
    ...?prefs.getStringList('history'),
    // TODO
  ]);

  final commands = prefs.getStringList('video_play_commands');

  if (commands == null) return;

  for (final command in commands) {
    final parsedCommand = _defaultData(url, command);

    await Process.start(parsedCommand[0], [...parsedCommand.skip(1)]);
  }
}

Future<void> playFromYoutubeVideo(final YoutubeVideo youtubeVideo,
    {final bool fromHistory = false}) async {
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

  final commands = prefs.getStringList('video_play_commands');

  if (commands == null) return;

  for (final command in commands) {
    final parsedCommand = _defaultData(youtubeVideo, command);

    await Process.start(parsedCommand[0], [...parsedCommand.skip(1)]);
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
