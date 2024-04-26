library search_result;

import 'package:autoscroll/autoscroll.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:youtube_api/youtube_api.dart';

import '../helper/command_parser.dart';
import 'keyboard_navigation.dart';
import 'list_items/list_item.dart';

class SearchResult extends StatefulWidget {
  final List<YoutubeVideo> result;
  final void Function() loadMoreCallback;
  final bool nextButtonEnabled;

  const SearchResult({
    required this.result,
    required this.loadMoreCallback,
    required this.nextButtonEnabled,
    final Key? key,
  }) : super(key: key);

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  @override
  Widget build(final BuildContext context) {
    return KeyboardNavigation(
      child: AutoscrollListView.builder(
        itemCount: widget.result.length + 1,
        itemBuilder: (final context, final index) {
          if (index == widget.result.length) {
            return Padding(
              padding: const EdgeInsets.all(8),
              child: Button(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Load more'),
                      if (!widget.nextButtonEnabled) ...[
                        const SizedBox(width: 8),
                        const SizedBox.square(
                          child: ProgressRing(
                            strokeWidth: 2,
                            activeColor: Colors.white,
                            backgroundColor: Colors.transparent,
                          ),
                          dimension: 12,
                        ),
                      ],
                    ],
                  ),
                ),
                onPressed:
                    widget.nextButtonEnabled ? widget.loadMoreCallback : null,
              ),
            );
          }
          final youtubeVideo = widget.result[index];
          final title = youtubeVideo.title.parseHtmlEntities();

          final listItem = switch (youtubeVideo.kind) {
            'video' => ListItemVideo(
                title: title,
                channelTitle: youtubeVideo.channelTitle,
                description: youtubeVideo.description,
                duration: youtubeVideo.duration!,
                thumbnailUrl: youtubeVideo.thumbnail.medium.url,
                publishedAt: youtubeVideo.publishedAt,
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
              youtubeVideo: youtubeVideo,
              child: listItem);
        },
      ),
    );
  }
}
