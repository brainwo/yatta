// ignore: unused_import
import 'dart:convert';
// ignore: unused_import
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:youtube_api/youtube_api.dart';

import 'const.dart';
import 'helper.dart';
import 'i18n//en_us.dart';
import 'theme.dart';
import 'widget/keyboard_handler.dart';
import 'widget/list_item.dart';
import 'widget/welcome_message.dart';

void main() async {
  final ValueNotifier<List<YouTubeVideo>> notifier = ValueNotifier(result);

  runApp(AnimatedBuilder(
      animation: notifier,
      builder: (final context, final widget) {
        return const App();
      }));
}

AppTheme appTheme = AppTheme.archDark();

List<YouTubeVideo> result = [];

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(final BuildContext context) {
    final FocusNode searchBoxFocus = FocusNode();
    final FocusNode scrollItemFocus = FocusNode();
    final ScrollController scrollviewController = ScrollController();
    final ValueNotifier<int?> selectedVideo = ValueNotifier<int?>(null);

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
  const HomePage({
    required this.searchBoxFocus,
    required this.scrollviewController,
    required this.selectedVideo,
    super.key,
  });

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
  Widget build(final BuildContext context) {
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

    final Widget searchResult = ColoredBox(
      color: appTheme.background,
      child: (result.isEmpty)
          ? const WelcomeMessage()
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
                focusNode: FocusNode(onKey: (final node, final event) {
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
                }),
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
              child: ColoredBox(
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

  void topbarHandler(final String query) {
    if (searchBoxMode == SearchBoxMode.play) {
      playVideo(query).then(
        (final _) {
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
        .then((final value) {
      setState(() {
        result = value;
        loading = false;
      });
    }, onError: (final dynamic err) {
      setState(() {
        noResultString = '${AppString.errorInformation}$err';
        loading = false;
      });
    });
  }
}
