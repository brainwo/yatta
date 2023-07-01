import 'package:test/test.dart';
import 'package:yatta/helper.dart';

void main() {
  const url = 'https://youtube.com';
  const title = 'This is a title';
  const description = 'This is a description';
  const type = 'video';
  const preview = 'preview.png';
  const thumbnail = 'thumbnail.png';
  const icon = 'icon.png';

  const xwinwrap =
      'xwinwrap -ov -g 1920x1080 -- mpv -wid WID --profile=wallpaper --input-ipc-server=/tmp/mpvsocket --no-osc \$url';
  const kitty =
      'kitty @ --to=unix:/tmp/mykitty set-colors -a background=#1f1f1f';
  const curl = 'curl --output /tmp/notifyicon.png \$icon';
  const notifySend = 'notify-send "Playing video" "\$title\\n\$description"';

  test('xwinwrap', () {
    expect(
      parseCommand(xwinwrap,
          url: url,
          title: title,
          description: description,
          type: type,
          preview: preview,
          thumbnail: thumbnail,
          icon: icon),
      [
        'xwinwrap',
        '-ov',
        '-g',
        '1920x1080',
        '--',
        'mpv',
        '-wid',
        'WID',
        '--profile=wallpaper',
        '--input-ipc-server=/tmp/mpvsocket',
        '--no-osc',
        'https://youtube.com'
      ],
    );
  });

  test('kitty', () {
    expect(
      parseCommand(kitty,
          url: url,
          title: title,
          description: description,
          type: type,
          preview: preview,
          thumbnail: thumbnail,
          icon: icon),
      [
        'kitty',
        '@',
        '--to=unix:/tmp/mykitty',
        'set-colors',
        '-a',
        'background=#1f1f1f',
      ],
    );
  });

  test('curl', () {
    expect(
      parseCommand(curl,
          url: url,
          title: title,
          description: description,
          type: type,
          preview: preview,
          thumbnail: thumbnail,
          icon: icon),
      [
        'curl',
        '--output',
        '/tmp/notifyicon.png',
        'icon.png',
      ],
    );
  });

  test('notify-send', () {
    expect(
      parseCommand(notifySend,
          url: url,
          title: title,
          description: description,
          type: type,
          preview: preview,
          thumbnail: thumbnail,
          icon: icon),
      [
        'notify-send',
        '"Playing video"',
        '"This is a title\\nThis is a description"',
      ],
    );
  });
}
