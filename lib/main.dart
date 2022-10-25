import 'theme/arc_dark.dart';
import 'package:fluent_ui/fluent_ui.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    var searchBoxFocus = FocusNode();
    var scrollItemFocus = FocusNode();

    return KeyboardListener(
      focusNode: FocusNode(onKey: (node, event) {
        switch (event.logicalKey.keyLabel) {
          case "Tab":
            node.requestFocus(scrollItemFocus);
            return KeyEventResult.handled;
          case "/":
            node.requestFocus(searchBoxFocus);
            return KeyEventResult.handled;
          default:
            return KeyEventResult.skipRemainingHandlers;
        }
      }),
      child: FluentApp(
        debugShowCheckedModeBanner: false,
        title: 'YT Hacker',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppTheme.background,
          micaBackgroundColor: AppTheme.background,
          activeColor: AppTheme.primary,
        ),
        home: HomePage(searchBoxFocus: searchBoxFocus),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.searchBoxFocus});

  final FocusNode searchBoxFocus;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    var textBoxController = TextEditingController();
    var query = [];

    return NavigationView(
      appBar: NavigationAppBar(
        title: TextBox(
          focusNode: widget.searchBoxFocus,
          controller: textBoxController,
          onSubmitted: (fetch) {
            debugPrint(fetch);
          },
        ),
      ),
      content: Center(
        child: query.isEmpty
            ? const Center(
                child: Text("No search query"),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  Text(
                    'You have pushed the button this many times:',
                  ),
                ],
              ),
      ),
    );
  }
}
