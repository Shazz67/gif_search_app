import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:gif_search_app/screens/home_screen.dart';
import 'package:gif_search_app/services/giphy_service.dart';
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
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    verify(mockGiphyService.searchGifs('funny', offset: 0)).called(1);
  });

  testWidgets('displays "No GIFs found" if search returns empty list',
      (WidgetTester tester) async {
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

    await tester.enterText(find.byType(TextField), 'banana');
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

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

    await tester.enterText(find.byType(TextField), 'banana');
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    expect(find.text('Failed to load GIFs'), findsOneWidget);
  });

  testWidgets('pull-to-refresh triggers fetch', (WidgetTester tester) async {
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

    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    verify(mockGiphyService.getGifsByCategory('Trending', offset: 0)).called(1);
  });
}
