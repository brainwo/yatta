import 'package:autoscroll/autoscroll.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show showLicensePage;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_api/youtube_api.dart';

import '../helper/time.dart';
import '../widget/keyboard_navigation.dart';
import '../widget/list_items/list_item.dart';

class WelcomeMessage extends StatelessWidget {
  const WelcomeMessage({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    final windowWidth = MediaQuery.sizeOf(context).width;
    final isWide = windowWidth >= 1500;

    return KeyboardNavigation(
      child: AutoscrollListView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        children: [
          const SizedBox(height: 8),
          RecentHistory(),
          const SizedBox(height: 24),
          Wrap(
            direction: isWide ? Axis.vertical : Axis.horizontal,
            spacing: 18,
            runSpacing: 18,
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            children: [
              _SelectionMenu(
                autofocus: true,
                key: const Key('saved'),
                title: 'Saved playlist',
                subtitle: 'View saved videos, playlists, and channels',
                icon: FluentIcons.playlist_music,
                onPressed: () async {
                  await Navigator.of(context).pushNamed('/playlist');
                },
              ),
              _SelectionMenu(
                key: const Key('feed'),
                title: 'Feed',
                subtitle: 'Subsribe to channels via RSS Feed',
                icon: FluentIcons.content_feed,
                onPressed: () async {
                  await Navigator.of(context).pushNamed('/feed');
                },
              ),
              _SelectionMenu(
                key: const Key('history'),
                title: 'History',
                subtitle: 'Browse through recent play history',
                icon: FluentIcons.history,
                onPressed: () async {
                  await Navigator.of(context).pushNamed('/history');
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Tooltip(
                message: 'Configure app settings and preferences',
                useMousePosition: false,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: HyperlinkButton(
                    onPressed: () async {
                      await Navigator.of(context).pushNamed('/settings');
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(FluentIcons.settings),
                        SizedBox(width: 4),
                        Text(
                          'Settings',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Tooltip(
                message: 'Open the GitHub Discussion page',
                useMousePosition: false,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: HyperlinkButton(
                    onPressed: () async {
                      if (!await launchUrl(Uri.https(
                          'github.com', 'brainwo/yatta/discussions'))) {
                        throw Exception('Could not launch feedback url');
                      }
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Suggest a feedback',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(FluentIcons.open_in_new_window),
                      ],
                    ),
                  ),
                ),
              ),
              Tooltip(
                message: 'Read application license',
                useMousePosition: false,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: HyperlinkButton(
                    onPressed: () {
                      showLicensePage(
                        context: context,
                        applicationVersion: const String.fromEnvironment(
                          'APPLICATION_VERSION',
                          defaultValue: 'development',
                        ),
                      );
                    },
                    child: const Text(
                      'License',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class RecentHistory extends StatelessWidget {
  RecentHistory({
    super.key,
  });

  final fetchHistory = SharedPreferences.getInstance().then(
    (final v) => v.getStringList('history')?.map(
          (final e) => YoutubeVideo.fromString(e),
        ),
  );

  @override
  Widget build(final BuildContext context) {
    return FutureBuilder(
      future: fetchHistory,
      builder: (final context, final snapshot) {
        if (snapshot.data == null) {
          return Container();
        }
        return SizedBox(
          width: 250,
          child: Column(
            children: [
              Row(
                children: [
                  const Text.rich(TextSpan(children: [
                    WidgetSpan(
                      child: Icon(FluentIcons.history, size: 14),
                    ),
                    TextSpan(text: '  Recently Viewed'),
                  ])),
                  const Spacer(),
                  HyperlinkButton(
                    onPressed: () async {
                      await Navigator.of(context).pushNamed('/history');
                    },
                    child: const Text('See All >'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AutoscrollSingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                    children: snapshot.data!
                        .toList()
                        .reversed
                        .where((final e) => e.kind == 'video')
                        .take(10)
                        .map(
                          (final data) =>
                              _HomeVideoThumbnail(youtubeVideo: data),
                        )
                        .toList()),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeVideoThumbnail extends StatelessWidget {
  const _HomeVideoThumbnail({
    required this.youtubeVideo,
  });

  final YoutubeVideo youtubeVideo;

  @override
  Widget build(final BuildContext context) {
    return ListItem(
      url: youtubeVideo.url,
      fromHistory: true,
      child: SizedBox(
        width: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                Image.network(
                  youtubeVideo.thumbnail.medium.url ?? '',
                ),
                if (youtubeVideo.duration != null)
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: Text(
                        youtubeVideo.duration!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              youtubeVideo.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                Flexible(
                  child: Text(
                    youtubeVideo.channelTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w300),
                  ),
                ),
                Text(
                  ' • ${timeSince(
                    DateTime.parse(youtubeVideo.publishedAt!),
                    DateTime.now(),
                  )}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionMenu extends StatelessWidget {
  const _SelectionMenu({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onPressed,
    this.autofocus = false,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final void Function() onPressed;
  final bool autofocus;

  @override
  Widget build(final BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Button(
        autofocus: autofocus,
        onPressed: onPressed,
        child: SizedBox(
          width: 500,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Icon(icon, size: 28),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Builder(builder: (final context) {
                          return Text(
                            title,
                            style: FluentTheme.of(context)
                                .typography
                                .bodyStrong
                                ?.copyWith(
                                    color: DefaultTextStyle.of(context)
                                        .style
                                        .color),
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          );
                        }),
                        const SizedBox(height: 8),
                        Builder(builder: (final context) {
                          return Text(
                            subtitle,
                            style: FluentTheme.of(context)
                                .typography
                                .body
                                ?.copyWith(
                                  color:
                                      DefaultTextStyle.of(context).style.color,
                                  fontWeight: FontWeight.w300,
                                ),
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  const Icon(FluentIcons.chevron_right)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
