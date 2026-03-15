import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_note_app/cubits/auth/auth_cubit.dart';
import 'package:coffee_note_app/cubits/auth/auth_state.dart';
import 'package:coffee_note_app/cubits/log/log_detail_cubit.dart';
import 'package:coffee_note_app/cubits/log/log_detail_state.dart';
import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:coffee_note_app/models/coffee_log.dart';
import 'package:coffee_note_app/router/app_route_observers.dart';
import 'package:coffee_note_app/screens/logs/coffee_log_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _MockLogDetailCubit extends MockCubit<LogDetailState>
    implements LogDetailCubit {}

void main() {
  group('CoffeeLogDetailScreen', () {
    late _MockAuthCubit authCubit;
    late _MockLogDetailCubit detailCubit;

    setUp(() {
      authCubit = _MockAuthCubit();
      detailCubit = _MockLogDetailCubit();
    });

    tearDown(() async {
      await authCubit.close();
      await detailCubit.close();
    });

    testWidgets('수정 저장으로 복귀하면 상세를 다시 로드한다', (tester) async {
      final authState = AuthState.authenticated(user: _testUser('user-1'));
      final detailState = LogDetailState.loaded(log: _testLog());

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
        Stream<LogDetailState>.fromIterable([detailState]),
        initialState: detailState,
      );

      final router = _buildRouter(
        authCubit: authCubit,
        detailCubit: detailCubit,
        editResult: _testLog().copyWith(cafeName: '수정된 카페'),
      );

      await tester.pumpWidget(_buildApp(router, authCubit, detailCubit));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();
      await tester.tap(find.text('저장 완료'));
      await tester.pumpAndSettle();

      verify(() => detailCubit.load('log-1')).called(1);
    });

    testWidgets('편집 화면에서 돌아오면 상세를 다시 로드한다', (tester) async {
      final authState = AuthState.authenticated(user: _testUser('user-1'));
      final detailState = LogDetailState.loaded(log: _testLog());

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
        Stream<LogDetailState>.fromIterable([detailState]),
        initialState: detailState,
      );

      final router = _buildRouter(
        authCubit: authCubit,
        detailCubit: detailCubit,
        editResult: null,
      );

      await tester.pumpWidget(_buildApp(router, authCubit, detailCubit));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();
      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();

      verify(() => detailCubit.load('log-1')).called(1);
    });
  });
}

MaterialApp _routerApp(GoRouter router) {
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
  LogDetailCubit detailCubit,
) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<AuthCubit>.value(value: authCubit),
      BlocProvider<LogDetailCubit>.value(value: detailCubit),
    ],
    child: _routerApp(router),
  );
}

GoRouter _buildRouter({
  required AuthCubit authCubit,
  required LogDetailCubit detailCubit,
  required Object? editResult,
}) {
  return GoRouter(
    observers: [logBranchRouteObserver],
    initialLocation: '/logs/log-1',
    routes: [
      GoRoute(
        path: '/logs/:id',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<LogDetailCubit>.value(value: detailCubit),
          ],
          child: CoffeeLogDetailScreen(logId: state.pathParameters['id']!),
        ),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => context.pop(editResult),
                  child: Text(editResult == null ? '취소' : '저장 완료'),
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

CoffeeLog _testLog() {
  final now = DateTime(2026, 3, 15, 12);
  return CoffeeLog(
    id: 'log-1',
    userId: 'user-1',
    cafeVisitDate: now,
    coffeeType: 'latte',
    cafeName: '테스트 카페',
    rating: 4.0,
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
    createdAt: '2026-03-15T00:00:00.000Z',
  );
}
