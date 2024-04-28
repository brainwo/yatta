part of 'list_item.dart';

class ListItemVideo extends StatelessWidget {
  final String title;
  final String channelTitle;
  final String? description;
  final String? thumbnailUrl;
  final String? publishedAt;
  final String duration;

  const ListItemVideo({
    required this.title,
    required this.channelTitle,
    required this.description,
    required this.duration,
    required this.publishedAt,
    final Key? key,
    this.thumbnailUrl,
  }) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    final timeNow = DateTime.now();
    return Row(
      children: [
        if (thumbnailUrl!.isNotEmpty)
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
                  Text(
                    ' • ${timeSince(DateTime.parse(publishedAt!), timeNow)}',
                    style: const TextStyle(fontWeight: FontWeight.w300),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if ((description ?? '').isNotEmpty)
                Text(
                  description!,
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
    required this.thumbnailUrl,
    required this.duration,
  });

  final String? thumbnailUrl;
  final String duration;

  @override
  Widget build(final BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            thumbnailUrl!,
            fit: BoxFit.cover,
            width: 180,
            height: 100,
            errorBuilder: (final _, final __, final ___) => Container(
                width: 180,
                height: 100,
                color: FluentTheme.of(context).inactiveColor),
          ),
        ),
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
