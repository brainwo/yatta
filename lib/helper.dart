import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:youtube_api/youtube_api.dart';

Future<void> playVideo(final String url) async {
  // ignore: unused_local_variable
  final Process process = await Process.start('xwinwrap', [
    '-ov',
    '-g',
    '1920x1080+0+0',
    '--',
    'mpv',
    '-wid',
    'WID',
    '--profile=wallpaper',
    '--input-ipc-server=/tmp/mpvsocket',
    url
  ]);

  await Process.start('kitty', [
    '@',
    '--to=unix:/tmp/mykitty',
    'set-colors',
    '-a',
    'background=#1f1f1f',
  ]);
}

Future<void> processVideo(final YouTubeVideo item) async {
  await playVideo(item.url);

  // final List<Map<String, dynamic>> entry = [
  // {
  // 'id': {
  // if (item.id != null) 'id': item.id,
  // if (item.kind != null) 'kind': item.kind,
  // },
  // 'snippet': {
  // 'channelTitle': item.channelTitle,
  // if (item.description != null) 'description': item.description,
  // 'title': item.title,
  // if (item.publishedAt != null) 'publishedAt': item.publishedAt,
  // if (item.channelId != null) 'channelId': item.channelId,
  // }
  // }
  // ];

  // TODO: load data.json
  // var file = File('data.json');
  // if (await file.exists()) {
  // List<Map<String, dynamic>> previousData =
  // jsonDecode(await file.readAsString());
  // previousData.addAll(entry);
  // await file
  // .writeAsString(jsonEncode(previousData))
  // .whenComplete(() => SystemNavigator.pop());
  // } else {
  // await file
  // .writeAsString(jsonEncode(entry))
  // .whenComplete(() => SystemNavigator.pop());
  // }

  await SystemNavigator.pop();
}
