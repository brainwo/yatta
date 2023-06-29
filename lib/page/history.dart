import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_api/youtube_api.dart';

import '../../intent.dart';
import '../helper.dart';
import '../widget/keyboard_navigation.dart';
import '../widget/list_items/list_item.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FocusNode searchBarFocus = FocusNode();
  late final Map<Type, Action<Intent>> _actionMap;
  late Future<List<String>?> future;
  List<YoutubeVideo>? filteredList;
  List<YoutubeVideo>? historyList;

  @override
  void initState() {
    super.initState();

    _actionMap = {
      SearchBarFocusIntent: CallbackAction<Intent>(
        onInvoke: (final _) => _requestSearchBarFocus(),
      ),
      NavigationPopIntent: CallbackAction<Intent>(
        onInvoke: (final _) => _navigationPop(context),
      )
    };

    fetchHistory();
  }

  Future<void> fetchHistory() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      historyList = prefs
          .getStringList('history')
          ?.map((final e) => YoutubeVideo.fromString(e))
          .toList();
      filteredList = historyList;
    });
  }

  void _requestSearchBarFocus() {
    searchBarFocus.requestFocus();
  }

  void _navigationPop(final BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _filterList(final String keyword) {
    if (filteredList == null) return;
    setState(() {
      filteredList = historyList
          ?.map((final e) => (e, e.toString()))
          .where(
            (final e) => e.$2.toLowerCase().contains(keyword.toLowerCase()),
          )
          .map((final e) => e.$1)
          .toList();
    });

    print(filteredList);
  }

  @override
  Widget build(final BuildContext context) {
    final timeNow = DateTime.now();
    return Actions(
      actions: _actionMap,
      child: NavigationView(
        appBar: NavigationAppBar(
            title: TextBox(
          focusNode: searchBarFocus,
          placeholder: 'Search from recent history',
          onChanged: _filterList,
        )),
        content: KeyboardNavigation(
          child: Center(
            child: ListView.builder(
              itemCount: filteredList?.length ?? 0,
              itemBuilder: (final context, final index) {
                final youtubeVideo =
                    filteredList![filteredList!.length - index - 1];
                final title = youtubeVideo.title
                    .replaceAll('&amp;', '&')
                    .replaceAll('&#39;', '\'')
                    .replaceAll('&quot;', '"');

                final listItem = switch (youtubeVideo.kind) {
                  'video' => ListItemVideo(
                      title: title,
                      channelTitle: youtubeVideo.channelTitle,
                      description: youtubeVideo.description,
                      duration: youtubeVideo.duration!,
                      thumbnailUrl: youtubeVideo.thumbnail.medium.url,
                      publishedAt: youtubeVideo.publishedAt,
                      timeNow: timeNow,
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
                  onClick: () async => PlayVideo.fromYoutubeVideo(youtubeVideo,
                      fromHistory: true),
                  url: youtubeVideo.url,
                  child: listItem,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
