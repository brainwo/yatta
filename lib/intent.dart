import 'package:flutter/widgets.dart';
import 'main.dart' show HomePage; // only used for documentation

/// An Intent to move focus into a search bar of a page.
/// The search bar used for this intent must serve the main functionality of
/// the screen. If there are multiple search bar present in one screen, this
/// should be only used on the search bar that is more important and relevant
/// to the context.
///
/// For example, the [HomePage] search bar located at the top.
class SearchBarFocusIntent extends Intent {
  const SearchBarFocusIntent();
}

class NavigationPopIntent extends Intent {
  const NavigationPopIntent();
}
