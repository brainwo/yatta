import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import '../intent.dart';
import 'keyboard_navigation.dart';

class ThumbnailItem extends StatefulWidget {
  final void Function() onPlay;
  final void Function() onSave;
  final void Function() onListen;
  final Widget child;
  final String url;
  final bool autofocus;

  const ThumbnailItem({
    required this.onPlay,
    required this.onListen,
    required this.onSave,
    required this.child,
    required this.url,
    this.autofocus = false,
    final Key? key,
  }) : super(key: key);

  @override
  State<ThumbnailItem> createState() => _ThumbnailItemState();
}

class _ThumbnailItemState extends State<ThumbnailItem> {
  final contextController = FlyoutController();
  final contextAttachKey = GlobalKey();
  final _focusNode = FocusNode();
  bool _focused = false;
  bool _hovered = false;
  // bool _showOptions = false;
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
                text: const Text('Play'),
                onPressed: widget.onPlay,
              ),
              MenuFlyoutItem(
                leading: const Icon(FluentIcons.heart),
                text: const Text('Favorite'),
                onPressed: widget.onSave,
              ),
              MenuFlyoutItem(
                leading: const Icon(FluentIcons.music_in_collection),
                text: const Text('Listen'),
                onPressed: widget.onListen,
              ),
              MenuFlyoutItem(
                leading: const Icon(FluentIcons.copy),
                text: const Text('Copy link address'),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.url));
                  Navigator.pop(context);
                },
              ),
              MenuFlyoutItem(
                leading: const Icon(FluentIcons.save),
                text: const Text('Save'),
                onPressed: () {},
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
    return FlyoutTarget(
      controller: contextController,
      child: GestureDetector(
        onTapDown: (final _) {
          setState(() => _focused = true);
        },
        onTapUp: (final _) {
          Future.delayed(const Duration(milliseconds: 100), () {
            setState(() => _focused = false);
          });

          _focusNode.requestFocus();
          // setState(() => _showOptions = !_showOptions);
        },
        onSecondaryTapDown: (final d) async {
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
    );
  }
}
