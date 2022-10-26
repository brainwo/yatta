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
  // String fileAsString = await file.readAsString()
  Widget build(BuildContext context) {
    FocusNode searchBoxFocus = FocusNode();
    FocusNode scrollItemFocus = FocusNode();
    ScrollController scrollviewController = ScrollController();
    ValueNotifier<int?> selectedVideo = ValueNotifier<int?>(null);

    return KeyboardListener(
      focusNode: FocusNode(onKey: (node, event) {
        switch (event.logicalKey.keyLabel) {
          case 'Tab':
            node.requestFocus(scrollItemFocus);
            return KeyEventResult.handled;
          case '/':
            if (!searchBoxFocus.hasFocus) {
              node.requestFocus(searchBoxFocus);
              return KeyEventResult.handled;
            }
            break;
          case 'Home':
          case 'Page Up':
            scrollviewController.jumpTo(0.0);
            return KeyEventResult.handled;
          case 'End':
          case 'Page Down':
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
        return KeyEventResult.ignored;
      }),
      child: FluentApp(
        debugShowCheckedModeBanner: false,
        title: 'YT Hacker',
        theme: ThemeData(
          brightness: Brightness.dark,
          accentColor: appTheme.primary.toAccentColor(),
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
              selected: widget.selectedVideo,
            ),
    );

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
              child: KeyboardListener(
                focusNode: FocusNode(onKey: ((node, event) {
                  if (searchBoxMode != SearchBoxMode.all &&
                      event.isKeyPressed(LogicalKeyboardKey.backspace) &&
                      textBoxController.text == '') {
                    setState(() {
                      searchBoxMode = SearchBoxMode.all;
                    });
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                })),
                child: TextBox(
                  // foregroundDecoration: BoxDecoration(
                  // border: Border.all(width: 1.0),
                  // ),
                  autocorrect: false,
                  placeholder: searchBoxMode == SearchBoxMode.all
                      ? AppString.searchPlaceholderAll
                      : AppString.searchPlaceholder,
                  focusNode: widget.searchBoxFocus,
                  controller: textBoxController,
                  onSubmitted: searchHandler,
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Button(
                  child: const Center(child: Icon(FluentIcons.search)),
                  onPressed: () {
                    searchHandler(textBoxController.text);
                  }),
            )
          ],
        ),
      ),
      content: Stack(
        children: [
          searchResult,
          if (loading)
            SizedBox.expand(
              child: Container(
                color: appTheme.backgroundDarker.withOpacity(0.5),
                child: const Center(child: ProgressRing()),
              ),
            )
        ],
      ),
    );
  }

  void searchHandler(String query) {
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
  }
}
