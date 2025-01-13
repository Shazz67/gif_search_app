import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../routes/custom_transition_route.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  late final AnimationController _zoomController;
  late final Animation<double> _zoomAnimation;

  late final AnimationController _textFadeController;
  late final Animation<double> _textFadeAnimation;

  String? _svgData;
  late bool _isVisible;

  @override
  void initState() {
    super.initState();

    CustomPageRoute.prewarm(vsync: this);

    _isVisible = false;

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.05, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _zoomAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _zoomController, curve: Curves.easeOut),
    );

    _textFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textFadeController, curve: Curves.easeIn),
    );

    // for prewarming but doesn't seem like it completely fixes the issue
    _zoomController.forward(from: 0.0);
    _zoomController.reverse(from: 1.0);

    _textFadeController.forward(from: 0.0);
    _textFadeController.reverse(from: 1.0);

    _zoomController.value = 0.0;
    _textFadeController.value = 0.0;

    Timer(const Duration(milliseconds: 2500), () {
      _scaleController.forward();
      _fadeController.forward();
    });

    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {});
      }
    });

    _preloadSvg();
    _prewarmCustomRouteAnimation();
  }

  Future<void> _preloadSvg() async {
    final svgRawData =
        await DefaultAssetBundle.of(context).loadString('assets/svg/star.svg');

    await Future.delayed(const Duration(milliseconds: 400));

    setState(() {
      _svgData = svgRawData;
      _isVisible = true;
    });

    _zoomController.forward();
    _textFadeController.forward();
  }

  void _prewarmCustomRouteAnimation() {
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    controller.forward().whenComplete(() {
      controller.dispose();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _zoomController.dispose();
    _textFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const HomeScreen(),
        if (_fadeAnimation.value > 0)
          FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 255, 0, 93),
                      Color(0xFF3D3DFF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isVisible)
                        ScaleTransition(
                          scale: _zoomAnimation,
                          child: FadeTransition(
                            opacity: _textFadeAnimation,
                            child: DefaultTextStyle(
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Fredoka',
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      const Text(
                                        'GIFFY',
                                        style: TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          height: 1.2,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (_svgData != null)
                                        SvgPicture.string(
                                          _svgData!,
                                          height: 30,
                                          width: 30,
                                          colorFilter: const ColorFilter.mode(
                                              Colors.white, BlendMode.srcIn),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
