import 'package:built_collection/built_collection.dart';
import 'package:youtube_search/data/model/search/model_search.dart';
import 'package:youtube_search/data/network/youtube_data_source.dart';

class YoutubeRepository {
  YoutubeDataSource _youtubeDataSource;

  String _lastSearchQuery;
  String _nextPageToken;

  YoutubeRepository(this._youtubeDataSource);

  Future<BuiltList<SearchItem>> searchVideos(String query) async {
    final searchresult = await _youtubeDataSource.searchVideos(query: query);
    _cacheValues(query: query, nextPageToken: searchresult.nextPageToken);
    if (searchresult.items.isEmpty) throw NoSearchResultsException();
    return searchresult.items;
  }

  void _cacheValues({String query, String nextPageToken}) {
    _lastSearchQuery = query;
    _nextPageToken = nextPageToken;
  }

  Future<BuiltList<SearchItem>> fetchNextResultPage() async {
    if (_lastSearchQuery == null) {
      throw SearchNotInitiatedException();
    }

    if (_nextPageToken == null) {
      throw NoNextPageTokenException();
    }

    final nextPageSearchResult = await _youtubeDataSource.searchVideos(
        query: _lastSearchQuery, pageToken: _nextPageToken);

    _cacheValues(
        query: _lastSearchQuery,
        nextPageToken: nextPageSearchResult.nextPageToken);

    return nextPageSearchResult.items;
  }
}

class SearchNotInitiatedException implements Exception {
  final message = "Cannot get the next result page without searching first.";
}

class NoSearchResultsException implements Exception {
  final message = "No results";
}

class NoNextPageTokenException implements Exception {
  final message = "No results";
}
