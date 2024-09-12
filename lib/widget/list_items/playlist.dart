part of 'list_item.dart';

class ListItemPlaylist extends StatelessWidget {
  final String title;
  final String channelTitle;
  final String? description;
  final String? thumbnailUrl;

  const ListItemPlaylist({
    required this.title,
    required this.channelTitle,
    required this.description,
    final Key? key,
    this.thumbnailUrl,
  }) : super(key: key);

  Container _errorThumbnail(final BuildContext context) {
    return Container(
      width: 180,
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
        Stack(
          alignment: Alignment.centerRight,
          children: [
            thumbnailUrl != null && thumbnailUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      thumbnailUrl,
                      width: 180,
                      height: 100,
                      errorBuilder: (final context, final _, final __) =>
                          _errorThumbnail(context),
                    ),
                  )
                : _errorThumbnail(context),
            Container(
              width: 60,
              height: 100,
              color: const Color.fromRGBO(0, 0, 0, 0.65),
              child: const Icon(
                FluentIcons.playlist_music,
                color: Colors.white,
              ),
            )
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              Text(
                channelTitle,
                style: const TextStyle(fontWeight: FontWeight.w300),
              ),
              if (description?.isNotEmpty ?? false)
                Text(
                  description!,
                  maxLines: 2,
                  style: const TextStyle(fontWeight: FontWeight.w300),
                ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)?.playlist ?? '',
                style: const TextStyle(fontWeight: FontWeight.w300),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
