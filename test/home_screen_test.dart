import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:gif_search_app/screens/home_screen.dart';
import 'package:gif_search_app/data/giphy_service.dart';
import 'home_screen_test.mocks.dart';
import 'package:gif_search_app/providers/providers.dart';

@GenerateNiceMocks([MockSpec<GiphyService>()])
void main() {
  late MockGiphyService mockGiphyService;

  setUp(() {
    mockGiphyService = MockGiphyService();
    reset(mockGiphyService);
  });

  testWidgets('typing in search bar triggers search',
      (WidgetTester tester) async {
    // Setup the mock response
    when(mockGiphyService.searchGifs(any, offset: anyNamed('offset')))
        .thenAnswer((_) async => <Map<String, dynamic>>[]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          connectivityProvider.overrideWith((_) => Stream.value(true)),
          giphyServiceProvider.overrideWithValue(mockGiphyService),
        ],
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'funny');
    await tester.pumpAndSettle(
        const Duration(milliseconds: 600)); // Account for debounce

    verify(mockGiphyService.searchGifs('funny', offset: 0)).called(1);
  });

  testWidgets('displays "No GIFs found" if search returns empty list',
      (WidgetTester tester) async {
    // Stub searchGifs to return an empty list
    when(mockGiphyService.searchGifs(any, offset: anyNamed('offset')))
        .thenAnswer((_) async => <Map<String, dynamic>>[]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          connectivityProvider.overrideWith((_) => Stream.value(true)),
          giphyServiceProvider.overrideWithValue(mockGiphyService),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // Type into search bar
    await tester.enterText(find.byType(TextField), 'banana');
    // Wait for debounce + network call
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    // Verify "No GIFs found" message
    expect(find.text('No GIFs found for your search query'), findsOneWidget);
  });

  testWidgets('displays error if searchGifs throws an exception',
      (WidgetTester tester) async {
    when(mockGiphyService.searchGifs(any, offset: anyNamed('offset')))
        .thenThrow(Exception('Network error'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          connectivityProvider.overrideWith((_) => Stream.value(true)),
          giphyServiceProvider.overrideWithValue(mockGiphyService),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // Type into the search bar
    await tester.enterText(find.byType(TextField), 'banana');
    // Wait for debounce + network call
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    // Verify error message
    expect(find.text('Failed to load GIFs'), findsOneWidget);
  });

  testWidgets('pull-to-refresh triggers fetch', (WidgetTester tester) async {
    // Let’s assume we’re on the default category "Trending"
    when(mockGiphyService.getGifsByCategory(any, offset: anyNamed('offset')))
        .thenAnswer((_) async => <Map<String, dynamic>>[]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          connectivityProvider.overrideWith((_) => Stream.value(true)),
          giphyServiceProvider.overrideWithValue(mockGiphyService),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // Pull down to refresh
    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    // Verify the fetch method for trending category was called
    verify(mockGiphyService.getGifsByCategory('Trending', offset: 0)).called(1);
  });
}
