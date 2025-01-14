import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  const SearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color.fromARGB(255, 75, 78, 255),
          fontSize: 18,
        ),
        contentPadding: const EdgeInsets.only(left: 14),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 152, 163, 255),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 77, 77, 240),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear,
                    color: Color.fromARGB(255, 75, 78, 255)),
                onPressed: onClear,
              )
            : null,
      ),
      onChanged: onChanged,
      style: const TextStyle(fontSize: 18, color: Colors.black),
      textAlignVertical: TextAlignVertical.center,
      textAlign: TextAlign.left,
    );
  }
}
