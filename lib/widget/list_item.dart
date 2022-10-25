import 'package:fluent_ui/fluent_ui.dart';
import 'package:youtube_api/youtube_api.dart';
import 'dart:io';

import '../main.dart';
import 'list_item/video.dart';
import 'list_item/channel.dart';

class ListItem extends StatefulWidget {
  const ListItem({
    Key? key,
    required this.homepage,
    required this.result,
  }) : super(key: key);

  final HomePage homepage;
  final List<YouTubeVideo> result;

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  int? selected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.homepage.scrollviewController,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...widget.result
              .asMap()
              .map((index, item) {
                Widget listItem() {
                  switch (item.kind) {
                    case 'video':
                      return ListItemVideo(
                        onClick: () async {
                          if (selected == index) {
                            await Process.run("mpv", [item.url]);
                          }
                          setState(() {
                            selected = index;
                          });
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
                          if (selected == index) {
                            await Process.run("mpv", [item.url]);
                          }
                          setState(() {
                            selected = index;
                          });
                        },
                        channelTitle: item.channelTitle,
                        thumbnailUrl: item.thumbnail.medium.url,
                      );
                    default:
                      debugPrint("${item.kind}");
                      return Container();
                  }
                }

                return MapEntry(
                    index,
                    Container(
                        color: (selected == index)
                            ? const Color.fromRGBO(255, 255, 255, 0.2)
                            : Colors.transparent,
                        child: listItem()));
              })
              .values
              .toList()
        ],
      ),
    );
  }
}
