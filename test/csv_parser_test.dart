import 'package:test/test.dart';
import 'package:yatta/util/csv_parser.dart';

const String csv = '''
id,type,provider,title,description,url,viewCount,channelId,channelTitle,iconUrl,thumbnailUrl,previewUrl,publishDate,duration,history,romanized
W2muWA-40Uk,video,youtube,三月のパンタシア 『夜光』,三月のパンタシア-夜光 小説「さよならの空はあの青い花の輝きとよく似ていた」(みあ著)主題歌 ...,https://youtu.be/W2muWA-40Uk,,UC4lk0Ob-F3ptOQUUq8s0pzQ,三月のパンタシア Official YouTube Channel,https://i.ytimg.com/vi/W2muWA-40Uk/default.jpg,https://i.ytimg.com/vi/W2muWA-40Uk/mqdefault.jpg,https://i.ytimg.com/vi/W2muWA-40Uk/hqdefault.jpg,2021-07-21T13:00:10Z,03:40,"2021-07-21T13:00:10Z,2022-07-21T13:00:10Z",sangatsu no phantasia yakou sangatsu no phantasia yakou sousetsu sayonara no sora wa ano aoi hana no kagayaki to yoku nite ita mia cho shudaika''';

void main() {
  group('Parse history', () {
    const parsedCsv = [
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

    test(
      'history',
      () => expect(const CsvParser().parse(csv.split('\n')), parsedCsv),
    );
  });
}
