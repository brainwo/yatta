part of search_result;

class _ListItemChannel extends StatelessWidget {
  final String channelTitle;
  final String? thumbnailUrl;

  const _ListItemChannel({
    required this.channelTitle,
    final Key? key,
    this.thumbnailUrl,
  }) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return Row(
      children: [
        if (thumbnailUrl!.isNotEmpty)
          SizedBox(
            width: 180,
            height: 100,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  thumbnailUrl!,
                  width: 100,
                  height: 100,
                  errorBuilder: (final _, final __, final ___) => Container(
                      width: 180,
                      height: 100,
                      color: FluentTheme.of(context).inactiveColor),
                ),
              ),
            ),
          ),
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
