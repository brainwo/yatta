import 'package:test/test.dart';
import 'package:yatta/helper.dart';

void main() {
  group('All available', () {
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

    const parsedXwinwrap = [
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
    ];
    const parsedKitty = [
      'kitty',
      '@',
      '--to=unix:/tmp/mykitty',
      'set-colors',
      '-a',
      'background=#1f1f1f'
    ];
    const parsedCurl = [
      'curl',
      '--output',
      '/tmp/notifyicon.png',
      'icon.png',
    ];
    const parsedNotifySend = [
      'notify-send',
      '"Playing video"',
      '"This is a title\\nThis is a description"',
    ];

    final helper = (final String command) {
      return parseCommand(
        command,
        url: url,
        title: title,
        description: description,
        type: type,
        preview: preview,
        thumbnail: thumbnail,
        icon: icon,
      );
    };

    test('xwinwrap', () => expect(helper(xwinwrap), parsedXwinwrap));
    test('kitty', () => expect(helper(kitty), parsedKitty));
    test('curl', () => expect(helper(curl), parsedCurl));
    test('notify-send', () => expect(helper(notifySend), parsedNotifySend));
  });

  group('No replacement available', () {
    const xwinwrap =
        'xwinwrap -ov -g 1920x1080 -- mpv -wid WID --profile=wallpaper --input-ipc-server=/tmp/mpvsocket --no-osc \$url';
    const kitty =
        'kitty @ --to=unix:/tmp/mykitty set-colors -a background=#1f1f1f';
    const curl = 'curl --output /tmp/notifyicon.png \$icon';
    const notifySend = 'notify-send "Playing video" "\$title\\n\$description"';

    const parsedXwinwrap = [
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
      '--no-osc'
    ];
    const parsedKitty = [
      'kitty',
      '@',
      '--to=unix:/tmp/mykitty',
      'set-colors',
      '-a',
      'background=#1f1f1f'
    ];
    const parsedCurl = ['curl', '--output', '/tmp/notifyicon.png'];
    const parsedNotifySend = ['notify-send', '"Playing video"', '"\\n"'];

    test('xwinwrap', () => expect(parseCommand(xwinwrap), parsedXwinwrap));
    test('kitty', () => expect(parseCommand(kitty), parsedKitty));
    test('curl', () => expect(parseCommand(curl), parsedCurl));
    test('notify-send', () {
      expect(parseCommand(notifySend), parsedNotifySend);
    });
  });
}
