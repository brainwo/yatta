import 'dart:convert';

import 'package:youtube_api/src/model/thumbnails.dart';

class YoutubeVideo {
  late Thumbnails thumbnail;
  String? kind;
  String? id;
  String? publishedAt;
  String? channelId;
  String? channelUrl;
  late String title;
  String? description;
  late String channelTitle;
  late String url;
  String? duration;
  late dynamic _data;

  YoutubeVideo(dynamic data, {bool getTrendingVideo = false}) {
    thumbnail = Thumbnails.fromMap(data['snippet']['thumbnails']);
    if (getTrendingVideo) {
      kind = 'video';
      id = data['id'];
    } else {
      kind = data['id']['kind'].substring(8);
      id = data['id'][data['id'].keys.elementAt(1)];
    }
    url = getUrl(kind!, id!);
    publishedAt = data['snippet']['publishedAt'];
    channelId = data['snippet']['channelId'];
    channelUrl = "https://www.youtube.com/channel/$channelId";
    title = data['snippet']['title'];
    description = data['snippet']['description'];
    channelTitle = data['snippet']['channelTitle'];
    if (data['duration'] != null) {
      duration = data['duration'];
    }
    _data = data;
  }

  static YoutubeVideo fromString(String data) {
    return YoutubeVideo(jsonDecode(data));
  }

  String getUrl(String kind, String id) {
    String baseURL = "https://www.youtube.com/";
    switch (kind) {
      case 'channel':
        return "${baseURL}channel/$id";
      case 'video':
        return "${baseURL}watch?v=$id";
      case 'playlist':
        return "${baseURL}playlist?list=$id";
    }
    return baseURL;
  }

  String toString() => jsonEncode({
        ...this._data as Map<String, dynamic>,
        'duration': this.duration,
      });
}
