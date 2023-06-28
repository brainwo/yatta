library search_result;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:youtube_api/youtube_api.dart';

import '../helper.dart';
import '../locale/en_us.dart';
import 'keyboard_navigation.dart';

part 'list_items/list_item.dart';
part 'list_items/channel.dart';
part 'list_items/playlist.dart';
part 'list_items/video.dart';

class SearchResult extends StatelessWidget {
  const SearchResult({
    required this.result,
    final Key? key,
  }) : super(key: key);

  final List<YoutubeVideo> result;
  static final timeNow = DateTime.now();

  @override
  Widget build(final BuildContext context) {
    return KeyboardNavigation(
      child: ListView.builder(
          itemCount: result.length,
          itemBuilder: (final context, final index) {
            final item = result[index];
            final title = item.title
                .replaceAll('&amp;', '&')
                .replaceAll('&#39;', '\'')
                .replaceAll('&quot;', '"');

            final listItem = switch (item.kind) {
              'video' => _ListItemVideo(
                  title: title,
                  channelTitle: item.channelTitle,
                  description: item.description,
                  duration: item.duration!,
                  thumbnailUrl: item.thumbnail.medium.url,
                  publishedAt: item.publishedAt,
                  timeNow: timeNow,
                ),
              'channel' => _ListItemChannel(
                  channelTitle: item.channelTitle,
                  thumbnailUrl: item.thumbnail.medium.url,
                ),
              'playlist' => _ListItemPlaylist(
                  title: title,
                  channelTitle: item.channelTitle,
                  description: item.description,
                  thumbnailUrl: item.thumbnail.medium.url,
                ),
              _ => const SizedBox.shrink()
            };

            return _ListItem(
                autofocus: index == 0,
                onClick: () async => playYouTubeVideo(item),
                url: item.url,
                child: listItem);
          }),
    );
  }
}
