import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

class AutoscrollGridView extends StatefulWidget {
  /// Wrapper to [GridView] widget with middle click autoscroll
  AutoscrollGridView({
    super.key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    ScrollController? controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    required this.gridDelegate,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    this.cacheExtent,
    List<Widget> children = const <Widget>[],
    int? semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.autoscrollSpeed = 0.25,
  })  : controller = controller ?? ScrollController(),
        childrenDelegate = SliverChildListDelegate(
          children,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
        ),
        semanticChildCount = semanticChildCount ?? children.length;

  /// Wrapper to [GridView.builder] widget with middle click autoscroll
  AutoscrollGridView.builder({
    super.key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    ScrollController? controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    required this.gridDelegate,
    required final NullableIndexedWidgetBuilder itemBuilder,
    ChildIndexGetter? findChildIndexCallback,
    required final int? itemCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    this.cacheExtent,
    int? semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.autoscrollSpeed = 0.25,
  })  : controller = controller ?? ScrollController(),
        childrenDelegate = SliverChildBuilderDelegate(
          itemBuilder,
          findChildIndexCallback: findChildIndexCallback,
          childCount: itemCount,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
        ),
        semanticChildCount = semanticChildCount ?? itemCount;

  /// Wrapper to [GridView.custom] widget with middle click autoscroll
  AutoscrollGridView.custom({
    super.key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    ScrollController? controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    required this.gridDelegate,
    required this.childrenDelegate,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    this.cacheExtent,
    required this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.autoscrollSpeed = 0.25,
  }) : controller = controller ?? ScrollController();

  /// Wrapper to [GridView.count] widget with middle click autoscroll
  AutoscrollGridView.count({
    super.key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    ScrollController? controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    required int crossAxisCount,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    double childAspectRatio = 1.0,
    List<Widget> children = const <Widget>[],
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    this.cacheExtent,
    int? semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.autoscrollSpeed = 0.25,
  })  : gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: childAspectRatio,
        ),
        childrenDelegate = SliverChildListDelegate(
          children,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
        ),
        controller = controller ?? ScrollController(),
        semanticChildCount = semanticChildCount ?? children.length;

  /// Wrapper to [GridView.extent] widget with middle click autoscroll
  AutoscrollGridView.extent({
    super.key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    ScrollController? controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    required double maxCrossAxisExtent,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    double childAspectRatio = 1.0,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    this.cacheExtent,
    List<Widget> children = const <Widget>[],
    int? semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.autoscrollSpeed = 0.25,
  })  : gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxCrossAxisExtent,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: childAspectRatio,
        ),
        childrenDelegate = SliverChildListDelegate(
          children,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
        ),
        controller = controller ?? ScrollController(),
        semanticChildCount = semanticChildCount ?? children.length;

  final bool reverse;
  final ScrollController controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final SliverGridDelegate gridDelegate;
  final SliverChildDelegate childrenDelegate;
  final Axis scrollDirection;
  final String? restorationId;
  final double? cacheExtent;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final int? semanticChildCount;
  final Clip clipBehavior;
  final double autoscrollSpeed;

  @override
  State<AutoscrollGridView> createState() => _AutoscrollGridViewState();
}

class _AutoscrollGridViewState extends State<AutoscrollGridView> {
  double startPosX = 0;
  double startPosY = 0;
  double posX = 0;
  double posY = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
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
      child: GridView.custom(
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        controller: widget.controller,
        primary: widget.primary,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        padding: widget.padding,
        gridDelegate: widget.gridDelegate,
        childrenDelegate: widget.childrenDelegate,
        cacheExtent: widget.cacheExtent,
        semanticChildCount: widget.semanticChildCount,
        dragStartBehavior: widget.dragStartBehavior,
        keyboardDismissBehavior: widget.keyboardDismissBehavior,
        restorationId: widget.restorationId,
        clipBehavior: widget.clipBehavior,
      ),
    );
  }
}
