import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'keyboard_navigation.dart';

class WelcomeMessage extends StatelessWidget {
  const WelcomeMessage({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    final windowWidth = MediaQuery.sizeOf(context).width;
    final isWide = windowWidth >= 1500;

    return KeyboardNavigation(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 64),
        children: [
          const SizedBox(height: 48),
          Center(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Yatta',
                    style: FluentTheme.of(context).typography.title,
                  ),
                  const WidgetSpan(child: SizedBox(width: 8)),
                  TextSpan(
                    text: 'v1.0.0',
                    style: FluentTheme.of(context)
                        .typography
                        .caption
                        ?.copyWith(color: FluentTheme.of(context).accentColor),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A YouTube frontend for creative hackers',
            style: FluentTheme.of(context).typography.bodyLarge,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 24),
          Wrap(
            direction: isWide ? Axis.vertical : Axis.horizontal,
            spacing: 18,
            runSpacing: 18,
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            children: [
              _SelectionMenu(
                key: const Key('tour'),
                title: 'App tour',
                subtitle: 'Learn more about feature you can use',
                icon: FluentIcons.compass_n_w,
                onPressed: () {},
              ),
              _SelectionMenu(
                key: const Key('saved'),
                title: 'Saved playlist',
                subtitle: 'View saved videos, playlists, and channels',
                icon: FluentIcons.playlist_music,
                onPressed: () {
                  Navigator.of(context).pushNamed('/playlist');
                },
              ),
              _SelectionMenu(
                key: const Key('history'),
                title: 'History',
                subtitle: 'Browse through recent play history',
                icon: FluentIcons.history,
                onPressed: () {
                  Navigator.of(context).pushNamed('/history');
                },
              ),
              _SelectionMenu(
                key: const Key('settings'),
                title: 'Settings',
                subtitle: 'Configure app settings and preferences',
                icon: FluentIcons.settings,
                onPressed: () {
                  Navigator.of(context).pushNamed('/settings');
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Tooltip(
              message: 'Open the GitHub Discussion page',
              useMousePosition: false,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: HyperlinkButton(
                  onPressed: () async {
                    if (!await launchUrl(
                        Uri.https('github.com', 'brainwo/yatta/discussions'))) {
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
          )
        ],
      ),
    );
  }
}

class _SelectionMenu extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final void Function() onPressed;

  const _SelectionMenu({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(final BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Button(
        autofocus: true,
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
                                  color:
                                      DefaultTextStyle.of(context).style.color,
                                ),
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          );
                        }),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          style: FluentTheme.of(context)
                              .typography
                              .body
                              ?.copyWith(
                                color: DefaultTextStyle.of(context).style.color,
                                fontWeight: FontWeight.w300,
                              ),
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
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
