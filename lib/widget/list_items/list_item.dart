part of search_result;

class _ListItem extends StatefulWidget {
  final void Function() onClick;
  final Widget child;
  final String url;
  final bool autofocus;

  const _ListItem({
    required this.onClick,
    required this.child,
    required this.url,
    this.autofocus = false,
    final Key? key,
  }) : super(key: key);

  @override
  State<_ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<_ListItem> {
  bool _focused = false;
  late final Map<Type, Action<Intent>> _actionMap;

  @override
  void initState() {
    super.initState();
    _actionMap = <Type, Action<Intent>>{
      ActivateIntent: CallbackAction<Intent>(
        onInvoke: (final _) => widget.onClick(),
      ),
    };
  }

  void _handleFocusHighlight(final bool value) {
    setState(() {
      _focused = value;
    });
  }

  final contextController = FlyoutController();
  final contextAttachKey = GlobalKey();
  final _focusNode = FocusNode();

  @override
  Widget build(final BuildContext context) {
    return FlyoutTarget(
      controller: contextController,
      child: GestureDetector(
        onDoubleTap: () {
          if (_focused == true) {
            widget.onClick();
          }
        },
        onTap: () {
          _focusNode.requestFocus();
        },
        onSecondaryTapUp: (final d) {
          _focusNode.requestFocus();

          final targetContext = context;
          final box = targetContext.findRenderObject()! as RenderBox;
          final position = box.localToGlobal(
            d.localPosition,
            ancestor: Navigator.of(context).context.findRenderObject(),
          );

          contextController.showFlyout<dynamic>(
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
        child: FocusableActionDetector(
          autofocus: widget.autofocus,
          focusNode: _focusNode,
          actions: _actionMap,
          onShowFocusHighlight: _handleFocusHighlight,
          child: ColoredBox(
            color: _focused
                ? FluentTheme.of(context).accentColor
                : Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: DecoratedBox(
                decoration: _focused
                    ? BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      )
                    : const BoxDecoration(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 14,
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
