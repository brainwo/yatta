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

class PlayVideo {
  static List<String> _parseCommand(
      final Object fromObject, final String command) {
    late final String url;
    late final String title;
    late final String type;
    late final String icon;

    switch (fromObject) {
      case YoutubeVideo():
        url = fromObject.url;
        title = fromObject.title;
        type = fromObject.kind ?? 'video';
        icon = fromObject.thumbnail.medium.url ?? '';
      case String():
        url = fromObject;
        title = '';
        type = 'url';
        icon = '';
      default:
        throw Exception('Unexpected fromObject type');
    }

    var buff = <String>[''];
    var inQuotationMark = false;
    var dollarSignStack = '';

    final popDollarSignStack = () {
      buff.last += switch (dollarSignStack) {
        '\$url' => url,
        '\$title' => title,
        '\$type' => type,
        '\$icon' => icon,
        final _ => '',
      };
      dollarSignStack = '';
    };

    for (var i = 0; i < command.length; i++) {
      if (dollarSignStack.isNotEmpty) {
        switch (command[i]) {
          case '\$':
          case ' ':
          case '"':
            popDollarSignStack();
          default:
            dollarSignStack += command[i];
            if (i == command.length - 1) {
              popDollarSignStack();
            }
            continue;
        }
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

    print(buff);

    return buff;
  }

  static Future<void> fromUrl(final String url) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList('history', [
      ...?prefs.getStringList('history'),
      // TODO
    ]);

    final commands = prefs.getStringList('video_play_commands');

    if (commands == null) return;

    for (final command in commands) {
      final parsedCommand = _parseCommand(url, command);

      await Process.start(parsedCommand[0], [...parsedCommand.skip(1)]);
    }
  }

  static Future<void> fromYoutubeVideo(final YoutubeVideo youtubeVideo,
      {final bool fromHistory = false}) async {
    final prefs = await SharedPreferences.getInstance();

    if (!fromHistory) {
      await prefs.setStringList('history', [
        ...?prefs.getStringList('history'),
        youtubeVideo.toString(),
      ]);
    }

    final commands = prefs.getStringList('video_play_commands');

    if (commands == null) return;

    for (final command in commands) {
      final parsedCommand = _parseCommand(youtubeVideo, command);

      await Process.start(parsedCommand[0], [...parsedCommand.skip(1)]);
    }
  }
}
