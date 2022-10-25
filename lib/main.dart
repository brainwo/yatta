import 'widget/list_item.dart';

import 'theme/arc_dark.dart';
import 'string/en_us.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:youtube_api/youtube_api.dart';
import 'const.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    FocusNode searchBoxFocus = FocusNode();
    FocusNode scrollItemFocus = FocusNode();
    ScrollController scrollviewController = ScrollController();

    return KeyboardListener(
      focusNode: FocusNode(onKey: (node, event) {
        debugPrint(event.logicalKey.keyLabel);
        switch (event.logicalKey.keyLabel) {
          case "Tab":
            node.requestFocus(scrollItemFocus);
            return KeyEventResult.handled;
          case "/":
            node.requestFocus(searchBoxFocus);
            return KeyEventResult.handled;
          case "Home":
          case "Page Up":
            debugPrint("${scrollviewController.positions}");
            scrollviewController.jumpTo(0.0);
            return KeyEventResult.handled;
          case "End":
          case "Page Down":
            debugPrint("${scrollviewController.positions}");
            scrollviewController
                .jumpTo(scrollviewController.position.maxScrollExtent);
            return KeyEventResult.handled;
          case "J":
            if (!searchBoxFocus.hasFocus && scrollviewController.positions.isNotEmpty) {
              scrollviewController
                  .jumpTo(scrollviewController.offset + scrollAmount);
              return KeyEventResult.handled;
            }
            break;
          case "K":
            if (!searchBoxFocus.hasFocus && scrollviewController.positions.isNotEmpty) {
              scrollviewController
                  .jumpTo(scrollviewController.offset - scrollAmount);
              return KeyEventResult.handled;
            }
            break;
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
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage(
      {super.key,
      required this.searchBoxFocus,
      required this.scrollviewController});

  final FocusNode searchBoxFocus;
  final ScrollController scrollviewController;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  YoutubeAPI ytApi = YoutubeAPI(innerKey);
  List<YouTubeVideo> result = [];
  String noResultString = AppString.noSearchQuery;

  @override
  Widget build(BuildContext context) {
    TextEditingController textBoxController = TextEditingController();

    Widget searchResult = (result.isEmpty)
        ? Center(child: Text(noResultString))
        : ListItem(homepage: widget, result: result);

    return NavigationView(
      appBar: NavigationAppBar(
        title: TextBox(
          placeholder: "Search...",
          focusNode: widget.searchBoxFocus,
          controller: textBoxController,
          onSubmitted: (query) {
            ytApi.search(query).then((value) {
              setState(() {
                result = value;
              });
            }, onError: (e) {
              setState(() {
                noResultString = "Error: $e";
              });
            });
          },
        ),
      ),
      content: searchResult,
    );
  }
}
