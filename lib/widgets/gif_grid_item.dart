import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../models/gif_model.dart';
import '../widgets/network_image_with_placeholder.dart';

class GifGridItem extends StatelessWidget {
  final GifModel gif;
  final String imageUrl;
  final String heroTag;
  final bool shouldFadeIn;
  final void Function() onTap;
  final void Function(VisibilityInfo visibilityInfo)? onVisibilityChanged;

  const GifGridItem({
    super.key,
    required this.gif,
    required this.imageUrl,
    required this.heroTag,
    required this.shouldFadeIn,
    required this.onTap,
    this.onVisibilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(imageUrl),
      onVisibilityChanged: onVisibilityChanged,
      child: GestureDetector(
        onTap: onTap,
        child: Hero(
          tag: heroTag,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: NetworkImageWithPlaceholder(
              imageUrl: imageUrl,
              shouldFadeIn: shouldFadeIn,
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ),
    );
  }
}
