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

  @override
  Widget build(final BuildContext context) {
    return Row(
      children: [
        Stack(
          alignment: Alignment.centerRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                thumbnailUrl!,
                width: 180,
                height: 100,
                errorBuilder: (final _, final __, final ___) => Container(
                    width: 180,
                    height: 100,
                    color: FluentTheme.of(context).inactiveColor),
              ),
            ),
            Container(
              width: 60,
              height: 100,
              color: const Color.fromRGBO(0, 0, 0, 0.65),
              child: const Icon(FluentIcons.playlist_music),
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
              const Text(
                AppString.playlist,
                style: TextStyle(fontWeight: FontWeight.w300),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
