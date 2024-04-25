import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';

class AutoscrollSingleChildScrollView extends StatefulWidget {
  AutoscrollSingleChildScrollView({
    super.key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.padding,
    this.primary,
    this.physics,
    ScrollController? controller,
    this.child,
    this.dragStartBehavior = DragStartBehavior.start,
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.autoscrollSpeed = 0.25,
  })  : assert(
          !(controller != null && (primary ?? false)),
          'Primary ScrollViews obtain their ScrollController via inheritance '
          'from a PrimaryScrollController widget. You cannot both set primary to '
          'true and pass an explicit controller.',
        ),
        controller = controller ?? ScrollController();

  final Axis scrollDirection;
  final bool reverse;
  final EdgeInsetsGeometry? padding;
  final ScrollController controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final Widget? child;
  final DragStartBehavior dragStartBehavior;
  final Clip clipBehavior;
  final String? restorationId;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final double autoscrollSpeed;

  @override
  State<AutoscrollSingleChildScrollView> createState() =>
      _AutoscrollSingleChildScrollViewState();
}

class _AutoscrollSingleChildScrollViewState
    extends State<AutoscrollSingleChildScrollView> {
  double startPosX = 0;
  double startPosY = 0;
  double posX = 0;
  double posY = 0;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (final event) {
        startPosX = event.position.dx;
        startPosY = event.position.dy;
      },
      onPointerUp: (final _) {
        setState(() {
          startPosX = 0;
          startPosY = 0;
          posX = 0;
          posY = 0;
        });
      },
      onPointerMove: (final event) async {
        if (event.buttons != 4) return;
        setState(() {
          posX = event.position.dx;
          posY = event.position.dy;
        });
        switch (widget.scrollDirection) {
          case Axis.horizontal:
            widget.controller.position.moveTo(
                widget.controller.position.pixels -
                    (startPosX - event.position.dx) * widget.autoscrollSpeed);
          case Axis.vertical:
            widget.controller.position.moveTo(
                widget.controller.position.pixels -
                    (startPosY - event.position.dy) * widget.autoscrollSpeed);
        }
      },
      child: SingleChildScrollView(
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        padding: widget.padding,
        primary: widget.primary,
        physics: widget.physics,
        controller: widget.controller,
        dragStartBehavior: widget.dragStartBehavior,
        clipBehavior: widget.clipBehavior,
        restorationId: widget.restorationId,
        keyboardDismissBehavior: widget.keyboardDismissBehavior,
        child: widget.child,
      ),
    );
  }
}
