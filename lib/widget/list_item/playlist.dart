import 'package:fluent_ui/fluent_ui.dart';

import '../../string/en_us.dart';

class ListItemPlaylist extends StatelessWidget {
  final String title;
  final String channelTitle;
  final String? description;
  final String? thumbnailUrl;
  final void Function()? onClick;

  const ListItemPlaylist({
    Key? key,
    required this.title,
    required this.channelTitle,
    required this.description,
    required this.onClick,
    this.thumbnailUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 32.0,
          vertical: 16.0,
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.centerRight,
              children: [
                if ((thumbnailUrl ?? '').isNotEmpty)
                  Image.network(
                    thumbnailUrl!,
                    width: 180,
                    height: 100,
                  ),
                Container(
                  width: 60,
                  height: 100,
                  color: const Color.fromRGBO(0, 0, 0, 0.65),
                  child: const Icon(FluentIcons.playlist_music),
                )
              ],
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  Text(
                    channelTitle,
                    style: const TextStyle(fontWeight: FontWeight.w300),
                  ),
                  if (description!.isNotEmpty)
                    Text(
                      description!,
                      style: const TextStyle(fontWeight: FontWeight.w300),
                    ),
                   const Text(
                    AppString.playlist,
                    style: TextStyle(fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
