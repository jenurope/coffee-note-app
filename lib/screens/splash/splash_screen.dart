import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const Color _lightBackground = Color(0xFF5D4037);
  static const Color _darkBackground = Color(0xFF121212);
  static const String _logoAssetPath = 'assets/images/splash_login_icon.png';
  // 로딩 스플래시에서 사용할 아이콘 크기
  static const double _nativeSplashIconSize = 144;
  // 컵 손잡이로 인해 우측으로 치우쳐 보이는 시각 중심 보정
  static const double _logoVisualOffsetX = -2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme.brightness == Brightness.dark
        ? _darkBackground
        : _lightBackground;
    const foregroundColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          const Spacer(),
          Transform.translate(
            offset: Offset(_logoVisualOffsetX, 0),
            child: Image(
              key: ValueKey('splash-logo'),
              image: AssetImage(_logoAssetPath),
              width: _nativeSplashIconSize,
              height: _nativeSplashIconSize,
              fit: BoxFit.contain,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.appTitle,
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
          ),
        ],
      ),
    );
  }
}
