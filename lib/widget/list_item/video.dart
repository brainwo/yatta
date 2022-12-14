import 'package:fluent_ui/fluent_ui.dart';

class ListItemVideo extends StatelessWidget {
  final String title;
  final String channelTitle;
  final String? description;
  final String? thumbnailUrl;
  final void Function()? onClick;
  final String duration;

  const ListItemVideo({
    required this.title,
    required this.channelTitle,
    required this.description,
    required this.duration,
    required this.onClick,
    final Key? key,
    this.thumbnailUrl,
  }) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 32.0,
          vertical: 16.0,
        ),
        child: Row(
          children: [
            if (thumbnailUrl!.isNotEmpty)
              Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: [
                  Image.network(
                    thumbnailUrl!,
                    width: 180,
                    height: 100,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ColoredBox(
                      color: Colors.black,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 2.0,
                        ),
                        child: Text(
                          duration,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
