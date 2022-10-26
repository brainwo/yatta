import 'dart:io';

import 'package:flutter/services.dart';
import 'package:youtube_api/youtube_api.dart';

void playVideo(YouTubeVideo item) async {
  // ignore: unused_local_variable
  var process = await Process.start('xwinwrap', [
    '-ov',
    '-g',
    '1920x1080+0+0',
    '--',
    'mpv',
    '-wid',
    'WID',
    '--profile=wallpaper',
    item.url
  ]);

  SystemNavigator.pop();
}
