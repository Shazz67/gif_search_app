import 'package:flutter/material.dart';
import '../widgets/shared/gradient_app_bar.dart';

class AddGifScreen extends StatelessWidget {
  const AddGifScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Add your own GIF',
        titleOffset: -18.0,
        height: Theme.of(context).appBarTheme.toolbarHeight ?? kToolbarHeight,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.image,
              size: 120,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            Text(
              'Adding GIFs coming soon!',
              style: TextStyle(
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
