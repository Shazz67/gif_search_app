import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer';

class GiphyService {
  final String apiKey = 'x7MAwKtWb0f2sJp8q34gLYvCIBWrGo2M';
  final String baseUrl = 'https://api.giphy.com/v1/gifs';

  Future<List<dynamic>> searchGifs(String query,
      {int offset = 0, int limit = 16}) async {
    log('Calling Giphy API with query: $query, offset: $offset, limit: $limit');

    final response = await http.get(
      Uri.parse(
        '$baseUrl/search?api_key=$apiKey&q=${Uri.encodeQueryComponent(query)}&limit=$limit&offset=$offset',
      ),
    );

    if (response.statusCode == 200) {
      log('API Response received for offset: $offset and limit: $limit');
      final data = json.decode(response.body);
      return data['data'];
    } else {
      log('API Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load GIFs');
    }
  }

  Future<List<dynamic>> getGifsByCategory(String category,
      {int offset = 0, int limit = 16}) async {
    log('Fetching GIFs for category: $category with offset: $offset');

    final endpoint =
        category.toLowerCase() == 'trending' ? 'trending' : 'search';

    final queryParam = category.toLowerCase() == 'trending'
        ? ''
        : '&q=${Uri.encodeQueryComponent(category)}';

    final response = await http.get(
      Uri.parse(
          '$baseUrl/$endpoint?api_key=$apiKey&limit=$limit&offset=$offset$queryParam'),
    );

    if (response.statusCode == 200) {
      log('Category "$category" GIFs fetched successfully');
      final data = json.decode(response.body);
      return data['data'];
    } else {
      log('API Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load GIFs for category: $category');
    }
  }
}
