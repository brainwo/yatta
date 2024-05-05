import 'dart:async';

import 'package:autoscroll/autoscroll.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_api/youtube_api.dart';

import '../../intent.dart';
import '../helper/command_parser.dart';
import '../model/database.dart';
import '../widget/keyboard_navigation.dart';
import '../widget/list_items/list_item.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FocusNode searchBarFocus = FocusNode();
  List<HistoryModel>? filteredList;
  List<HistoryModel>? historyList;
  late final Map<Type, Action<Intent>> _actionMap = {
    SearchBarFocusIntent: CallbackAction<Intent>(
      onInvoke: (final _) => _requestSearchBarFocus(),
    ),
    NavigationPopIntent: CallbackAction<Intent>(
      onInvoke: (final _) => _navigationPop(context),
    )
  };

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((final _) async {
      await fetchHistory();
    });
  }

  Future<void> fetchHistory() async {
    final database = await HistoryDatabase.load();

    setState(() {
      historyList = database.history;
      filteredList = historyList;
    });
  }

  void _requestSearchBarFocus() => searchBarFocus.requestFocus();

  void _navigationPop(final BuildContext context) {
    if (!Navigator.of(context).canPop()) return;
    Navigator.of(context).pop();
  }

  void _filterList(final String keyword) {
    if (filteredList == null) return;
    setState(() {
      filteredList = historyList
          ?.where((final e) =>
              e.toString().toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    });
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
              placeholder: 'Search from recent history',
              onChanged: _filterList,
            ),
          ),
        ),
        content: KeyboardNavigation(
          child: AutoscrollListView.builder(
            itemCount: filteredList?.length ?? 0,
            itemBuilder: (final context, final index) {
              final youtubeVideo =
                  filteredList![filteredList!.length - index - 1];
              final title = youtubeVideo.title.parseHtmlEntities();

              final listItem = switch (youtubeVideo.type) {
                ItemType.video => ListItemVideo(
                    title: title,
                    channelTitle: youtubeVideo.channelTitle,
                    description: youtubeVideo.description,
                    duration: youtubeVideo.duration.toString(),
                    thumbnailUrl: youtubeVideo.thumbnailUrl,
                    publishedAt: youtubeVideo.publishDate,
                  ),
                ItemType.channel => ListItemChannel(
                    channelTitle: youtubeVideo.channelTitle,
                    thumbnailUrl: youtubeVideo.thumbnailUrl,
                  ),
                ItemType.playlist => ListItemPlaylist(
                    title: title,
                    channelTitle: youtubeVideo.channelTitle,
                    description: youtubeVideo.description,
                    thumbnailUrl: youtubeVideo.thumbnailUrl,
                  ),
              };

              return ListItem(
                autofocus: index == 0,
                url: youtubeVideo.url,
                fromHistory: true,
                child: listItem,
              );
            },
          ),
        ),
      ),
    );
  }
}
