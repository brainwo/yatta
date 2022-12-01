// ignore: unused_import
import 'dart:convert';
// ignore: unused_import
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:youtube_api/youtube_api.dart';

import 'const.dart';
import 'helper.dart';
import 'string/en_us.dart';
import 'theme.dart';
import 'widget/keyboard_handler.dart';
import 'widget/list_item.dart';

void main() async {
  ValueNotifier<List<YouTubeVideo>> notifier = ValueNotifier(result);

  runApp(AnimatedBuilder(
      animation: notifier,
      builder: (context, widget) {
        return const App();
      }));
}

AppTheme appTheme = AppTheme.archDark();

List<YouTubeVideo> result = [];

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    FocusNode searchBoxFocus = FocusNode();
    FocusNode scrollItemFocus = FocusNode();
    ScrollController scrollviewController = ScrollController();
    ValueNotifier<int?> selectedVideo = ValueNotifier<int?>(null);

    return KeyboardHandler(
      scrollItemFocus: scrollItemFocus,
      searchBoxFocus: searchBoxFocus,
      scrollviewController: scrollviewController,
      selectedVideo: selectedVideo,
      child: FluentApp(
        debugShowCheckedModeBanner: false,
        title: 'Yatta',
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
  final FocusNode searchBoxFocus;

  final ScrollController scrollviewController;
  final ValueNotifier<int?> selectedVideo;
  const HomePage(
      {super.key,
      required this.searchBoxFocus,
      required this.scrollviewController,
      required this.selectedVideo});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum SearchBoxMode { video, playlist, channel, all, play }

class _HomePageState extends State<HomePage> {
  YoutubeAPI ytApi = YoutubeAPI(innerKey);
  String noResultString = AppString.noSearchQuery;
  bool loading = false;
  SearchBoxMode searchBoxMode = SearchBoxMode.all;
  TextEditingController textBoxController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    textBoxController.addListener(() {
      if (searchBoxMode == SearchBoxMode.all) {
        switch (textBoxController.text) {
          case 'v ':
            setState(() {
              searchBoxMode = SearchBoxMode.video;
              textBoxController.text = '';
            });
            break;
          case 'c ':
            setState(() {
              searchBoxMode = SearchBoxMode.channel;
              textBoxController.text = '';
            });
            break;
          case 'p ':
            setState(() {
              searchBoxMode = SearchBoxMode.playlist;
              textBoxController.text = '';
            });
            break;
        }
      }
      if (textBoxController.text.startsWith('https://')) {
        setState(() {
          searchBoxMode = SearchBoxMode.play;
        });
      } else if (searchBoxMode == SearchBoxMode.play) {
        setState(() {
          searchBoxMode = SearchBoxMode.all;
        });
      }
    });

    Widget searchResult = Container(
      color: appTheme.background,
      child: (result.isEmpty)
          ? Container() // TODO: a nice elementaryOS-like welcoming message
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
            if (searchBoxMode != SearchBoxMode.all &&
                searchBoxMode != SearchBoxMode.play)
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: appTheme.primary,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(6.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          '${searchBoxMode.name[0].toUpperCase()}${searchBoxMode.name.substring(1)}'),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                ],
              ),
            Expanded(
              child: KeyboardListener(
                focusNode: FocusNode(onKey: ((node, event) {
                  if (searchBoxMode != SearchBoxMode.all &&
                      searchBoxMode != SearchBoxMode.play &&
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
                  autocorrect: false,
                  autofocus: true,
                  placeholder: (searchBoxMode == SearchBoxMode.all ||
                          searchBoxMode == SearchBoxMode.play)
                      ? AppString.searchPlaceholderAll
                      : AppString.searchPlaceholder,
                  focusNode: widget.searchBoxFocus,
                  controller: textBoxController,
                  onSubmitted: topbarHandler,
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Button(
                  child: Center(
                      child: Icon(searchBoxMode == SearchBoxMode.play
                          ? FluentIcons.play
                          : FluentIcons.search)),
                  onPressed: () {
                    topbarHandler(textBoxController.text);
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
                child: Center(
                    child: ProgressRing(
                  backgroundColor: appTheme.background,
                )),
              ),
            )
        ],
      ),
    );
  }

  void topbarHandler(String query) {
    if (searchBoxMode == SearchBoxMode.play) {
      playVideo(query).then(
        (_) {
          SystemNavigator.pop();
        },
      );
      return;
    }

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
