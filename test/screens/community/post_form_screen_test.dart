import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:coffee_note_app/screens/community/post_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('PostFormScreen', () {
    testWidgets('앱바 우측 저장 액션만 노출한다', (tester) async {
      await _pumpFormRoute(tester, const PostFormScreen());

      expect(find.widgetWithText(TextButton, '저장'), findsOneWidget);
      expect(find.text('작성완료'), findsNothing);
    });

    testWidgets('변경 후 뒤로가기 시 경고 팝업이 표시되고 나가기로 pop 된다', (tester) async {
      await _pumpFormRoute(tester, const PostFormScreen());

      await tester.enterText(find.byType(TextFormField).first, '테스트 게시글');
      await tester.pump();

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text('작성 중인 내용이 사라집니다. 나가시겠습니까?'), findsOneWidget);

      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();

      expect(find.text('새 게시글'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('나가기'));
      await tester.pumpAndSettle();

      expect(find.text('HOME'), findsOneWidget);
    });
  });
}

Future<void> _pumpFormRoute(WidgetTester tester, Widget form) async {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('HOME'))),
      ),
      GoRoute(path: '/form', builder: (context, state) => form),
    ],
  );

  await tester.pumpWidget(
    MaterialApp.router(
      locale: const Locale('ko'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
  await tester.pumpAndSettle();
  router.push('/form');
  await tester.pumpAndSettle();
}
