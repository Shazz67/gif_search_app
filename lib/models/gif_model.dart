import 'package:english_words/english_words.dart';

class GifModel {
  final String id;
  final String title;
  final GifImage images;
  final String? source;
  final GifUser? user;
  final List<String> tags;

  GifModel({
    required this.id,
    required this.title,
    required this.images,
    this.source,
    this.user,
    required this.tags,
  });

  factory GifModel.fromJson(Map<String, dynamic> json) {
    List<String> inferTags(String? title, String? slug) {
      final keywords = <String>[];
      if (title != null) {
        final cleanTitle = title.split(' by ')[0];
        keywords.addAll(cleanTitle.split(' '));
      }
      if (slug != null) {
        keywords.addAll(slug.split('-'));
      }

      final validWords = all.map((word) => word.toLowerCase()).toSet();

      const excludedWords = {
        'and',
        'the',
        'what',
        'is',
        'in',
        'on',
        'at',
        'for',
        'to',
        'with',
        'of',
        'by',
        'a',
        'an',
        'it',
        'as',
        'be',
        'was',
        'are',
        'this',
        'that',
        'or',
        'but',
        'not'
      };

      return keywords
          .map((tag) => tag.toLowerCase())
          .where((tag) =>
              validWords.contains(tag) &&
              tag.length > 2 &&
              !excludedWords.contains(tag))
          .toSet()
          .toList();
    }

    return GifModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      images: GifImage.fromJson(json['images']),
      source: json['source'],
      user: json['user'] != null ? GifUser.fromJson(json['user']) : null,
      tags: inferTags(json['title'], json['slug']),
    );
  }
}

class GifImage {
  final GifFixedHeight fixedHeight;
  final GifOriginal original;

  GifImage({
    required this.fixedHeight,
    required this.original,
  });

  factory GifImage.fromJson(Map<String, dynamic> json) {
    return GifImage(
      fixedHeight: GifFixedHeight.fromJson(json['fixed_height']),
      original: GifOriginal.fromJson(json['original']),
    );
  }
}

class GifUser {
  final String username;
  final String displayName;
  final String profileUrl;
  final String avatarUrl;

  GifUser({
    required this.username,
    required this.displayName,
    required this.profileUrl,
    required this.avatarUrl,
  });

  factory GifUser.fromJson(Map<String, dynamic> json) {
    return GifUser(
      username: json['username'] ?? '',
      displayName: json['display_name'] ?? '',
      profileUrl: json['profile_url'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
    );
  }
}

class GifFixedHeight {
  final String url;

  GifFixedHeight({required this.url});

  factory GifFixedHeight.fromJson(Map<String, dynamic> json) {
    return GifFixedHeight(
      url: json['url'] ?? '',
    );
  }
}

class GifOriginal {
  final String url;
  final int? width;
  final int? height;

  GifOriginal({required this.url, this.width, this.height});

  factory GifOriginal.fromJson(Map<String, dynamic> json) {
    return GifOriginal(
      url: json['url'] ?? '',
      width: json['width'] != null ? int.tryParse(json['width']) : null,
      height: json['height'] != null ? int.tryParse(json['height']) : null,
    );
  }
}
