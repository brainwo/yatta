import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_api/youtube_api.dart';

import '../../intent.dart';
import '../helper/command_parser.dart';
import '../widget/keyboard_navigation.dart';
import '../widget/list_items/list_item.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  final FocusNode searchBarFocus = FocusNode();
  late final Map<Type, Action<Intent>> _actionMap = {
    SearchBarFocusIntent: CallbackAction<Intent>(
      onInvoke: (final _) => _requestSearchBarFocus(),
    ),
    NavigationPopIntent: CallbackAction<Intent>(
      onInvoke: (final _) => _navigationPop(context),
    )
  };
  late Future<List<String>> future = SharedPreferences.getInstance()
      .then((final prefs) => prefs.getStringList('playlist') ?? []);

  @override
  void initState() {
    super.initState();
  }

  void _requestSearchBarFocus() {
    searchBarFocus.requestFocus();
  }

  void _navigationPop(final BuildContext context) {
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  @override
  Widget build(final BuildContext context) {
    return Actions(
      actions: _actionMap,
      child: NavigationView(
        appBar: NavigationAppBar(
          title: SizedBox(
            height: 36,
            child: TextBox(
              focusNode: searchBarFocus,
              placeholder: 'Search from saved playlist',
            ),
          ),
        ),
        content: KeyboardNavigation(
          child: Center(
            child: FutureBuilder(
              future: future,
              builder: (final context, final snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();

                final historyList = snapshot.data!
                    .map((final e) => YoutubeVideo.fromString(e))
                    .toList();

                return ListView.builder(
                  itemCount: historyList.length,
                  itemBuilder: (final context, final index) {
                    final youtubeVideo =
                        historyList[historyList.length - index - 1];
                    final title = youtubeVideo.title.parseHtmlEntities();

                    final listItem = switch (youtubeVideo.kind) {
                      'video' => ListItemVideo(
                          title: title,
                          channelTitle: youtubeVideo.channelTitle,
                          description: youtubeVideo.description,
                          duration: youtubeVideo.duration!,
                          thumbnailUrl: youtubeVideo.thumbnail.medium.url,
                          publishedAt: youtubeVideo.publishedAt,
                        ),
                      'channel' => ListItemChannel(
                          channelTitle: youtubeVideo.channelTitle,
                          thumbnailUrl: youtubeVideo.thumbnail.medium.url,
                        ),
                      'playlist' => ListItemPlaylist(
                          title: title,
                          channelTitle: youtubeVideo.channelTitle,
                          description: youtubeVideo.description,
                          thumbnailUrl: youtubeVideo.thumbnail.medium.url,
                        ),
                      _ => const SizedBox.shrink()
                    };

                    return ListItem(
                        autofocus: index == 0,
                        fromHistory: true,
                        url: youtubeVideo.url,
                        child: listItem);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
