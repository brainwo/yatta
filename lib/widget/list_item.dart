import 'package:fluent_ui/fluent_ui.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:ythacker/widget/list_item/playlist.dart';
import 'dart:io';

import '../helper.dart';
import '../main.dart';
import 'list_item/video.dart';
import 'list_item/channel.dart';

class ListItemController extends ChangeNotifier {
  ListItemController({int? selected}) : _selected = selected;
  int? get selected => _selected;

  set selected(int? index) {
    selected = index;
  }

  final int? _selected;
}

class ListItem extends StatefulWidget {
  const ListItem({
    Key? key,
    required this.homepage,
    required this.result,
    required this.selected,
  }) : super(key: key);

  final HomePage homepage;
  final ValueNotifier<int?> selected;
  final List<YouTubeVideo> result;


  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: widget.selected,
        builder: (BuildContext context, Widget? child) {
          return SingleChildScrollView(
            controller: widget.homepage.scrollviewController,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...widget.result
                    .asMap()
                    .map((index, YouTubeVideo item) {
                      Widget listItem() {
                        switch (item.kind) {
                          case 'video':
                            return ListItemVideo(
                              onClick: () async {
                                if (widget.selected.value == index) {
                                  playVideo(item);
                                }
                                widget.selected.value = index;
                              },
                              title: item.title,
                              channelTitle: item.channelTitle,
                              description: item.description!,
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
                                  playVideo(item);
                                }
                                widget.selected.value = index;
                              },
                              title: item.title,
                              channelTitle: item.channelTitle,
                              description: item.description!,
                              thumbnailUrl: item.thumbnail.medium.url,
                            );
                          default:
                            debugPrint('${item.kind}');
                            return Container();
                        }
                      }

                      return MapEntry(
                          index,
                          Container(
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
