import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_note_app/cubits/auth/auth_cubit.dart';
import 'package:coffee_note_app/cubits/auth/auth_state.dart';
import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:coffee_note_app/models/bean_recipe.dart';
import 'package:coffee_note_app/screens/beans/bean_recipe_manage_screen.dart';
import 'package:coffee_note_app/services/bean_recipe_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _MockBeanRecipeService extends Mock implements BeanRecipeService {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      BeanRecipe(
        id: 'fallback-id',
        userId: 'fallback-user',
        name: 'fallback',
        brewMethod: 'pour_over',
        recipe: 'fallback',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );
  });

  group('BeanRecipeManageScreen', () {
    late _MockAuthCubit authCubit;
    late _MockBeanRecipeService service;

    setUp(() {
      authCubit = _MockAuthCubit();
      service = _MockBeanRecipeService();
    });

    tearDown(() async {
      await authCubit.close();
    });

    testWidgets('목록 렌더링과 레시피 추가가 동작한다', (tester) async {
      final user = _testUser('recipe-user-1');
      final authState = AuthState.authenticated(user: user);
      var recipes = <BeanRecipe>[];

      whenListen(
        authCubit,
        Stream<AuthState>.fromIterable([authState]),
        initialState: authState,
      );
      when(() => service.getRecipes(user.id)).thenAnswer((_) async => recipes);
      when(() => service.createRecipe(any())).thenAnswer((invocation) async {
        final input = invocation.positionalArguments.first as BeanRecipe;
        final created = input.copyWith(
          id: 'recipe-1',
          createdAt: DateTime(2026, 2, 27),
          updatedAt: DateTime(2026, 2, 27),
        );
        recipes = <BeanRecipe>[created];
        return created;
      });

      await _pumpScreen(tester, authCubit: authCubit, service: service);

      expect(find.text('등록된 레시피가 없습니다'), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('bean_recipe_name_field')),
        '아침 레시피',
      );
      await tester.enterText(
        find.byKey(const Key('bean_recipe_text_field')),
        '16g / 250ml, 2:30',
      );
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      verify(() => service.createRecipe(any())).called(1);
      expect(find.text('아침 레시피'), findsOneWidget);
    });

    testWidgets('레시피 수정과 삭제가 동작한다', (tester) async {
      final user = _testUser('recipe-user-2');
      final authState = AuthState.authenticated(user: user);
      var recipes = <BeanRecipe>[
        BeanRecipe(
          id: 'recipe-2',
          userId: user.id,
          name: '기본 레시피',
          brewMethod: 'pour_over',
          recipe: '15g / 240ml, 2:20',
          createdAt: DateTime(2026, 2, 27),
          updatedAt: DateTime(2026, 2, 27),
        ),
      ];

      whenListen(
        authCubit,
        Stream<AuthState>.fromIterable([authState]),
        initialState: authState,
      );
      when(() => service.getRecipes(user.id)).thenAnswer((_) async => recipes);
      when(() => service.updateRecipe(any())).thenAnswer((invocation) async {
        final updated = invocation.positionalArguments.first as BeanRecipe;
        recipes = <BeanRecipe>[updated];
        return updated;
      });
      when(() => service.deleteRecipe('recipe-2')).thenAnswer((_) async {
        recipes = <BeanRecipe>[];
      });

      await _pumpScreen(tester, authCubit: authCubit, service: service);

      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('bean_recipe_name_field')),
        '수정 레시피',
      );
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      verify(() => service.updateRecipe(any())).called(1);
      expect(find.text('수정 레시피'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('삭제'),
        ),
      );
      await tester.pumpAndSettle();

      verify(() => service.deleteRecipe('recipe-2')).called(1);
      expect(find.text('등록된 레시피가 없습니다'), findsOneWidget);
    });

    testWidgets('로드 실패 시 오류 메시지를 노출한다', (tester) async {
      final user = _testUser('recipe-user-3');
      final authState = AuthState.authenticated(user: user);
      whenListen(
        authCubit,
        Stream<AuthState>.fromIterable([authState]),
        initialState: authState,
      );
      when(
        () => service.getRecipes(user.id),
      ).thenThrow(Exception('load failed'));

      await _pumpScreen(tester, authCubit: authCubit, service: service);

      expect(find.text('레시피 목록을 불러오지 못했습니다.'), findsOneWidget);
    });
  });
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required AuthCubit authCubit,
  required BeanRecipeService service,
}) async {
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [BlocProvider<AuthCubit>.value(value: authCubit)],
      child: MaterialApp(
        locale: const Locale('ko'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: BeanRecipeManageScreen(service: service),
      ),
    ),
  );
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
