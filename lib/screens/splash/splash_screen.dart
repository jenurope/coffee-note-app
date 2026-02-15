import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const Color _lightBackground = Color(0xFF5D4037);
  static const Color _darkBackground = Color(0xFF121212);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme.brightness == Brightness.dark
        ? _darkBackground
        : _lightBackground;
    const foregroundColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.coffee, size: 64, color: foregroundColor),
            const SizedBox(height: 16),
            Text(
              '커피로그',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: foregroundColor,
              ),
            ),
            const SizedBox(height: 12),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: foregroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
