import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'layouts/app_layout.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/detailed_gif_screen.dart';
import 'models/gif_model.dart';
import 'routes/custom_transition_route.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class NavigationCoordinator {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return CustomPageRoute(
          builder: (_) => const AnimatedSplashScreen(),
          settings: settings,
        );
      case '/home':
        return CustomPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      case '/detailed':
        final gif = settings.arguments as GifModel;
        return CustomPageRoute(
          builder: (_) => DetailedGifScreen(gif: gif),
          settings: settings,
        );
      default:
        return CustomPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GIFFY',
      theme: ThemeData(
        fontFamily: 'Fredoka',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 77, 41, 255),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          toolbarHeight: 44,
        ),
        useMaterial3: true,
      ),
      onGenerateRoute: NavigationCoordinator.onGenerateRoute,
      builder: (context, child) {
        return AppLayout(
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
