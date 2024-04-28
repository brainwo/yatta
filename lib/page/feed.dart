import 'dart:async';
import 'dart:io';

import 'package:autoscroll/autoscroll.dart';
import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:http/http.dart' as http;
import 'package:rss_dart/dart_rss.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xdg_directories/xdg_directories.dart' as xdg;
import 'package:yaml/yaml.dart' as yaml;
import 'package:youtube_api/youtube_api.dart';

import '../../intent.dart';
import '../const.dart';
import '../helper/command_parser.dart';
import '../widget/keyboard_navigation.dart';
import '../widget/list_items/list_item.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final FocusNode searchBarFocus = FocusNode();
  List<AtomItem>? filteredList;
  List<AtomItem>? feedList;
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
      await fetchFeed();
    });
  }

  Future<void> fetchFeed() async {
    final file = feedPathLookup
        .map((final path) => File('${xdg.configHome.path}$path'))
        .firstWhereOrNull((final configLookup) => configLookup.existsSync());

    if (file == null) return;

    final result = await file
        .readAsString()
        .then((final rawFile) => switch (yaml.loadYaml(rawFile)) {
              final List<dynamic> urls => urls
                  .map((final url) => http.get(Uri.parse(url.toString())))
                  .toList(),
              _ => <Future<http.Response>>[]
            })
        .then((final urls) async => Future.wait(urls));

    setState(() {
      feedList = result
          .map((final e) => AtomFeed.parse(e.body))
          .expand((final e) => e.items)
          .sorted((final a, final b) => DateTime.parse(a.published ?? '')
              .compareTo(DateTime.parse(b.published ?? '')))
          .toList();

      filteredList = feedList;
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
      filteredList = feedList
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
              placeholder: 'Search from feed',
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
              // print(youtubeVideo
              // .items.first.media?.group?.);

              final listItem = ListItemVideo(
                title: youtubeVideo.media?.title?.value ?? '',
                channelTitle: youtubeVideo.authors.first.name ?? '',
                description:
                    youtubeVideo.media?.group?.description?.value ?? '',
                duration: '00:02',
                thumbnailUrl:
                    youtubeVideo.media?.group?.thumbnail.firstOrNull?.url ?? '',
                publishedAt: youtubeVideo.published ?? '',
              );

              return listItem;

              return ListItem(
                autofocus: index == 0,
                youtubeVideo: YoutubeVideo(''),
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
