import 'package:flutter/material.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool canPop;
  final VoidCallback? onBackPressed;
  final double titleOffset;
  final TextStyle? titleStyle;
  final double height;
  final BorderRadius? borderRadius;

  const GradientAppBar({
    super.key,
    required this.title,
    this.canPop = true,
    this.onBackPressed,
    this.titleOffset = -3.0,
    this.titleStyle,
    this.height = kToolbarHeight,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return AppBar(
      leading: canPop
          ? Transform.translate(
              offset: Offset(
                  0.0, isLandscape ? -7.0 : 2.0), // Dynamic offset for leading
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: onBackPressed ?? () => Navigator.pop(context),
              ),
            )
          : null,
      title: Transform.translate(
        offset: Offset(titleOffset, isLandscape ? -6.0 : 0.0),
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 255, 255),
                Color.fromARGB(255, 255, 255, 255),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: Text(
            title,
            style: titleStyle ??
                const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
      centerTitle: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
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
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
