part of 'list_item.dart';

class ListItemChannel extends StatelessWidget {
  const ListItemChannel({
    required this.channelTitle,
    final Key? key,
    this.thumbnailUrl,
  }) : super(key: key);

  final String channelTitle;
  final String? thumbnailUrl;

  Container _errorThumbnail(final BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      color: FluentTheme.of(context).menuColor,
      child: const Icon(FluentIcons.alert_solid),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final thumbnailUrl = this.thumbnailUrl;

    return Row(
      children: [
        thumbnailUrl != null && thumbnailUrl.isNotEmpty
            ? SizedBox(
                width: 180,
                height: 100,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      thumbnailUrl,
                      width: 100,
                      height: 100,
                      errorBuilder: (final context, final _, final __) =>
                          _errorThumbnail(context),
                    ),
                  ),
                ),
              )
            : _errorThumbnail(context),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(channelTitle),
              const Text(
                'Channel',
                style: TextStyle(fontWeight: FontWeight.w300),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
