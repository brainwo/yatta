import 'package:fluent_ui/fluent_ui.dart';

import '../../intent.dart';
import '../widget/keyboard_navigation.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FocusNode searchBarFocus = FocusNode();
  late final Map<Type, Action<Intent>> _actionMap;

  @override
  void initState() {
    super.initState();

    _actionMap = {
      SearchBarFocusIntent: CallbackAction<Intent>(
        onInvoke: (final _) => _requestSearchBarFocus(),
      ),
      NavigationPopIntent: CallbackAction<Intent>(
        onInvoke: (final _) => _navigationPop(context),
      )
    };
  }

  void _requestSearchBarFocus() {
    searchBarFocus.requestFocus();
  }

  void _navigationPop(final BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Actions(
      actions: _actionMap,
      child: NavigationView(
        appBar: NavigationAppBar(
            title: TextBox(
          focusNode: searchBarFocus,
          placeholder: 'Search from recent history',
        )),
        content: KeyboardNavigation(
          child: Center(
            child: Column(
              children: [
                const Text('History'),
                Button(
                  autofocus: true,
                  onPressed: () {},
                  child: const Text('Press Me'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
