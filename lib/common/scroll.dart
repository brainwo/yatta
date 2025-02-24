import 'package:auto_scrolling/auto_scrolling.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

class AppScrollBehavior extends FluentScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {PointerDeviceKind.touch};

  Widget _defaultAutoScroll(
    final Widget child,
    final Axis axis,
    final ScrollController? controller,
  ) =>
      AutoScroll(
        controller: controller,
        scrollDirection: axis,
        anchorBuilder: (final _) => SingleDirectionAnchor(
          direction: axis,
        ),
        child: child,
      );

  @override
  Widget buildScrollbar(
    final BuildContext context,
    final Widget child,
    final ScrollableDetails details,
  ) {
    final axis = axisDirectionToAxis(details.direction);

    switch (getPlatform(context)) {
      case TargetPlatform.macOS:
      case TargetPlatform.iOS:
        return _defaultAutoScroll(
          switch (axis) {
            Axis.horizontal => child,
            Axis.vertical => CupertinoScrollbar(
                controller: details.controller,
                child: child,
              ),
          },
          axis,
          details.controller,
        );
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return _defaultAutoScroll(
          switch (axis) {
            Axis.horizontal => child,
            Axis.vertical => Scrollbar(
                controller: details.controller,
                child: child,
              ),
          },
          axis,
          details.controller,
        );
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return child;
    }
  }
}
