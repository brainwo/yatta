part of 'list_item.dart';

class ListItemVideo extends StatelessWidget {
  final String title;
  final String channelTitle;
  final String? description;
  final String? thumbnailUrl;
  final String? publishedAt;
  final String? duration;

  const ListItemVideo({
    required this.title,
    required this.channelTitle,
    required this.description,
    required this.publishedAt,
    this.thumbnailUrl,
    this.duration,
    final Key? key,
  }) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    final timeNow = DateTime.now();
    final description = this.description;
    final publishedAt = this.publishedAt;

    return Row(
      children: [
        _VideoThumbnail(thumbnailUrl: thumbnailUrl, duration: duration),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      channelTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w300),
                    ),
                  ),
                  if (publishedAt != null)
                    Text(
                      ' • ${timeSince(DateTime.parse(publishedAt), timeNow)}',
                      style: const TextStyle(fontWeight: FontWeight.w300),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (description != null && description.isNotEmpty)
                Text(
                  description,
                  style: const TextStyle(fontWeight: FontWeight.w300),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VideoThumbnail extends StatelessWidget {
  const _VideoThumbnail({
    this.thumbnailUrl,
    this.duration,
  });

  final String? thumbnailUrl;
  final String? duration;

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
    final duration = this.duration;

    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: thumbnailUrl != null && thumbnailUrl.isNotEmpty
              ? Image.network(thumbnailUrl,
                  fit: BoxFit.cover,
                  width: 180,
                  height: 100,
                  errorBuilder: (final context, final _, final __) =>
                      _errorThumbnail(context))
              : _errorThumbnail(context),
        ),
        if (duration != null)
          Padding(
            padding: const EdgeInsets.all(2),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 2,
              ),
              child: Text(
                duration,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }
}
