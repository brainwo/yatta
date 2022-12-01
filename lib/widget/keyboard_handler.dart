import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../const.dart';
import '../helper.dart';
import '../main.dart';

class KeyboardHandler extends StatelessWidget {
  const KeyboardHandler({
    required this.scrollItemFocus,
    required this.searchBoxFocus,
    required this.scrollviewController,
    required this.selectedVideo,
    required this.child,
    final Key? key,
  }) : super(key: key);

  final FocusNode scrollItemFocus;
  final FocusNode searchBoxFocus;
  final ScrollController scrollviewController;
  final ValueNotifier<int?> selectedVideo;
  final Widget child;

  @override
  Widget build(final BuildContext context) {
    return KeyboardListener(
        focusNode:
            FocusNode(onKey: (final FocusNode node, final RawKeyEvent event) {
          switch (event.logicalKey.keyLabel) {
            case 'Tab':
              node.requestFocus(scrollItemFocus);
              return KeyEventResult.handled;
            case 'L':
              if (!searchBoxFocus.hasFocus && event.isControlPressed) {
                node.requestFocus(searchBoxFocus);
                return KeyEventResult.handled;
              }
              break;
            case '/':
              if (!searchBoxFocus.hasFocus) {
                node.requestFocus(searchBoxFocus);
                return KeyEventResult.handled;
              }
              break;
            case 'Home':
            case 'Page Up':
              scrollviewController.jumpTo(0.0);
              return KeyEventResult.handled;
            case 'End':
            case 'Page Down':
              scrollviewController
                  .jumpTo(scrollviewController.position.maxScrollExtent);
              return KeyEventResult.handled;
            case 'J':
              if (!searchBoxFocus.hasFocus &&
                  scrollviewController.positions.isNotEmpty) {
                scrollviewController
                    .jumpTo(scrollviewController.offset + scrollAmount);
                if (event.isKeyPressed(LogicalKeyboardKey.keyJ) &&
                        ((selectedVideo.value ?? 0) < 9) ||
                    selectedVideo.value == null) {
                  selectedVideo.value = (selectedVideo.value ?? -1) + 1;
                }
                return KeyEventResult.handled;
              }
              break;
            case 'K':
              if (!searchBoxFocus.hasFocus &&
                  scrollviewController.positions.isNotEmpty) {
                scrollviewController
                    .jumpTo(scrollviewController.offset - scrollAmount);
                if (event.isKeyPressed(LogicalKeyboardKey.keyK) &&
                    (selectedVideo.value ?? -1) > 0) {
                  selectedVideo.value = (selectedVideo.value ?? 1) - 1;
                }
                return KeyEventResult.handled;
              }
              break;
          }
          if (event.isKeyPressed(LogicalKeyboardKey.enter) &&
              result.isNotEmpty) {
            processVideo(result[selectedVideo.value!]);
          }
          return KeyEventResult.ignored;
        }),
        child: child);
  }
}
