import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';

import '../locale/en_us.dart';

// TODO: use Regex to match known errors
// YouTube Data API v3 has not been used in project 144809266352 before or it is disabled. Enable it by visiting https://console.developers.google.com/apis/api/youtube.googleapis.com/overview?project=144809266352 then retry. If you enabled this API recently, wait a few minutes for the action to propagate to our systems and retry.

class SearchError extends StatelessWidget {
  final String errorText;

  const SearchError({
    required this.errorText,
    super.key,
  });

  Future<void> _handleCopyToClipboard(final BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: errorText));

    if (context.mounted) {
      await displayInfoBar(context, builder: (final context, final close) {
        return InfoBar(
          title: const Text('Copied'),
          content: const Text('Error details copied to clipboard'),
          action: IconButton(
            icon: const Icon(FluentIcons.clear),
            onPressed: close,
          ),
          severity: InfoBarSeverity.info,
        );
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 64),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            FluentIcons.unavailable_offline,
            size: 64,
          ),
          const SizedBox(height: 8),
          Text(
            AppString.errorTitle,
            style: FluentTheme.of(context).typography.title,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          const Text('Error details: '),
          const SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextBox(
                    readOnly: true,
                    minLines: 1,
                    maxLines: 4,
                    controller: TextEditingController()..text = errorText,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 36,
                  child: Tooltip(
                    message: 'Copy to clipboard',
                    child: Button(
                      child: const Icon(FluentIcons.copy),
                      onPressed: () async => _handleCopyToClipboard(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
