import 'package:flutter/material.dart';

class CustomPageRoute<T> extends MaterialPageRoute<T> {
  static bool isPrewarmed = false;

  CustomPageRoute({
    required super.builder,
    super.settings,
  });

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);
  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final oldPageScale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeInOut,
      ),
    );

    final newPageScale = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      ),
    );
    final newPageFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      ),
    );

    // for the new page, we fade in and scale in, for the old page we only scale up
    // it is a better transition visually, I don't like how the bottom can be seen when transitioning but it's better than how a fade in effect with the old page messes up the top
    return AnimatedBuilder(
      animation: secondaryAnimation,
      builder: (context, _) {
        return ScaleTransition(
          scale: oldPageScale,
          child: FadeTransition(
            opacity: newPageFade,
            child: ScaleTransition(
              scale: newPageScale,
              child: child,
            ),
          ),
        );
      },
    );
  }

  static void prewarm({required TickerProvider vsync}) {
    if (isPrewarmed) return;
    isPrewarmed = true;

    final controller = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 300),
    );
    final secondaryController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 300),
    );

    for (double t = 0.0; t <= 1.0; t += 0.1) {
      controller.value = t;
      secondaryController.value = t;
    }

    controller.dispose();
    secondaryController.dispose();
  }
}
