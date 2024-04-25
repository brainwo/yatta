import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:youtube_api/src/model/video.dart';
import 'package:youtube_api/src/model/youtube_video.dart';
export 'package:youtube_api/src/model/youtube_video.dart';
import 'package:youtube_api/src/util/_api.dart';
import 'package:youtube_api/src/util/get_duration.dart';

class YoutubeApi {
  String? type;
  String? query;
  String? prevPageToken;
  String? nextPageToken;
  int maxResults;
  late ApiHelper api;
  int page = 0;
  String? regionCode;
  bool? getTrending;
  final headers = {"Accept": "application/json"};
  YoutubeApi(
    String key, {
    this.type,
    this.maxResults = 10,
  }) {
    this.type = type;
    this.maxResults = maxResults;
    api = ApiHelper(key: key, maxResults: this.maxResults, type: this.type);
  }

  Future<List<YoutubeVideo>> getTrends({
    required String regionCode,
  }) async {
    this.regionCode = regionCode;
    this.getTrending = true;
    final url = api.trendingUri(regionCode: regionCode);
    final res = await http.get(url, headers: headers);
    final jsonData = json.decode(res.body);

    if (jsonData['error'] != null) {
      throw jsonData['error']['message'];
    }

    if (jsonData['pageInfo']['totalResults'] == null) return <YoutubeVideo>[];
    final result = await _getResultFromJson(jsonData);

    return result;
  }

  Future<List<YoutubeVideo>> search(
    String query, {
    String type = 'video,channel,playlist',
    String order = 'relevance',
    String videoDuration = 'any',
    String? regionCode,
  }) async {
    this.getTrending = false;
    this.query = query;
    final url = api.searchUri(
      query,
      type: type,
      videoDuration: videoDuration,
      order: order,
      regionCode: regionCode,
    );
    final res = await http.get(url, headers: headers);
    final jsonData = json.decode(res.body);
    if (jsonData['error'] != null) {
      throw jsonData['error']['message'];
    }
    if (jsonData['pageInfo']['totalResults'] == null) return <YoutubeVideo>[];
    final List<YoutubeVideo> result = await _getResultFromJson(jsonData);
    return result;
  }

  Future<List<YoutubeVideo>> channel(String channelId, {String? order}) async {
    this.getTrending = false;
    final url = api.channelUri(channelId, order);
    var res = await http.get(url, headers: headers);
    var jsonData = json.decode(res.body);
    if (jsonData['error'] != null) {
      throw jsonData['error']['message'];
    }
    if (jsonData['pageInfo']['totalResults'] == null) return <YoutubeVideo>[];
    List<YoutubeVideo> result = await _getResultFromJson(jsonData);
    return result;
  }

  /*
  Get video details from video Id
   */
  Future<List<Video>> video(List<String> videoId) async {
    List<Video> result = [];
    final url = api.videoUri(videoId);
    var res = await http.get(url, headers: headers);
    var jsonData = json.decode(res.body);

    if (jsonData == null) return [];

    int total = jsonData['pageInfo']['totalResults'] <
            jsonData['pageInfo']['resultsPerPage']
        ? jsonData['pageInfo']['totalResults']
        : jsonData['pageInfo']['resultsPerPage'];

    for (int i = 0; i < total; i++) {
      result.add(new Video(jsonData['items'][i]));
    }
    return result;
  }

  Future<List<YoutubeVideo>> _getResultFromJson(jsonData) async {
    List<YoutubeVideo>? result = [];
    if (jsonData == null) return [];
    nextPageToken = jsonData['nextPageToken'];
    api.setNextPageToken(nextPageToken);
    int total = jsonData['pageInfo']['totalResults'] <
            jsonData['pageInfo']['resultsPerPage']
        ? jsonData['pageInfo']['totalResults']
        : jsonData['pageInfo']['resultsPerPage'];
    result = await _getListOfYtApis(jsonData, total);
    page = 1;
    return result ?? [];
  }

  Future<List<YoutubeVideo>?> _getListOfYtApis(dynamic data, int total) async {
    List<YoutubeVideo> result = [];
    List<String> videoIdList = [];
    for (int i = 0; i < total; i++) {
      YoutubeVideo ytApiObj =
          YoutubeVideo(data['items'][i], getTrendingVideo: getTrending!);
      if (ytApiObj.kind == "video") videoIdList.add(ytApiObj.id!);
      result.add(ytApiObj);
    }
    List<Video> videoList = await video(videoIdList);
    // TODO: what is this for LMAO
    await Future.forEach(videoList, (Video ytVideo) {
      YoutubeVideo? ytApiObj;
      try {
        ytApiObj = result.firstWhere((ytApi) => ytApi.id == ytVideo.id);
      } catch (_) {
        // catch the error and do nothing, because it already null
      }
      ytApiObj?.duration = getDuration(ytVideo.duration ?? "") ?? "";
    });
    return result;
  }

  Future<List<YoutubeVideo>> nextPage() async {
    this.getTrending = false;
    if (api.nextPageToken == null) return [];
    List<YoutubeVideo>? result = [];
    final Uri url = api.nextPageUri(this.getTrending!);
    final http.Response res = await http.get(url, headers: headers);
    final jsonData = json.decode(res.body);

    if (jsonData['pageInfo']['totalResults'] == null) return <YoutubeVideo>[];

    if (jsonData == null) return <YoutubeVideo>[];

    nextPageToken = jsonData['nextPageToken'];
    prevPageToken = jsonData['prevPageToken'];
    api.setNextPageToken(nextPageToken);
    api.setPrevPageToken(prevPageToken);
    final int total = jsonData['pageInfo']['totalResults'] <
            jsonData['pageInfo']['resultsPerPage']
        ? jsonData['pageInfo']['totalResults']
        : jsonData['pageInfo']['resultsPerPage'];

    if (total == 0) {
      return <YoutubeVideo>[];
    }

    result = await _getListOfYtApis(jsonData, total);
    page++;
    return result ?? [];
  }

  Future<List<YoutubeVideo>?> prevPage() async {
    if (api.prevPageToken == null) return null;
    List<YoutubeVideo> result = [];
    final url = api.prevPageUri(this.getTrending!);
    var res = await http.get(url, headers: headers);
    var jsonData = json.decode(res.body);

    if (jsonData['pageInfo']['totalResults'] == null) return <YoutubeVideo>[];

    if (jsonData == null) return <YoutubeVideo>[];

    nextPageToken = jsonData['nextPageToken'];
    prevPageToken = jsonData['prevPageToken'];
    api.setNextPageToken(nextPageToken!);
    api.setPrevPageToken(prevPageToken!);
    int total = jsonData['pageInfo']['totalResults'] <
            jsonData['pageInfo']['resultsPerPage']
        ? jsonData['pageInfo']['totalResults']
        : jsonData['pageInfo']['resultsPerPage'];
    result = await _getListOfYtApis(jsonData, total) ?? [];
    if (total == 0) {
      return <YoutubeVideo>[];
    }
    page--;
    return result;
  }

  int get getPage => page;
  int get getMaxResults => this.maxResults;
  String? get getQuery => api.query;
  String? get getType => api.type;

  set setKey(String key) => api.key = key;
  set setMaxResults(int maxResults) => this.maxResults = maxResults;
  set setQuery(String query) => api.query = query;
  set setType(String type) => api.type = type;
}
