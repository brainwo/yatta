import 'package:test/test.dart';
import 'package:yatta/helper/tsv.dart';

const String tsv = '''
id\ttype\tprovider\ttitle\tdescription\turl\tviewCount\tchannelId\tchannelTitle\ticonUrl\tthumbnailUrl\tpreviewUrl\tpublishDate\tduration\thistory\tromanized
W2muWA-40Uk\tvideo\tyoutube\t三月のパンタシア 『夜光』\t三月のパンタシア-夜光 小説「さよならの空はあの青い花の輝きとよく似ていた」(みあ著)主題歌 ...\thttps://youtu.be/W2muWA-40Uk\t\tUC4lk0Ob-F3ptOQUUq8s0pzQ\t三月のパンタシア Official YouTube Channel\thttps://i.ytimg.com/vi/W2muWA-40Uk/default.jpg\thttps://i.ytimg.com/vi/W2muWA-40Uk/mqdefault.jpg\thttps://i.ytimg.com/vi/W2muWA-40Uk/hqdefault.jpg\t2021-07-21T13:00:10Z\t03:40\t2021-07-21T13:00:10Z,2022-07-21T13:00:10Z\tsangatsu no phantasia yakou sangatsu no phantasia yakou sousetsu sayonara no sora wa ano aoi hana no kagayaki to yoku nite ita mia cho shudaika''';

void main() {
  group('Parse history', () {
    const parsedTsv = [
      {
        'id': 'W2muWA-40Uk',
        'type': 'video',
        'provider': 'youtube',
        'title': '三月のパンタシア 『夜光』',
        'description': '三月のパンタシア-夜光 小説「さよならの空はあの青い花の輝きとよく似ていた」(みあ著)主題歌 ...',
        'url': 'https://youtu.be/W2muWA-40Uk',
        'viewCount': '',
        'channelId': 'UC4lk0Ob-F3ptOQUUq8s0pzQ',
        'channelTitle': '三月のパンタシア Official YouTube Channel',
        'iconUrl': 'https://i.ytimg.com/vi/W2muWA-40Uk/default.jpg',
        'thumbnailUrl': 'https://i.ytimg.com/vi/W2muWA-40Uk/mqdefault.jpg',
        'previewUrl': 'https://i.ytimg.com/vi/W2muWA-40Uk/hqdefault.jpg',
        'publishDate': '2021-07-21T13:00:10Z',
        'duration': '03:40',
        'history': '2021-07-21T13:00:10Z,2022-07-21T13:00:10Z',
        'romanized': '''
sangatsu no phantasia yakou sangatsu no phantasia yakou sousetsu sayonara no sora wa ano aoi hana no kagayaki to yoku nite ita mia cho shudaika'''
      }
    ];

    test('history', () => expect(loadTsv(tsv), parsedTsv));
  });
}
