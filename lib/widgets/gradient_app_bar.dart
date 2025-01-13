import 'package:flutter/material.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool canPop;
  final VoidCallback? onBackPressed;
  final double titleOffset;
  final TextStyle? titleStyle;

  const GradientAppBar({
    Key? key,
    required this.title,
    this.canPop = true,
    this.onBackPressed,
    this.titleOffset = -6.0,
    this.titleStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: canPop
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      title: Transform.translate(
        offset: Offset(titleOffset, 0.0),
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
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10.0),
          bottomRight: Radius.circular(10.0),
        ),
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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
