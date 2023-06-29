import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_api/youtube_api.dart';

import 'const.dart';
import 'helper.dart';
import 'intent.dart';
import 'locale/en_us.dart';
import 'model/theme.dart';
import 'page/history.dart';
import 'page/playlist.dart';
import 'page/settings.dart';
import 'widget/search_error.dart';
import 'widget/search_result.dart';
import 'widget/welcome_message.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  static final appTheme = AppTheme.from(defaultThemeName);

  @override
  Widget build(final BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: FluentApp(
        debugShowCheckedModeBanner: false,
        title: 'Yatta',
        shortcuts: {
          ...WidgetsApp.defaultShortcuts,
          const SingleActivator(LogicalKeyboardKey.f6):
              const SearchBarFocusIntent(),
          const SingleActivator(LogicalKeyboardKey.keyJ, control: true):
              const SearchBarFocusIntent(),
          const SingleActivator(LogicalKeyboardKey.keyK, control: true):
              const SearchBarFocusIntent(),
          const SingleActivator(LogicalKeyboardKey.keyL, control: true):
              const SearchBarFocusIntent(),
          // TODO: currently typing `q` in a text field is impossible with this implementation
          // const SingleActivator(LogicalKeyboardKey.keyQ):
          // const NavigationPopIntent(),
          const SingleActivator(LogicalKeyboardKey.escape):
              const NavigationPopIntent(),
        },
        // TODO: theme provider
        theme: FluentThemeData.dark().copyWith(
          accentColor: appTheme.primary.toAccentColor(),
          activeColor: appTheme.primary,
          buttonTheme: ButtonThemeData(
            defaultButtonStyle: ButtonStyle(
              foregroundColor: ButtonState.resolveWith((final states) {
                if (states.isPressing) return Colors.white;
                return null;
              }),
              backgroundColor: ButtonState.resolveWith(
                (final states) {
                  if (states.isPressing) return appTheme.primary;
                  if (states.isHovering) return appTheme.backgroundHighlight;
                  return appTheme.background;
                },
              ),
            ),
          ),
          tooltipTheme: TooltipThemeData(
            preferBelow: true,
            showDuration: Duration.zero,
            waitDuration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: appTheme.background.withOpacity(0.5),
              borderRadius: BorderRadius.circular(4),
            ),
            textStyle: const TextStyle(fontSize: 14),
          ),
          navigationPaneTheme: NavigationPaneThemeData(
            backgroundColor: appTheme.backgroundDarker,
          ),
          resources: ResourceDictionary.dark(
            controlFillColorInputActive: appTheme.background,
          ),
        ),
        darkTheme: FluentThemeData.dark(),
        routes: {
          '/': (final _) => const HomePage(),
          '/playlist': (final _) => const PlaylistPage(),
          '/history': (final _) => const HistoryPage(),
          '/settings': (final _) => const SettingsPage(),
        },
      ),
    );
  }
}

/// When using the search box, you can toggle between these input mode:
///
/// - `video`: search for videos only
/// - `playlist`: search for playlists only
/// - `channel`: search for channels only
/// - `all`: search for videos, playlists, channels
/// - `play`: play the given URL
enum SearchBoxMode {
  video,
  playlist,
  channel,
  all,
  play;

  /// YouTube search will return either one of these categories:
  /// `video`, `playlist`, or `channel`.
  bool get isSearchCategory =>
      this == SearchBoxMode.video ||
      this == SearchBoxMode.playlist ||
      this == SearchBoxMode.channel;

  /// Return enum name in title case
  String get titleName =>
      '${this.name[0].toUpperCase()}${this.name.substring(1)}';
}

