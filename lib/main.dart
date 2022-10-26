// ignore: unused_import
import 'dart:convert';
// ignore: unused_import
import 'dart:io';

import 'package:flutter/services.dart';
import 'helper.dart';
import 'theme.dart';

import 'widget/list_item.dart';

import 'string/en_us.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:youtube_api/youtube_api.dart';
import 'const.dart';

List<YouTubeVideo> result = [];
AppTheme appTheme = AppTheme.archDark();

void main() async {
  ValueNotifier<List<YouTubeVideo>> notifier = ValueNotifier(result);

  // File config = File('~/.config/ythacker/config.json');

  // if (await config.exists()) {
  // config.readAsString();
  // } else {
  // config.create(recursive: true);
  // }

  // File file = File('data.json');
  // if (await file.exists()) {
  // String fileAsString = await file.readAsString();
  // List<dynamic> data = jsonDecode(fileAsString);
  // result = data.map((item) => YouTubeVideo(item)).toList();
  // debugPrint('$result');
  // notifier.value = result;
  // } else {
  // debugPrint('Create new data');
  // }

  runApp(AnimatedBuilder(
      animation: notifier,
      builder: (context, widget) {
        return const App();
      }));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    FocusNode searchBoxFocus = FocusNode();
    FocusNode scrollItemFocus = FocusNode();
    ScrollController scrollviewController = ScrollController();
    ValueNotifier<int?> selectedVideo = ValueNotifier<int?>(null);

    return KeyboardListener(
      focusNode: FocusNode(onKey: (node, event) {
        debugPrint(event.logicalKey.keyLabel);
        switch (event.logicalKey.keyLabel) {
          case 'Tab':
            node.requestFocus(scrollItemFocus);
            return KeyEventResult.handled;
          case '/':
            node.requestFocus(searchBoxFocus);
            return KeyEventResult.handled;
          case 'Home':
          case 'Page Up':
            debugPrint('${scrollviewController.positions}');
            scrollviewController.jumpTo(0.0);
            return KeyEventResult.handled;
          case 'End':
          case 'Page Down':
            debugPrint('${scrollviewController.positions}');
            scrollviewController
                .jumpTo(scrollviewController.position.maxScrollExtent);
            return KeyEventResult.handled;
          case 'J':
            if (!searchBoxFocus.hasFocus &&
                scrollviewController.positions.isNotEmpty) {
              scrollviewController
                  .jumpTo(scrollviewController.offset + scrollAmount);
              if (event.isKeyPressed(LogicalKeyboardKey.keyJ) &&
                      ((selectedVideo.value ?? 0) < 9) ||
                  selectedVideo.value == null) {
                selectedVideo.value = (selectedVideo.value ?? -1) + 1;
              }
              return KeyEventResult.handled;
            }
            break;
          case 'K':
            if (!searchBoxFocus.hasFocus &&
                scrollviewController.positions.isNotEmpty) {
              scrollviewController
                  .jumpTo(scrollviewController.offset - scrollAmount);
              if (event.isKeyPressed(LogicalKeyboardKey.keyK) &&
                  (selectedVideo.value ?? -1) > 0) {
                selectedVideo.value = (selectedVideo.value ?? 1) - 1;
              }
              return KeyEventResult.handled;
            }
            break;
        }
        if (event.isKeyPressed(LogicalKeyboardKey.enter) && result.isNotEmpty) {
          playVideo(result[selectedVideo.value!]);
        }
        return KeyEventResult.skipRemainingHandlers;
      }),
      child: FluentApp(
        title: 'YT Hacker',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: appTheme.background,
          micaBackgroundColor: appTheme.background,
          activeColor: appTheme.primary,
        ),
        home: HomePage(
          searchBoxFocus: searchBoxFocus,
          scrollviewController: scrollviewController,
          selectedVideo: selectedVideo,
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage(
      {super.key,
      required this.searchBoxFocus,
      required this.scrollviewController,
      required this.selectedVideo});

  final FocusNode searchBoxFocus;
  final ScrollController scrollviewController;
  final ValueNotifier<int?> selectedVideo;

  @override
  State<HomePage> createState() => _HomePageState();
}

enum SearchBoxMode { video, playlist, channel, all }

class _HomePageState extends State<HomePage> {
  YoutubeAPI ytApi = YoutubeAPI(innerKey);
  String noResultString = AppString.noSearchQuery;
  bool loading = false;
  SearchBoxMode searchBoxMode = SearchBoxMode.all;

  @override
  Widget build(BuildContext context) {
    TextEditingController textBoxController = TextEditingController();

    textBoxController.addListener(() {
      if (searchBoxMode == SearchBoxMode.all) {
        switch (textBoxController.text) {
          case 'v ':
            setState(() {
              searchBoxMode = SearchBoxMode.video;
            });
            break;
          case 'c ':
            setState(() {
              searchBoxMode = SearchBoxMode.channel;
            });
            break;
          case 'p ':
            setState(() {
              searchBoxMode = SearchBoxMode.playlist;
            });
            break;
        }
      }
    });

    Widget searchResult = Container(
        color: appTheme.background,
        child: (result.isEmpty)
            ? Center(child: Text(noResultString))
            : ListItem(
                homepage: widget,
                result: result,
                selected: widget.selectedVideo));

    return NavigationView(
      appBar: NavigationAppBar(
        backgroundColor: appTheme.backgroundDarker,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            if (searchBoxMode != SearchBoxMode.all)
              Row(
                children: [
                  Text(
                      '${searchBoxMode.name[0].toUpperCase()}${searchBoxMode.name.substring(1)}'),
                  const SizedBox(width: 8.0),
                ],
              ),
            Expanded(
              child: TextBox(
                placeholder: searchBoxMode == SearchBoxMode.all ? AppString.searchPlaceholderAll : AppString.searchPlaceholder,
                focusNode: widget.searchBoxFocus,
                controller: textBoxController,
                onSubmitted: (query) {
                  setState(() {
                    loading = true;
                  });
                  ytApi
                      .search(query,
                          type: searchBoxMode == SearchBoxMode.all
                              ? 'video,channel,playlist'
                              : searchBoxMode.name)
                      .then((value) {
                    setState(() {
                      result = value;
                      loading = false;
                    });
                  }, onError: (err) {
                    setState(() {
                      noResultString = '${AppString.errorInformation}$err';
                      loading = false;
                    });
                  });
                },
              ),
            ),
          ],
        ),
      ),
      content: Stack(
        children: [
          searchResult,
          if (loading)
            SizedBox.expand(
              child: Container(
                color: const Color.fromRGBO(0, 0, 0, 0.5),
                child: const Center(child: ProgressRing()),
              ),
            )
        ],
      ),
    );
  }
}
