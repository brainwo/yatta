library list_item;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import '../../helper.dart';
import '../../locale/en_us.dart';

part 'channel.dart';
part 'playlist.dart';
part 'video.dart';

class ListItem extends StatefulWidget {
  final void Function() onPlay;
  final void Function() onSave;
  final Widget child;
  final String url;
  final bool autofocus;

  const ListItem({
    required this.onPlay,
    required this.onSave,
    required this.child,
    required this.url,
    this.autofocus = false,
    final Key? key,
  }) : super(key: key);

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  final contextController = FlyoutController();
  final contextAttachKey = GlobalKey();
  final _focusNode = FocusNode();
  bool _focused = false;
  bool _hovered = false;
  bool _showOptions = false;
  late final Map<Type, Action<Intent>> _actionMap;

  @override
  void initState() {
    super.initState();
    _actionMap = <Type, Action<Intent>>{
      ActivateIntent: CallbackAction<Intent>(
        onInvoke: (final _) => setState(() => _showOptions = !_showOptions),
      ),
    };
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
          setState(() => _showOptions = !_showOptions);
        },
        onSecondaryTapUp: (final d) async {
          _focusNode.requestFocus();

          final targetContext = context;
          final box = targetContext.findRenderObject()! as RenderBox;
          final position = box.localToGlobal(
            d.localPosition,
            ancestor: Navigator.of(context).context.findRenderObject(),
          );

          await contextController.showFlyout<dynamic>(
            barrierColor: Colors.transparent,
            position: position,
            builder: (final context) {
              return FlyoutContent(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: CommandBar(
                    overflowBehavior: CommandBarOverflowBehavior.wrap,
                    primaryItems: [
                      CommandBarButton(
                        icon: const Icon(FluentIcons.copy),
                        label: const SizedBox(
                          width: 120,
                          child: Text('Copy link address'),
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: widget.url));
                          Navigator.pop(context);
                        },
                      ),
                      CommandBarButton(
                        icon: const Icon(FluentIcons.save),
                        label: const SizedBox(
                          width: 120,
                          child: Text('Save'),
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: Column(
          children: [
            _content(context),
            if (_showOptions)
              Row(
                children: [
                  _ContextButtons(
                    icon: FluentIcons.heart,
                    title: 'Favorite',
                    onPressed: widget.onSave,
                  ),
                  _ContextButtons(
                    icon: FluentIcons.play,
                    title: 'Play',
                    onPressed: widget.onPlay,
                  ),
                  _ContextButtons(
                    icon: FluentIcons.copy,
                    title: 'Copy URL',
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: widget.url));

                      if (context.mounted) {
                        await displayInfoBar(
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
                        );
                      }
                    },
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}

class _ContextButtons extends StatefulWidget {
  final IconData icon;
  final String title;
  final void Function() onPressed;

  const _ContextButtons({
    required this.icon,
    required this.title,
    required this.onPressed,
  });

  @override
  State<_ContextButtons> createState() => _ContextButtonsState();
}

class _ContextButtonsState extends State<_ContextButtons> {
  bool _focused = false;
  bool _hovered = false;
  late final Map<Type, Action<Intent>> _actionMap;

  @override
  void initState() {
    super.initState();
    _actionMap = <Type, Action<Intent>>{
      ActivateIntent: CallbackAction<Intent>(
        onInvoke: (final _) => widget.onPressed(),
      ),
    };
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

  @override
  Widget build(final BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: widget.onPressed,
        child: FocusableActionDetector(
          actions: _actionMap,
          onShowFocusHighlight: _handleFocusHighlight,
          onShowHoverHighlight: _handleHoverHighlight,
          mouseCursor: SystemMouseCursors.click,
          child: ColoredBox(
            color: switch ((_focused, _hovered)) {
              (true, _) => FluentTheme.of(context).activeColor,
              (_, true) => Colors.white.withOpacity(0.1),
              _ => Colors.transparent,
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, size: 12),
                  const SizedBox(width: 16),
                  Text(widget.title),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
