import 'dart:io';

import 'package:flutter/services.dart';
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

/// Play video from a given [String] of url
Future<void> playVideoFromUrl(final String url) async {
  final prefs = await SharedPreferences.getInstance();

  final commands = prefs.getStringList('video_play_commands');

  if (commands == null) return;

  for (final command in commands) {
    final parsedCommand = command.split(' ').map((final e) {
      if (e == '\$url') return url;
      return e;
    }).toList();

    await Process.start(parsedCommand[0], [...parsedCommand.skip(1)]);
  }
}

Future<void> playYouTubeVideo(final YoutubeVideo youtubeVideo) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setStringList('history', [
    ...?prefs.getStringList('history'),
    youtubeVideo.toString(),
  ]);

  final commands = prefs.getStringList('video_play_commands');

  if (commands == null) return;

  for (final command in commands) {
    final parsedCommand = command.split(' ').map((final e) {
      return switch (e) {
        '\$url' => youtubeVideo.url,
        '\$title' => '"${youtubeVideo.title}"',
        final e => e
      };
    }).toList();

    await Process.start(parsedCommand[0], [...parsedCommand.skip(1)]);
  }

  // await SystemNavigator.pop();
}
