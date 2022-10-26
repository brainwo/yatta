import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:ythacker/helper.dart';

import 'widget/list_item.dart';

import 'theme/arc_dark.dart';
import 'string/en_us.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:youtube_api/youtube_api.dart';
import 'const.dart';

List<YouTubeVideo> result = [];

void main() async {
  ValueNotifier<List<YouTubeVideo>> notifier = ValueNotifier(result);

  File file = File('data.json');
  if (await file.exists()) {
    String fileAsString = await file.readAsString();
    List<dynamic> data = jsonDecode(fileAsString);
    // result = data.map((item) => YouTubeVideo(item)).toList();
    debugPrint('$result');
    notifier.value = result;
  } else {
    debugPrint('awia');
  }

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
          scaffoldBackgroundColor: AppTheme.background,
          micaBackgroundColor: AppTheme.background,
          activeColor: AppTheme.primary,
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

class _HomePageState extends State<HomePage> {
  YoutubeAPI ytApi = YoutubeAPI(innerKey);
  String noResultString = AppString.noSearchQuery;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    TextEditingController textBoxController = TextEditingController();

    Widget searchResult = Container(
        color: AppTheme.background,
        child: (result.isEmpty)
            ? Center(child: Text(noResultString))
            : ListItem(
                homepage: widget,
                result: result,
                selected: widget.selectedVideo));

    return NavigationView(
      appBar: NavigationAppBar(
        backgroundColor: AppTheme.backgroundDarker,
        automaticallyImplyLeading: false,
        title: TextBox(
          placeholder: AppString.searchPlaceholder,
          focusNode: widget.searchBoxFocus,
          controller: textBoxController,
          onSubmitted: (query) {
            setState(() {
              loading = true;
            });
            ytApi.search(query, type: 'playlist').then((value) {
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
