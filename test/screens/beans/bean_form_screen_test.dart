import 'package:coffee_note_app/core/di/service_locator.dart';
import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:coffee_note_app/screens/beans/bean_form_screen.dart';
import 'package:coffee_note_app/services/coffee_bean_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class _MockCoffeeBeanService extends Mock implements CoffeeBeanService {}

void main() {
  group('BeanFormScreen', () {
    late _MockCoffeeBeanService service;

    setUp(() async {
      service = _MockCoffeeBeanService();
      await getIt.reset();
      getIt.allowReassignment = true;
      getIt.registerSingleton<CoffeeBeanService>(service);
    });

    tearDown(() async {
      await getIt.reset();
    });

    testWidgets('앱바 우측 저장 액션만 노출한다', (tester) async {
      await _pumpFormRoute(tester, const BeanFormScreen());

      expect(find.widgetWithText(TextButton, '저장'), findsOneWidget);
      expect(find.text('등록하기'), findsNothing);
      expect(find.text('수정하기'), findsNothing);
    });

    testWidgets('변경 후 뒤로가기 시 경고 팝업이 표시되고 나가기로 pop 된다', (tester) async {
      await _pumpFormRoute(tester, const BeanFormScreen());

      await tester.enterText(find.byType(TextFormField).first, '테스트 원두');
      await tester.pump();

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text('작성 중인 내용이 사라집니다. 나가시겠습니까?'), findsOneWidget);

      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();

      expect(find.text('새 원두 관리'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('나가기'));
      await tester.pumpAndSettle();

      expect(find.text('HOME'), findsOneWidget);
    });

    testWidgets('수정 프리로드 실패 시 스낵바를 노출하고 현재 화면을 닫는다', (tester) async {
      when(() => service.getBean('bean-1')).thenThrow(Exception('load failed'));

      await _pumpFormRoute(tester, const BeanFormScreen(beanId: 'bean-1'));

      expect(find.text('원두 정보를 불러오지 못했습니다. 잠시 후 다시 시도해주세요.'), findsOneWidget);
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
