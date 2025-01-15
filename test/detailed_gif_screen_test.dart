import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:gif_search_app/screens/detailed_gif_screen.dart';
import 'package:gif_search_app/models/gif_model.dart';
import 'package:gif_search_app/services/giphy_service.dart';
import 'package:gif_search_app/widgets/shared/gif_grid_item.dart';
import 'detailed_gif_screen_test.mocks.dart';
import 'package:gif_search_app/providers/providers.dart';
import 'package:visibility_detector/visibility_detector.dart';

@GenerateNiceMocks([MockSpec<GiphyService>()])
void main() {
  late MockGiphyService mockGiphyService;
  late ProviderContainer container;

  setUp(() {
    mockGiphyService = MockGiphyService();
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    container = ProviderContainer(
      overrides: [
        giphyServiceProvider.overrideWithValue(mockGiphyService),
        // Mock the connectivity provider to always return true
        connectivityProvider.overrideWith((ref) => Stream.value(true)),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  Future<void> pumpDetailedGifScreen(WidgetTester tester, GifModel gif) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          onGenerateRoute: (settings) {
            if (settings.name == '/home') {
              final tag = settings.arguments as String?;
              return MaterialPageRoute(
                builder: (_) => Scaffold(body: Text('Tag: $tag')),
              );
            }
            return null;
          },
          home: DetailedGifScreen(gif: gif),
        ),
      ),
    );
    // Initial frame
    await tester.pump();
    // Wait for animations
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('displays related GIFs', (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      final gif = GifModel(
        id: 'test-id',
        title: 'Test GIF',
        images: GifImage(
          original: GifOriginal(url: 'https://example.com/original.gif'),
          fixedHeight:
              GifFixedHeight(url: 'https://example.com/fixed-height.gif'),
        ),
        user: null,
        source: 'Test Source',
        tags: ['test', 'gif'],
      );

      when(mockGiphyService.searchGifs(any, offset: anyNamed('offset')))
          .thenAnswer((_) async => [
                {
                  'id': 'related-id-1',
                  'title': 'Related GIF 1',
                  'images': {
                    'fixed_height': {'url': 'https://example.com/related1.gif'},
                    'original': {
                      'url': 'https://example.com/related1-original.gif'
                    }
                  },
                  'user': null
                },
                {
                  'id': 'related-id-2',
                  'title': 'Related GIF 2',
                  'images': {
                    'fixed_height': {'url': 'https://example.com/related2.gif'},
                    'original': {
                      'url': 'https://example.com/related2-original.gif'
                    }
                  },
                  'user': null
                }
              ]);

      await pumpDetailedGifScreen(tester, gif);

      // Wait for async operations
      await tester.pump(const Duration(seconds: 1));

      // Verify the UI displays the two related GIFs
      expect(find.byType(GifGridItem), findsNWidgets(2));
    });
  });

  testWidgets('clicking a tag navigates to HomeScreen with tag argument',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      final gif = GifModel(
        id: 'test-id',
        title: 'Test GIF',
        images: GifImage(
          original: GifOriginal(url: 'https://example.com/original.gif'),
          fixedHeight:
              GifFixedHeight(url: 'https://example.com/fixed-height.gif'),
        ),
        user: null,
        source: 'Test Source',
        tags: ['funny'],
      );

      await pumpDetailedGifScreen(tester, gif);

      // Tap the first tag
      await tester.tap(find.text('funny').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify navigation and correct tag is passed
      expect(find.text('Tag: funny'), findsOneWidget);
    });
  });

  testWidgets('displays user details if available',
      (WidgetTester tester) async {
    final gif = GifModel(
      id: 'test-id',
      title: 'Test GIF',
      images: GifImage(
        original: GifOriginal(url: 'https://example.com/original.gif'),
        fixedHeight:
            GifFixedHeight(url: 'https://example.com/fixed-height.gif'),
      ),
      user: GifUser(
        username: 'testuser',
        displayName: 'Test User',
        profileUrl: 'https://example.com/profile',
        avatarUrl: 'https://example.com/avatar.jpg',
      ),
      source: null,
      tags: [],
    );

    await pumpDetailedGifScreen(tester, gif);

    // Verify user details are displayed
    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('@testuser'), findsOneWidget);
    expect(find.byType(CircleAvatar), findsOneWidget);
  });

  testWidgets('displays inferred tags from title and slug',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      final gif = GifModel.fromJson({
        'id': 'test-id',
        'title': 'Funny Cat',
        'slug': 'funny-cat',
        'images': {
          'fixed_height': {'url': 'https://example.com/fixed-height.gif'},
          'original': {'url': 'https://example.com/original.gif'},
        },
      });

      await pumpDetailedGifScreen(tester, gif);
      await tester.pump(const Duration(seconds: 1));

      // Verify inferred tags
      expect(find.text('funny'), findsOneWidget);
      expect(find.text('cat'), findsOneWidget);
    });
  });
}
