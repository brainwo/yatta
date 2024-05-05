import 'dart:io';

// import 'package:csv/csv.dart';
// import 'package:csv/csv.dart';
// import 'package:fast_csv/csv_parser.dart';
import 'package:xdg_directories/xdg_directories.dart' as xdg;

import '../util/csv_parser.dart';

enum ItemType {
  video,
  playlist,
  channel,
}

class HistoryDatabase {
  const HistoryDatabase({required this.history});

  final List<HistoryModel> history;

  static Future<HistoryDatabase> load({final int? limit}) async {
    final file = File('${xdg.dataHome.path}/yatta/history.csv');
    return HistoryDatabase(
        history: const CsvParser()
            .parse(await file.readAsLines())
            .map((final e) => switch (e) {
                  {
                    'id': final String id,
                    'type': final String type,
                    'provider': final String provider,
                    'title': final String title,
                    'description': final String description,
                    'url': final String url,
                    'viewCount': final String viewCount,
                    'channelId': final String channelId,
                    'channelTitle': final String channelTitle,
                    'iconUrl': final String iconUrl,
                    'thumbnailUrl': final String thumbnailUrl,
                    'previewUrl': final String previewUrl,
                    'publishDate': final String publishDate,
                    'duration': _,
                    'romanizedMetadata': final String romanizedMetadata,
                    'history': final String history,
                  } =>
                    HistoryModel(
                      id: id,
                      title: title,
                      description: description,
                      duration: Duration.zero,
                      romanizedMetadata: romanizedMetadata,
                      publishDate: publishDate,
                      type: switch (type) {
                        'video' => ItemType.video,
                        'playlist' => ItemType.playlist,
                        'channel' => ItemType.channel,
                        _ => ItemType.video,
                      },
                      history: history.split(','),
                      channelId: channelId,
                      iconUrl: iconUrl,
                      thumbnailUrl: thumbnailUrl,
                      previewUrl: previewUrl,
                      provider: provider,
                      channelTitle: channelTitle,
                      url: url,
                      viewCount: int.tryParse(viewCount),
                    ),
                  _ => throw UnimplementedError(),
                })
            .toList());
  }
}

class HistoryModel {
  const HistoryModel({
    required this.id,
    required this.title,
    required this.duration,
    required this.description,
    required this.romanizedMetadata,
    required this.publishDate,
    required this.type,
    required this.history,
    required this.channelId,
    required this.iconUrl,
    required this.thumbnailUrl,
    required this.previewUrl,
    required this.provider,
    required this.channelTitle,
    required this.url,
    required this.viewCount,
  });

  /// Can be video id or playlist id
  final String id;

  final ItemType type;

  /// Video site (e.g. "youtube")
  final String provider;

  final String title;
  final String description;
  final String url;
  final int? viewCount;

  /// Channel name
  final String channelTitle;
  final String channelId;

  /// Cover image < 120px width
  final String iconUrl;

  /// Cover image < 32px width
  final String thumbnailUrl;

  /// Cover image < 48px width
  final String previewUrl;

  /// ISO 8601 format time
  final String publishDate;
  final Duration duration;

  /// ISO 8601 format time
  final List<String> history;

  /// Search friendly string
  final String romanizedMetadata;
}
