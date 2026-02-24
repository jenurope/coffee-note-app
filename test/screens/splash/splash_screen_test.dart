import 'package:coffee_note_app/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SplashScreen', () {
    testWidgets('라이트 모드에서 배경/이미지/텍스트/로딩 위치가 올바르다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ko'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ko'), Locale('en'), Locale('ja')],
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.light,
          home: const SplashScreen(),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF5D4037));

      final logo = tester.widget<Image>(find.byKey(const ValueKey('splash-logo')));
      final provider = logo.image;
      expect(provider, isA<AssetImage>());
      expect((provider as AssetImage).assetName, 'assets/images/splash_login_icon.png');
      expect(logo.width, 144);
      expect(logo.height, 144);

      final title = tester.widget<Text>(find.text('커피로그'));
      expect(title.style?.color, Colors.white);

      final progress = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(progress.color, Colors.white);

      final logoY = tester.getCenter(find.byKey(const ValueKey('splash-logo'))).dy;
      final titleY = tester.getCenter(find.text('커피로그')).dy;
      final progressY = tester.getCenter(find.byType(CircularProgressIndicator)).dy;
      expect(titleY, greaterThan(logoY));
      expect(progressY, greaterThan(titleY));
    });

    testWidgets('다크 모드에서 배경 색상이 올바르다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ko'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ko'), Locale('en'), Locale('ja')],
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
          home: const SplashScreen(),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF121212));
    });
  });
}
