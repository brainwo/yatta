import 'dart:convert';

import 'package:youtube_api/youtube_api.dart';

/// The
class Config {
  // Store
  List<YoutubeVideo> history;

  Config({required this.history});

  Config fromString(final String jsonString) {
    // ignore: unused_local_variable
    final configMap = jsonDecode(jsonString) as Map<String, dynamic>;
    // final List<YoutubeVideo> history = configMap[''] as List<>;
    return Config(history: []);
  }
}
