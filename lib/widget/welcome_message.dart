import 'package:fluent_ui/fluent_ui.dart';

class WelcomeMessage extends StatelessWidget {
  const WelcomeMessage({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return const Center(
      child: Text('Hello World'),
    );
  }
}
