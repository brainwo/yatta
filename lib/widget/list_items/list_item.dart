library list_item;

import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_api/youtube_api.dart';
import '../../helper/command_parser.dart';
import '../../helper/time.dart';
import '../../intent.dart';
import '../../locale/en_us.dart';
import '../keyboard_navigation.dart';

part 'channel.dart';
part 'playlist.dart';
part 'video.dart';

typedef ListItemCallback = void Function(YoutubeVideo);

class ListItem extends StatefulWidget {
  const ListItem({
    required this.child,
    required this.url,
    this.fromHistory = false,
    this.autofocus = false,
    final Key? key,
  }) : super(key: key);

  final Widget child;
  final String url;
  final bool autofocus;
  final bool fromHistory;

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  final contextController = FlyoutController();
  final contextAttachKey = GlobalKey();
  final _focusNode = FocusNode();
  bool _focused = false;
  bool _hovered = false;
  late final Map<Type, Action<Intent>> _actionMap;

  @override
  void initState() {
    super.initState();
    _actionMap = <Type, Action<Intent>>{
      ActivateIntent: CallbackAction<Intent>(
        onInvoke: (final _) async => _openMenuFlyout(),
      ),
    };
  }

  @override
  void dispose() {
    contextController.dispose();
    super.dispose();
  }

  void _handleFocusHighlight(final bool value) {
    setState(() {
      _focused = value;
    });
  }

  void _handleHoverHighlight(final bool value) {
    setState(() {
      _hovered = value;
    });
  }

  Future<void> _playVideo(final BuildContext context) async {
    await displayInfoBar(
      context,
      builder: (final context, final close) {
        return InfoBar(
          title: const Text('Playing'),
          content: const Text('Playing video on mpv'),
          action: IconButton(
            icon: const Icon(FluentIcons.clear),
            onPressed: close,
          ),
          severity: InfoBarSeverity.info,
        );
      },
    );

    await playFromUrl(widget.url);
  }

  Future<void> _playAudio(final BuildContext context) async {
    await displayInfoBar(
      context,
      builder: (final context, final close) {
        return InfoBar(
          title: const Text('Playing'),
          content: const Text('Playing audio on mpv'),
          action: IconButton(
            icon: const Icon(FluentIcons.clear),
            onPressed: close,
          ),
          severity: InfoBarSeverity.info,
        );
      },
    );

    await playFromUrl(
      widget.url,
      // fromHistory: widget.fromHistory,
      mode: PlayMode.listen,
    );
  }

  Future<void> _openPlayer(final BuildContext context) async {
    await displayInfoBar(
      context,
      builder: (final context, final close) {
        return InfoBar(
          title: const Text('Opening'),
          content: const Text('Opening url on mpv'),
          action: IconButton(
            icon: const Icon(FluentIcons.clear),
            onPressed: close,
          ),
          severity: InfoBarSeverity.info,
        );
      },
    );

    await Process.start(
        'mpv', ['--ytdl-format=bestvideo[height<=1080]+bestaudio', widget.url]);
  }

  Future<void> _openMenuFlyout() async {
    await contextController.showFlyout<dynamic>(
      dismissWithEsc: true,
      barrierDismissible: true,
      dismissOnPointerMoveAway: false,
      navigatorKey: GlobalKey<NavigatorState>().currentState,
      autoModeConfiguration: FlyoutAutoConfiguration(
        preferredMode: FlyoutPlacementMode.bottomCenter,
      ),
      builder: (final context) {
        return KeyboardNavigation(
          child: MenuFlyout(
            items: [
              MenuFlyoutItem(
                leading: const Icon(FluentIcons.play),
                text: const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'P',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                      TextSpan(text: 'lay'),
                    ],
                  ),
                ),
                onPressed: () => _playVideo(context),
              ),
              MenuFlyoutItem(
                leading: const Icon(FluentIcons.music_in_collection),
                text: const Text.rich(TextSpan(
                  text: 'L',
                  children: [
                    TextSpan(
                      text: 'i',
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                    TextSpan(text: 'sten'),
                  ],
                )),
                onPressed: () => _playAudio(context),
              ),
              MenuFlyoutItem(
                leading: const Icon(FluentIcons.heart),
                text: const Text.rich(TextSpan(children: [
                  TextSpan(
                    text: 'F',
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                  TextSpan(text: 'avorite'),
                ])),
                onPressed: () {},
              ),
              const MenuFlyoutSeparator(),
              MenuFlyoutItem(
                text: const Text.rich(
                  TextSpan(
                    text: 'Cop',
                    children: [
                      TextSpan(
                        text: 'y',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                      TextSpan(text: ' link address'),
                    ],
                  ),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(
                    text: widget.url,
                  )).whenComplete(() => displayInfoBar(
                        context,
                        builder: (final context, final close) {
                          return InfoBar(
                            title: const Text('Copied'),
                            content: const Text('URL copied to clipboard'),
                            action: IconButton(
                              icon: const Icon(FluentIcons.clear),
                              onPressed: close,
                            ),
                            severity: InfoBarSeverity.info,
                          );
                        },
                      ));
                },
              ),
              MenuFlyoutItem(
                text: const Text.rich(TextSpan(children: [
                  TextSpan(
                    text: 'O',
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                  TextSpan(text: 'pen in browser'),
                ])),
                onPressed: () async {
                  if (!await launchUrl(Uri.parse(widget.url))) {
                    throw Exception('Could not launch feedback url');
                  }
                },
              ),
              MenuFlyoutItem(
                text: const Text.rich(TextSpan(text: 'Open in ', children: [
                  TextSpan(
                    text: 'v',
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                  TextSpan(text: 'ideo player'),
                ])),
                onPressed: () => _openPlayer(context),
              ),
            ],
          ),
        );
      },
    );
  }

  FocusableActionDetector _content(final BuildContext context) {
    return FocusableActionDetector(
      autofocus: widget.autofocus,
      focusNode: _focusNode,
      actions: _actionMap,
      onShowFocusHighlight: _handleFocusHighlight,
      onShowHoverHighlight: _handleHoverHighlight,
      mouseCursor: SystemMouseCursors.click,
      child: ColoredBox(
        color: switch ((_focused, _hovered)) {
          (true, _) => FluentTheme.of(context).accentColor,
          (_, true) => Colors.white.withOpacity(0.1),
          _ => Colors.transparent,
        },
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: DecoratedBox(
            decoration: switch ((_focused, _hovered)) {
              (true, _) => BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              _ => const BoxDecoration(),
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    return Actions(
      actions: {
        PlayVideoIntent: CallbackAction<Intent>(
          onInvoke: (final _) async => _playVideo(context),
        ),
        ListenVideoIntent: CallbackAction<Intent>(
          onInvoke: (final _) async => _playAudio(context),
        ),
      },
      child: Shortcuts(
        shortcuts: {
          const SingleActivator(LogicalKeyboardKey.keyP):
              const PlayVideoIntent(),
          const SingleActivator(LogicalKeyboardKey.keyI):
              const ListenVideoIntent(),
        },
        child: FlyoutTarget(
          controller: contextController,
          child: GestureDetector(
            onTapDown: (final _) {
              setState(() => _focused = true);
            },
            onTapUp: (final _) {
              _focusNode.requestFocus();
            },
            onSecondaryTapDown: (final d) async {
              _focusNode.requestFocus();
              await _openMenuFlyout();
            },
            child: Shortcuts(
              shortcuts: {
                const SingleActivator(LogicalKeyboardKey.escape):
                    const NavigationPopIntent(),
              },
              child: _content(context),
            ),
          ),
        ),
      ),
    );
  }
}
