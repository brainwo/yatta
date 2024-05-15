import 'package:fluent_ui/fluent_ui.dart';

class ChoiceChip extends StatefulWidget {
  const ChoiceChip({
    required this.selected,
    required this.label,
    required this.onSelected,
  });

  final bool selected;
  final Widget label;
  final void Function(bool) onSelected;

  @override
  State<ChoiceChip> createState() => _ChoiceChipState();
}

class _ChoiceChipState extends State<ChoiceChip> {
  late final fluentTheme = FluentTheme.of(context);
  bool _focused = false;
  bool _hovered = false;

  @override
  Widget build(final BuildContext context) {
    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowFocusHighlight: (final value) => setState(() => _focused = value),
      onShowHoverHighlight: (final value) => setState(() => _hovered = value),
      child: GestureDetector(
        onTap: () => widget.onSelected(!widget.selected),
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: widget.selected
                ? fluentTheme.accentColor
                : _hovered
                    ? Colors.white.withOpacity(0.1)
                    : const Color.fromRGBO(158, 160, 165, 0),
            shape: StadiumBorder(
              side: BorderSide(
                width: _focused ? 2 : 1,
                color: widget.selected && !_focused
                    ? fluentTheme.accentColor
                    : const Color.fromRGBO(158, 160, 165, 1),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(child: widget.label),
          ),
        ),
      ),
    );
  }
}