/// The main page of this application
/// HomePage may navigate to `TourPage`, `PlaylistPage`, `HistoryPage`, or `SettingsPage`
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late YoutubeApi youtubeApi;
  String noResultString = AppString.noSearchQuery;
  SearchBoxMode searchBoxMode = SearchBoxMode.all;
  TextEditingController textBoxController = TextEditingController();
  Future<List<YoutubeVideo>>? searchResult;

  final FocusNode searchBarFocus = FocusNode();
  late final Map<Type, Action<Intent>> _actionMap;

  @override
  void initState() {
    super.initState();
    textBoxController.addListener(() {
      if (searchBoxMode == SearchBoxMode.all) {
        setState(() {
          switch (textBoxController.text) {
            case searchModeVideoShortcut:
              searchBoxMode = SearchBoxMode.video;
              textBoxController.text = '';
            case searchModeChannelShortcut:
              searchBoxMode = SearchBoxMode.channel;
              textBoxController.text = '';
            case searchModePlaylistShortcut:
              searchBoxMode = SearchBoxMode.playlist;
              textBoxController.text = '';
          }
        });
      }

      final isUrl = textBoxController.text.startsWith('https://') ||
          textBoxController.text.startsWith('www.youtube.com') ||
          textBoxController.text.startsWith('youtube.com') ||
          textBoxController.text.startsWith('youtu.be');

      if (isUrl) {
        setState(() {
          searchBoxMode = SearchBoxMode.play;
        });
        return;
      }

      if (searchBoxMode == SearchBoxMode.play) {
        setState(() {
          searchBoxMode = SearchBoxMode.all;
        });
      }
    });

    _actionMap = {
      SearchBarFocusIntent: CallbackAction<Intent>(
        onInvoke: (final _) => _requestSearchBarFocus(),
      ),
    };
  }

  Future<void> _handleTopBar(final String query) async {
    if (searchBoxMode == SearchBoxMode.play) {
      await PlayVideo.fromUrl(query);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('youtube_api_key');
    final maxResults = prefs.getInt('youtube_result_per_search');

    if (apiKey == null) {
      // throw error
      return;
    }

    youtubeApi = YoutubeApi(apiKey, maxResults: maxResults ?? 10);

    setState(() {
      if (query.isEmpty) {
        searchResult = null;
        return;
      }

      searchResult = youtubeApi.search(
        query,
        type: searchBoxMode == SearchBoxMode.all
            ? 'video,channel,playlist'
            : searchBoxMode.name,
      );
    });
  }

  void _requestSearchBarFocus() {
    searchBarFocus.requestFocus();
  }

  Widget topBar() {
    return Row(
      children: [
        if (searchBoxMode.isSearchCategory)
          _SearchModeIndicator(searchBoxMode: searchBoxMode),
        Expanded(
          child: KeyboardListener(
            focusNode: FocusNode(
              skipTraversal: true,
              onKey: (final _, final event) {
                final removeSearchCategory = searchBoxMode.isSearchCategory &&
                    event.isKeyPressed(LogicalKeyboardKey.backspace) &&
                    textBoxController.text == '';

                if (removeSearchCategory) {
                  setState(() {
                    searchBoxMode = SearchBoxMode.all;
                  });
                  return KeyEventResult.handled;
                }

                return KeyEventResult.ignored;
              },
            ),
            child: TextBox(
              focusNode: searchBarFocus,
              autocorrect: false,
              placeholder: searchBoxMode.isSearchCategory
                  ? AppString.searchPlaceholder
                  : AppString.searchPlaceholderAll,
              controller: textBoxController,
              onSubmitted: _handleTopBar,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.all(8),
          child: searchButton(),
        )
      ],
    );
  }

  Widget searchButton() {
    return Tooltip(
      message: searchBoxMode == SearchBoxMode.play
          ? 'Play from URL'
          : 'Search for videos',
      useMousePosition: false,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Button(
          focusable: false,
          child: Center(
            child: Icon(
              searchBoxMode == SearchBoxMode.play
                  ? FluentIcons.play
                  : FluentIcons.search,
            ),
          ),
          onPressed: () => _handleTopBar(textBoxController.text),
        ),
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    return Actions(
      actions: _actionMap,
      child: NavigationView(
        appBar: NavigationAppBar(
          automaticallyImplyLeading: false,
          title: topBar(),
        ),
        content: FutureBuilder(
          future: searchResult,
          builder: (final context, final snapshot) {
            if (snapshot.hasError) {
              return SearchError(errorText: snapshot.error.toString());
            }

            return switch (snapshot.connectionState) {
              ConnectionState.done => SearchResult(result: snapshot.data!),
              ConnectionState.none => const WelcomeMessage(),
              ConnectionState.waiting ||
              ConnectionState.active =>
                const Center(child: ProgressBar())
            };
          },
        ),
      ),
    );
  }
}

class _SearchModeIndicator extends StatelessWidget {
  const _SearchModeIndicator({
    required this.searchBoxMode,
  });

  final SearchBoxMode searchBoxMode;

  @override
  Widget build(final BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: FluentTheme.of(context).accentColor,
          borderRadius: const BorderRadius.all(
            Radius.circular(6),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(searchBoxMode.titleName),
        ),
      ),
    );
  }
}
