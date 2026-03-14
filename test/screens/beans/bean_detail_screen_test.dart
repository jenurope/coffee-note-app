import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_note_app/cubits/auth/auth_cubit.dart';
import 'package:coffee_note_app/cubits/auth/auth_state.dart';
import 'package:coffee_note_app/cubits/bean/bean_detail_cubit.dart';
import 'package:coffee_note_app/cubits/bean/bean_detail_state.dart';
import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:coffee_note_app/models/coffee_bean.dart';
import 'package:coffee_note_app/screens/beans/bean_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _MockBeanDetailCubit extends MockCubit<BeanDetailState>
    implements BeanDetailCubit {}

void main() {
  group('BeanDetailScreen', () {
    late _MockAuthCubit authCubit;
    late _MockBeanDetailCubit detailCubit;

    setUp(() {
      authCubit = _MockAuthCubit();
      detailCubit = _MockBeanDetailCubit();
    });

    tearDown(() async {
      await authCubit.close();
      await detailCubit.close();
    });

    testWidgets('수정 저장으로 복귀하면 상세를 다시 로드한다', (tester) async {
      final authState = AuthState.authenticated(user: _testUser('user-1'));
      final detailState = BeanDetailState.loaded(bean: _testBean());

      when(() => authCubit.state).thenReturn(authState);
      when(() => detailCubit.state).thenReturn(detailState);
      when(() => detailCubit.load(any())).thenAnswer((_) async {});

      whenListen(
        authCubit,
        Stream<AuthState>.fromIterable([authState]),
        initialState: authState,
      );
      whenListen(
        detailCubit,
        Stream<BeanDetailState>.fromIterable([detailState]),
        initialState: detailState,
      );

      final router = _buildRouter(
        authCubit: authCubit,
        detailCubit: detailCubit,
        editResult: true,
      );

      await tester.pumpWidget(_buildApp(router, authCubit, detailCubit));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();
      await tester.tap(find.text('저장 완료'));
      await tester.pumpAndSettle();

      verify(() => detailCubit.load('bean-1')).called(1);
    });

    testWidgets('취소로 복귀하면 상세를 다시 로드하지 않는다', (tester) async {
      final authState = AuthState.authenticated(user: _testUser('user-1'));
      final detailState = BeanDetailState.loaded(bean: _testBean());

      when(() => authCubit.state).thenReturn(authState);
      when(() => detailCubit.state).thenReturn(detailState);
      when(() => detailCubit.load(any())).thenAnswer((_) async {});

      whenListen(
        authCubit,
        Stream<AuthState>.fromIterable([authState]),
        initialState: authState,
      );
      whenListen(
        detailCubit,
        Stream<BeanDetailState>.fromIterable([detailState]),
        initialState: detailState,
      );

      final router = _buildRouter(
        authCubit: authCubit,
        detailCubit: detailCubit,
        editResult: false,
      );

      await tester.pumpWidget(_buildApp(router, authCubit, detailCubit));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();
      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();

      verifyNever(() => detailCubit.load('bean-1'));
    });
  });
}

MaterialApp routerApp(GoRouter router) {
  return MaterialApp.router(
    locale: const Locale('ko'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: router,
  );
}

Widget _buildApp(
  GoRouter router,
  AuthCubit authCubit,
  BeanDetailCubit detailCubit,
) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<AuthCubit>.value(value: authCubit),
      BlocProvider<BeanDetailCubit>.value(value: detailCubit),
    ],
    child: routerApp(router),
  );
}

GoRouter _buildRouter({
  required AuthCubit authCubit,
  required BeanDetailCubit detailCubit,
  required bool editResult,
}) {
  return GoRouter(
    initialLocation: '/beans/bean-1',
    routes: [
      GoRoute(
        path: '/beans/:id',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<BeanDetailCubit>.value(value: detailCubit),
          ],
          child: BeanDetailScreen(beanId: state.pathParameters['id']!),
        ),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => context.pop(editResult ? true : null),
                  child: Text(editResult ? '저장 완료' : '취소'),
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

CoffeeBean _testBean() {
  final now = DateTime(2026, 3, 14, 12);
  return CoffeeBean(
    id: 'bean-1',
    userId: 'user-1',
    name: '테스트 원두',
    roastery: '테스트 로스터리',
    purchaseDate: now,
    rating: 4.5,
    createdAt: now,
    updatedAt: now,
  );
}

User _testUser(String id) {
  return User(
    id: id,
    appMetadata: const {},
    userMetadata: const {},
    aud: 'authenticated',
    email: '$id@example.com',
    createdAt: '2026-03-14T00:00:00.000Z',
  );
}
