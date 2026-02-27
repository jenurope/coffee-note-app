import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_note_app/core/di/service_locator.dart';
import 'package:coffee_note_app/cubits/auth/auth_cubit.dart';
import 'package:coffee_note_app/cubits/auth/auth_state.dart';
import 'package:coffee_note_app/models/bean_recipe.dart';
import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:coffee_note_app/screens/beans/bean_form_screen.dart';
import 'package:coffee_note_app/services/bean_recipe_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _MockBeanRecipeService extends Mock implements BeanRecipeService {}

void main() {
  late _MockBeanRecipeService recipeService;

  setUp(() {
    recipeService = _MockBeanRecipeService();
    getIt.allowReassignment = true;
    if (getIt.isRegistered<BeanRecipeService>()) {
      getIt.unregister<BeanRecipeService>();
    }
    getIt.registerSingleton<BeanRecipeService>(recipeService);
  });

  tearDown(() {
    if (getIt.isRegistered<BeanRecipeService>()) {
      getIt.unregister<BeanRecipeService>();
    }
  });

  group('BeanFormScreen', () {
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

      expect(find.text('새 원두 기록'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('나가기'));
      await tester.pumpAndSettle();

      expect(find.text('HOME'), findsOneWidget);
    });

    testWidgets('관리 레시피 선택 시 레시피가 자동 채워지고 수동 수정 가능하다', (tester) async {
      final authCubit = _MockAuthCubit();
      addTearDown(() => authCubit.close());
      final user = _testUser('bean-form-user');
      final authState = AuthState.authenticated(user: user);
      whenListen(
        authCubit,
        Stream<AuthState>.fromIterable([authState]),
        initialState: authState,
      );
      when(() => recipeService.getRecipes(user.id)).thenAnswer(
        (_) async => <BeanRecipe>[
          BeanRecipe(
            id: 'recipe-1',
            userId: user.id,
            name: '아침 레시피',
            brewMethod: 'pour_over',
            recipe: '16g / 250ml, 2:30',
            createdAt: DateTime(2026, 2, 27),
            updatedAt: DateTime(2026, 2, 27),
          ),
        ],
      );

      await _pumpFormRoute(
        tester,
        const BeanFormScreen(),
        authCubit: authCubit,
      );

      await tester.tap(find.byKey(const Key('bean_recipe_template_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('아침 레시피').last);
      await tester.pumpAndSettle();

      final recipeField = find.descendant(
        of: find.byKey(const Key('bean_recipe_text_field')),
        matching: find.byType(TextFormField),
      );
      expect(recipeField, findsOneWidget);
      expect(
        tester.widget<TextFormField>(recipeField).controller?.text,
        '16g / 250ml, 2:30',
      );

      await tester.enterText(recipeField, '18g / 280ml, 2:40');
      await tester.pump();
      expect(
        tester.widget<TextFormField>(recipeField).controller?.text,
        '18g / 280ml, 2:40',
      );
    });
  });
}

Future<void> _pumpFormRoute(
  WidgetTester tester,
  Widget form, {
  AuthCubit? authCubit,
}) async {
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
    MultiBlocProvider(
      providers: [
        if (authCubit != null) BlocProvider<AuthCubit>.value(value: authCubit),
      ],
      child: MaterialApp.router(
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
    ),
  );
  await tester.pumpAndSettle();
  router.push('/form');
  await tester.pumpAndSettle();
}

User _testUser(String id) {
  return User(
    id: id,
    appMetadata: const {},
    userMetadata: const {},
    aud: 'authenticated',
    email: '$id@example.com',
    createdAt: '2026-02-27T00:00:00.000Z',
  );
}
