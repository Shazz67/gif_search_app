import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gif_search_app/data/giphy_service.dart'; // Replace with your app's import path

@GenerateNiceMocks([MockSpec<http.Client>()])
import 'giphy_service_test.mocks.dart';

void main() {
  group('GiphyService', () {
    late GiphyService giphyService;
    late MockClient mockHttpClient; // from giphy_service_test.mocks.dart

    setUp(() {
      mockHttpClient = MockClient();
      giphyService = GiphyService(client: mockHttpClient);
    });

    test('searchGifs returns data on valid response', () async {
      // Arrange
      const query = 'funny';
      const mockResponse = {
        "data": [
          {"id": "1", "url": "http://giphy.com/gif1"},
          {"id": "2", "url": "http://giphy.com/gif2"}
        ]
      };
      final uri = Uri.parse(
        'https://api.giphy.com/v1/gifs/search?api_key=x7MAwKtWb0f2sJp8q34gLYvCIBWrGo2M&q=funny&limit=16&offset=0',
      );

      // Stub the mock client
      when(mockHttpClient.get(uri)).thenAnswer(
        (_) async => http.Response(json.encode(mockResponse), 200),
      );

      // Act
      final results = await giphyService.searchGifs(query);

      // Assert
      expect(results.length, 2);
      expect(results[0]['id'], '1');
    });

    test('searchGifs throws exception on non-200 response', () async {
      // Arrange
      final uri = Uri.parse(
        'https://api.giphy.com/v1/gifs/search?api_key=x7MAwKtWb0f2sJp8q34gLYvCIBWrGo2M&q=funny&limit=16&offset=0',
      );

      // Stub the mock client
      when(mockHttpClient.get(uri)).thenAnswer(
        (_) async => http.Response('Error', 500),
      );

      // Act & Assert
      expect(
        () async => await giphyService.searchGifs('funny'),
        throwsException,
      );
    });

    test('getGifsByCategory returns data on valid response', () async {
      // Arrange
      const category = 'Trending';
      const mockResponse = {
        "data": [
          {"id": "3", "url": "http://giphy.com/gif3"},
          {"id": "4", "url": "http://giphy.com/gif4"}
        ]
      };
      final uri = Uri.parse(
        'https://api.giphy.com/v1/gifs/trending?api_key=x7MAwKtWb0f2sJp8q34gLYvCIBWrGo2M&limit=16&offset=0',
      );

      // Stub the mock client
      when(mockHttpClient.get(uri)).thenAnswer(
        (_) async => http.Response(json.encode(mockResponse), 200),
      );

      // Act
      final results = await giphyService.getGifsByCategory(category);

      // Assert
      expect(results.length, 2);
      expect(results[0]['id'], '3');
    });

    test('getGifsByCategory throws exception on non-200 response', () async {
      // Arrange
      final uri = Uri.parse(
        'https://api.giphy.com/v1/gifs/trending?api_key=x7MAwKtWb0f2sJp8q34gLYvCIBWrGo2M&limit=16&offset=0',
      );

      // Stub the mock client
      when(mockHttpClient.get(uri)).thenAnswer(
        (_) async => http.Response('Error', 404),
      );

      // Act & Assert
      expect(
        () async => await giphyService.getGifsByCategory('Trending'),
        throwsException,
      );
    });
  });
}
