import 'dart:io';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';
import 'package:youtube_search/data/model/search/model_search.dart';
import 'package:youtube_search/data/network/api_key.dart';
import 'package:youtube_search/data/network/youtube_data_source.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  String fixture(String name) =>
      File('test/data/fixtures/$name.json').readAsStringSync();

  MockClient mockClient;
  YoutubeDataSource dataSource;

  setUp(() {
    mockClient = MockClient();
    dataSource = YoutubeDataSource(mockClient);
  });

  group('searchVideos', () {
    test(
      'returns YoutubeSearchResult when the call completes successfully',
      () async {
        when(
          mockClient.get(
            argThat(
              startsWith('https://www.googleapis.com/youtube/v3/search'),
            ),
          ),
        ).thenAnswer(
          (_) async => http.Response(
                fixture('search_result'),
                200,
                headers: {'content-type': 'application/json; charset=utf-8'},
              ),
        );

        YoutubeSearchResult result = await dataSource.searchVideos(
          query: 'resocoder',
          pageToken: 'abcd',
        );

        expect(result, TypeMatcher<YoutubeSearchResult>());
        expect(result.items.length, 2);
        expect(result.items[0].snippet.title,
            startsWith('Android Kotlin: Forecast App 01'));
      },
    );

    test('throws an error on bad request', () async {
      when(
        mockClient.get(
          argThat(
            startsWith('https://www.googleapis.com/youtube/v3/search'),
          ),
        ),
      ).thenAnswer(
        (_) async => http.Response(fixture('error'), 400),
      );

      expect(
        () => dataSource.searchVideos(
              query: 'resocoder',
              pageToken: 'abcd',
            ),
        throwsA(TypeMatcher<YoutubeSearchError>()),
      );
    });

    test('makes an HTTP request to a proper URL', () {
      when(
        mockClient.get(
          argThat(
            startsWith('https://www.googleapis.com/youtube/v3/search'),
          ),
        ),
      ).thenAnswer(
        (_) async => http.Response(
              fixture('search_result'),
              200,
              headers: {'content-type': 'application/json; charset=utf-8'},
            ),
      );

      dataSource.searchVideos(query: 'resocoder');
      dataSource.searchVideos(query: 'resocoder', pageToken: 'abcd');
      dataSource.searchVideos(query: 'cute cat');

      verifyInOrder([
        mockClient.get(argThat(
          allOf(
            startsWith('https://www.googleapis.com/youtube/v3/search'),
            contains('part=snippet'),
            contains('maxResults=5'),
            contains('q=resocoder'),
            contains('type=video'),
            contains('key=$API_KEY'),
            isNot(contains('pageToken')),
          ),
        )),
        mockClient.get(argThat(
          allOf(
            startsWith('https://www.googleapis.com/youtube/v3/search'),
            contains('q=resocoder'),
            contains('pageToken=abcd'),
          ),
        )),
        mockClient.get(argThat(
          allOf(
            startsWith('https://www.googleapis.com/youtube/v3/search'),
            contains('q=cute%20cat'),
          ),
        )),
      ]);
    });
  });

  /* group('fetchVideo', () { 
    test(
      'returns YoutubeVideoResponse when the call completes successfully',
      () async {
        when(
          mockClient.get(
            startsWith('https://www.googleapis.com/youtube/v3/videos'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
                fixture('video_response'),
                200,
                headers: {'content-type': 'application/json; charset=UTF-8'},
              ),
        );

        YoutubeVideoResponse response =
            await dataSource.fetchVideoInfo(id: 'L_bxFljD6AI');

        expect(response, TypeMatcher<YoutubeVideoResponse>());
        expect(response.items.length, 1);
        expect(response.items[0].id, 'L_bxFljD6AI');

        verify(mockClient.get(
          argThat(
            allOf(
              startsWith('https://www.googleapis.com/youtube/v3/videos'),
              contains('id=L_bxFljD6AI'),
              contains('key=$API_KEY'),
            ),
          ),
        ));
      },
    );

    test('throws a YoutubeVideoError on a bad request', () {
      when(
        mockClient.get(
          argThat(
            startsWith('https://www.googleapis.com/youtube/v3/videos'),
          ),
        ),
      ).thenAnswer(
        (_) async => http.Response(fixture('error'), 400),
      );

      expect(
        () => dataSource.fetchVideoInfo(id: 'abcd'),
        throwsA(TypeMatcher<YoutubeVideoError>()),
      );
    });

    test('makes HTTP requests to proper URLs', () {
      when(
        mockClient.get(
          startsWith('https://www.googleapis.com/youtube/v3/videos'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
              fixture('video_response'),
              200,
              headers: {'content-type': 'application/json; charset=UTF-8'},
            ),
      );

      dataSource.fetchVideoInfo(id: 'abcd');
      dataSource.fetchVideoInfo(id: 'efgh');

      verifyInOrder([
        mockClient.get(
          argThat(
            allOf(
              startsWith('https://www.googleapis.com/youtube/v3/videos'),
              contains('id=abcd'),
              contains('key=$API_KEY'),
            ),
          ),
        ),
        mockClient.get(
          argThat(
            allOf(
              startsWith('https://www.googleapis.com/youtube/v3/videos'),
              contains('id=efgh'),
              contains('key=$API_KEY'),
            ),
          ),
        ),
      ]);
    });
  });*/
}
