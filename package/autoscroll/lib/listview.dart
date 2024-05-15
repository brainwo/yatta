import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class AutoscrollListView extends StatefulWidget {
  /// Wrapper to [ListView] widget with middle click autoscroll
  AutoscrollListView({
    super.key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    ScrollController? controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.itemExtent,
    this.itemExtentBuilder,
    this.prototypeItem,
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
  })  : assert(
          (itemExtent == null && prototypeItem == null) ||
              (itemExtent == null && itemExtentBuilder == null) ||
              (prototypeItem == null && itemExtentBuilder == null),
          'You can only pass one of itemExtent, prototypeItem and itemExtentBuilder.',
        ),
        controller = controller ?? ScrollController(),
        childrenDelegate = SliverChildListDelegate(
          children,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
        ),
        semanticChildCount = semanticChildCount ?? children.length;

  /// Wrapper to [ListView.builder] widget with middle click autoscroll
  AutoscrollListView.builder({
    super.key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    ScrollController? controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.itemExtent,
    this.itemExtentBuilder,
    this.prototypeItem,
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
  })  : assert(itemCount == null || itemCount >= 0),
        assert(semanticChildCount == null || semanticChildCount <= itemCount!),
        assert(
          (itemExtent == null && prototypeItem == null) ||
              (itemExtent == null && itemExtentBuilder == null) ||
              (prototypeItem == null && itemExtentBuilder == null),
          'You can only pass one of itemExtent, prototypeItem and itemExtentBuilder.',
        ),
        controller = controller ?? ScrollController(),
        childrenDelegate = SliverChildBuilderDelegate(
          itemBuilder,
          findChildIndexCallback: findChildIndexCallback,
          childCount: itemCount,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
        ),
        semanticChildCount = semanticChildCount ?? itemCount;

  /// Wrapper to [AutoscrollListView.separated] widget with middle click autoscroll
  AutoscrollListView.separated({
    super.key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    ScrollController? controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    required NullableIndexedWidgetBuilder itemBuilder,
    ChildIndexGetter? findChildIndexCallback,
    required IndexedWidgetBuilder separatorBuilder,
    required int itemCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    this.cacheExtent,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.autoscrollSpeed = 0.25,
  })  : assert(itemCount >= 0),
        controller = controller ?? ScrollController(),
        itemExtent = null,
        itemExtentBuilder = null,
        prototypeItem = null,
        childrenDelegate = SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final int itemIndex = index ~/ 2;
            if (index.isEven) {
              return itemBuilder(context, itemIndex);
            }
            return separatorBuilder(context, itemIndex);
          },
          findChildIndexCallback: findChildIndexCallback,
          childCount: _computeActualChildCount(itemCount),
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
          semanticIndexCallback: (Widget widget, int index) {
            return index.isEven ? index ~/ 2 : null;
          },
        ),
        semanticChildCount = itemCount;

  /// Wrapper to [ListView.custom] widget with middle click autoscroll
  AutoscrollListView.custom({
    super.key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    ScrollController? controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.itemExtent,
    this.itemExtentBuilder,
    this.prototypeItem,
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
  })  : assert(
          (itemExtent == null && prototypeItem == null) ||
              (itemExtent == null && itemExtentBuilder == null) ||
              (prototypeItem == null && itemExtentBuilder == null),
          'You can only pass one of itemExtent, prototypeItem and itemExtentBuilder.',
        ),
        controller = controller ?? ScrollController();

  final bool reverse;
  final ScrollController controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final SliverChildDelegate childrenDelegate;
  final Axis scrollDirection;
  final String? restorationId;
  final double? itemExtent;
  final ItemExtentBuilder? itemExtentBuilder;
  final Widget? prototypeItem;
  final double? cacheExtent;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final int? semanticChildCount;
  final Clip clipBehavior;
  final double autoscrollSpeed;

  // Helper method to compute the actual child count for the separated constructor.
  static int _computeActualChildCount(int itemCount) {
    return math.max(0, itemCount * 2 - 1);
  }

  @override
  State<AutoscrollListView> createState() => _AutoscrollListViewState();
}

class _AutoscrollListViewState extends State<AutoscrollListView> {
  double startPosX = 0;
  double startPosY = 0;
  double posX = 0;
  double posY = 0;

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
      child: ListView.custom(
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        controller: widget.controller,
        primary: widget.primary,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        padding: widget.padding,
        itemExtent: widget.itemExtent,
        prototypeItem: widget.prototypeItem,
        itemExtentBuilder: widget.itemExtentBuilder,
        childrenDelegate: widget.childrenDelegate,
        cacheExtent: widget.cacheExtent,
        semanticChildCount: widget.semanticChildCount,
        dragStartBehavior: widget.dragStartBehavior,
        keyboardDismissBehavior: widget.keyboardDismissBehavior,
        restorationId: widget.restorationId,
      ),
    );
  }
}
