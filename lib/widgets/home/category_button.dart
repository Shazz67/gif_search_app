import 'package:flutter/material.dart';

class CategoryButton extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback onPressed;

  const CategoryButton({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 202, 205, 255),
            blurRadius: 10,
            spreadRadius: -6,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: isSelected
            ? const LinearGradient(
                colors: [
                  Color.fromARGB(255, 255, 0, 93),
                  Color(0xFF3D3DFF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isSelected ? null : Colors.white,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return isSelected
                ? const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 255, 255, 255),
                      Color.fromARGB(255, 255, 255, 255),
                    ],
                  ).createShader(bounds)
                : const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 75, 78, 255),
                      Color.fromARGB(255, 75, 78, 255),
                    ],
                  ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: Text(
            category,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
