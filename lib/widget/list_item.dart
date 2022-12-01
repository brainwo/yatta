import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:youtube_api/youtube_api.dart';

import '../helper.dart';
import '../main.dart';
import 'list_item/channel.dart';
import 'list_item/playlist.dart';
import 'list_item/video.dart';

class ListItemController extends ChangeNotifier {
  ListItemController({final int? selected}) : _selected = selected;
  int? get selected => _selected;

  set selected(final int? index) {
    selected = index;
  }

  final int? _selected;
}

class ListItem extends StatefulWidget {
  const ListItem({
    required this.homepage,
    required this.result,
    required this.selected,
    final Key? key,
  }) : super(key: key);

  final HomePage homepage;
  final ValueNotifier<int?> selected;
  final List<YouTubeVideo> result;

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  @override
  Widget build(final BuildContext context) {
    return AnimatedBuilder(
        animation: widget.selected,
        builder: (final BuildContext context, final Widget? child) {
          return SingleChildScrollView(
            controller: widget.homepage.scrollviewController,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...widget.result
                    .asMap()
                    .map((final index, final YouTubeVideo item) {
                      Widget listItem() {
                        switch (item.kind) {
                          case 'video':
                            return ListItemVideo(
                              onClick: () async {
                                if (widget.selected.value == index) {
                                  processVideo(item);
                                }
                                widget.selected.value = index;
                              },
                              title: item.title
                                  .replaceAll('&amp;', '&')
                                  .replaceAll('&#39;', '\'')
                                  .replaceAll('&quot;', '"'),
                              channelTitle: item.channelTitle,
                              description: item.description,
                              duration: item.duration!,
                              thumbnailUrl: item.thumbnail.medium.url,
                            );
                          case 'channel':
                            return ListItemChannel(
                              onClick: () async {
                                if (widget.selected.value == index) {
                                  await Process.run('mpv', [item.url]);
                                }
                                widget.selected.value = index;
                              },
                              channelTitle: item.channelTitle,
                              thumbnailUrl: item.thumbnail.medium.url,
                            );
                          case 'playlist':
                            return ListItemPlaylist(
                              onClick: () async {
                                if (widget.selected.value == index) {
                                  processVideo(item);
                                }
                                widget.selected.value = index;
                              },
                              title: item.title
                                  .replaceAll('&amp;', '&')
                                  .replaceAll('&#39;', '\'')
                                  .replaceAll('&quot;', '"'),
                              channelTitle: item.channelTitle,
                              description: item.description,
                              thumbnailUrl: item.thumbnail.medium.url,
                            );
                          default:
                            debugPrint('${item.kind}');
                            return Container();
                        }
                      }

                      return MapEntry(
                          index,
                          ColoredBox(
                              color: (widget.selected.value == index)
                                  ? const Color.fromRGBO(255, 255, 255, 0.2)
                                  : Colors.transparent,
                              child: listItem()));
                    })
                    .values
                    .toList()
              ],
            ),
          );
        });
  }
}
