library search_result;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:youtube_api/youtube_api.dart';

import '../helper.dart';
import 'keyboard_navigation.dart';
import 'list_items/list_item.dart';

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
            final youtubeVideo = result[index];
            final title = youtubeVideo.title
                .replaceAll('&amp;', '&')
                .replaceAll('&#39;', '\'')
                .replaceAll('&quot;', '"');

            final listItem = switch (youtubeVideo.kind) {
              'video' => ListItemVideo(
                  title: title,
                  channelTitle: youtubeVideo.channelTitle,
                  description: youtubeVideo.description,
                  duration: youtubeVideo.duration!,
                  thumbnailUrl: youtubeVideo.thumbnail.medium.url,
                  publishedAt: youtubeVideo.publishedAt,
                  timeNow: timeNow,
                ),
              'channel' => ListItemChannel(
                  channelTitle: youtubeVideo.channelTitle,
                  thumbnailUrl: youtubeVideo.thumbnail.medium.url,
                ),
              'playlist' => ListItemPlaylist(
                  title: title,
                  channelTitle: youtubeVideo.channelTitle,
                  description: youtubeVideo.description,
                  thumbnailUrl: youtubeVideo.thumbnail.medium.url,
                ),
              _ => const SizedBox.shrink()
            };

            return ListItem(
                autofocus: index == 0,
                onClick: () async => PlayVideo.fromYoutubeVideo(youtubeVideo),
                url: youtubeVideo.url,
                child: listItem);
          }),
    );
  }
}
