import 'package:flutter/widgets.dart';

class ListItemChannel extends StatelessWidget {
  final String channelTitle;
  final String? thumbnailUrl;
  final void Function()? onClick;

  const ListItemChannel({
    Key? key,
    required this.channelTitle,
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
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(channelTitle),
                  const Text(
                    "channel",
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
