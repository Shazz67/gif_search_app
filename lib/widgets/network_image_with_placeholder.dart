import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:visibility_detector/visibility_detector.dart';

class NetworkImageWithPlaceholder extends StatefulWidget {
  final String imageUrl;
  final BorderRadius borderRadius;
  final bool shouldFadeIn;

  const NetworkImageWithPlaceholder({
    super.key,
    required this.imageUrl,
    required this.shouldFadeIn,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  NetworkImageWithPlaceholderState createState() =>
      NetworkImageWithPlaceholderState();
}

class NetworkImageWithPlaceholderState
    extends State<NetworkImageWithPlaceholder> {
  bool _showContent = false;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    if (!widget.shouldFadeIn) {
      _showContent = true;
    }
  }

  void _handleImageLoaded() {
    if (mounted) {
      setState(() {
        _showContent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
        key: Key(widget.imageUrl),
        onVisibilityChanged: (visibilityInfo) {
          final isNowVisible = visibilityInfo.visibleFraction > 0;

          if (isNowVisible && !_isVisible) {
            if (mounted) {
              setState(() {
                _isVisible = true;
                _showContent = false;
              });
            }
          } else if (!isNowVisible && _isVisible) {
            if (mounted) {
              setState(() {
                _isVisible = false;
              });
            }
          }
        },
        child: ClipRRect(
          borderRadius: widget.borderRadius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_isVisible) ...[
                const PulsatingPlaceholder(),
                AnimatedOpacity(
                  opacity: _showContent ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 400),
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) {
                      return const PulsatingPlaceholder();
                    },
                    errorWidget: (context, url, error) {
                      return const Center(child: Icon(Icons.error));
                    },
                    imageBuilder: (context, imageProvider) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          _handleImageLoaded();
                        }
                      });
                      return Image(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ] else
                const PulsatingPlaceholder(),
            ],
          ),
        ));
  }
}

class PulsatingPlaceholder extends StatefulWidget {
  const PulsatingPlaceholder({super.key});

  @override
  PulsatingPlaceholderState createState() => PulsatingPlaceholderState();
}

class PulsatingPlaceholderState extends State<PulsatingPlaceholder>
    with TickerProviderStateMixin {
  late final AnimationController _fadeInController;
  late final Animation<double> _fadeInAnimation;

  late final AnimationController _pulsateController;
  late final Animation<double> _pulsateAnimation;

  @override
  void initState() {
    super.initState();

    _fadeInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeInController, curve: Curves.easeIn),
    );

    _pulsateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _pulsateAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulsateController, curve: Curves.easeInOut),
    );

    _fadeInController.forward();

    _fadeInController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulsateController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _pulsateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeInAnimation,
      child: AnimatedBuilder(
        animation: _pulsateAnimation,
        builder: (context, child) {
          final pulsateOpacity = _pulsateAnimation.value;
          return Container(
            color: Color.fromARGB(
              (pulsateOpacity * 255).toInt(),
              224,
              224,
              232,
            ),
          );
        },
      ),
    );
  }
}
