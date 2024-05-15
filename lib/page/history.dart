import 'dart:async';

import 'package:autoscroll/autoscroll.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../intent.dart';
import '../helper/command_parser.dart';
import '../model/database.dart';
import '../widget/choice_chip.dart';
import '../widget/keyboard_navigation.dart';
import '../widget/list_items/list_item.dart';

enum SortingOptions {
  alphabetical,
  uploadDate,
  lastWatch,
  timesWatched,
  popular,
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FocusNode searchBarFocus = FocusNode();
  SortingOptions sortingOption = SortingOptions.lastWatch;
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
              e.channelTitle.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    });
  }

  void sortList(final SortingOptions? option, {final bool desc = false}) {
    if (desc == true) {
      setState(() => filteredList = filteredList?.reversed.toList());
      return;
    }
    switch (option) {
      case SortingOptions.alphabetical:
        filteredList?.sort((final a, final b) => a.title.compareTo(b.title));
      case SortingOptions.lastWatch:
        filteredList?.sort((final a, final b) {
          try {
            final result = DateTime.parse(a.history.first)
                .compareTo(DateTime.parse(b.history.first));
            return result;
          } on FormatException catch (_) {
            return 0;
          }
        });
      case SortingOptions.uploadDate:
        filteredList?.sort((final a, final b) => DateTime.parse(a.publishDate)
            .compareTo(DateTime.parse(b.publishDate)));
      case SortingOptions.timesWatched:
        filteredList?.sort(
            (final a, final b) => a.history.length.compareTo(b.history.length));
      case SortingOptions.popular:
        filteredList?.sort((final a, final b) =>
            a.viewCount?.compareTo(b.viewCount ?? 0) ?? 0);
      case null:
        filteredList?.sort((final a, final b) => a.title.compareTo(b.title));
    }

    setState(() => sortingOption = option ?? SortingOptions.lastWatch);
  }

  final sortChoices = [
    (
      const Text.rich(TextSpan(
        children: [
          WidgetSpan(
            child: Icon(FluentIcons.history, size: 14),
          ),
          TextSpan(text: '  Last watched')
        ],
      )),
      SortingOptions.lastWatch
    ),
    (const Text('Most watched'), SortingOptions.timesWatched),
    (const Text('Recent upload'), SortingOptions.uploadDate),
    (const Text('Popular'), SortingOptions.popular),
  ];

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: SizedBox(
                  height: 36,
                  child: AutoscrollListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: sortChoices.length,
                    separatorBuilder: (final context, final _) =>
                        const SizedBox(width: 8),
                    itemBuilder: (final context, final i) => ChoiceChip(
                      selected: sortingOption == sortChoices[i].$2,
                      label: sortChoices[i].$1,
                      onSelected: (final value) => value
                          ? sortList(sortChoices[i].$2)
                          : sortList(sortChoices[i].$2, desc: true),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AutoscrollListView.builder(
                  shrinkWrap: true,
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
                          duration: youtubeVideo.duration,
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
                      history: youtubeVideo,
                      url: youtubeVideo.url,
                      fromHistory: true,
                      child: listItem,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
