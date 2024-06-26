import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';

/// Wrap a widget inside this widget to add modal navigation when
/// a widget inside this is focused
class KeyboardNavigation extends StatelessWidget {
  final Widget child;

  /// By default, this widget comes with [DirectionalFocusAction],
  /// to add more actions, use this property. No need more [Actions].
  final Map<Type, Action<Intent>>? additionalActions;

  final Map<ShortcutActivator, Intent>? additionalShortcuts;

  const KeyboardNavigation({
    required this.child,
    super.key,
    this.additionalActions,
    this.additionalShortcuts,
  });

  @override
  Widget build(final BuildContext context) {
    return Actions(
      actions: {
        DirectionalFocusIntent: DirectionalFocusAction(),
        ...?additionalActions
      },
      child: Shortcuts(
        shortcuts: {
          const SingleActivator(
            LogicalKeyboardKey.keyH,
          ): const DirectionalFocusIntent(TraversalDirection.left),
          const SingleActivator(
            LogicalKeyboardKey.keyJ,
          ): const DirectionalFocusIntent(TraversalDirection.down),
          const SingleActivator(
            LogicalKeyboardKey.keyK,
          ): const DirectionalFocusIntent(TraversalDirection.up),
          const SingleActivator(LogicalKeyboardKey.keyL):
              const DirectionalFocusIntent(TraversalDirection.right),
          ...?additionalShortcuts,
        },
        child: child,
      ),
    );
  }
}
