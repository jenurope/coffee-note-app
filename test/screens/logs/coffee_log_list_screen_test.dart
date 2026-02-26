import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_note_app/cubits/auth/auth_cubit.dart';
import 'package:coffee_note_app/cubits/auth/auth_state.dart';
import 'package:coffee_note_app/cubits/log/log_filters.dart';
import 'package:coffee_note_app/cubits/log/log_list_cubit.dart';
import 'package:coffee_note_app/cubits/log/log_list_state.dart';
import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:coffee_note_app/screens/logs/coffee_log_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _MockLogListCubit extends MockCubit<LogListState>
    implements LogListCubit {}

void main() {
  setUpAll(() {
    registerFallbackValue(const LogFilters());
  });

  group('CoffeeLogListScreen 필터 바텀시트', () {
    late _MockAuthCubit authCubit;
    late _MockLogListCubit logListCubit;

    setUp(() {
      authCubit = _MockAuthCubit();
      logListCubit = _MockLogListCubit();

      when(() => logListCubit.updateFilters(any())).thenAnswer((_) async {});
      when(() => logListCubit.hasMore).thenReturn(false);
    });

    tearDown(() async {
      await authCubit.close();
      await logListCubit.close();
    });

    testWidgets('작은 화면에서 overflow 없이 필터 시트를 스크롤할 수 있다', (tester) async {
      _setSmallViewport(tester);
      _bindStates(authCubit: authCubit, logListCubit: logListCubit);

      await _pumpCoffeeLogListScreen(
        tester,
        authCubit: authCubit,
        logListCubit: logListCubit,
      );

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      final applyButton = find.text('적용하기');
      await tester.ensureVisible(applyButton);
      await tester.pumpAndSettle();
      await tester.tap(applyButton);
      await tester.pumpAndSettle();

      verify(() => logListCubit.updateFilters(any())).called(1);
      expect(tester.takeException(), isNull);
    });
  });
}

Future<void> _pumpCoffeeLogListScreen(
  WidgetTester tester, {
  required AuthCubit authCubit,
  required LogListCubit logListCubit,
}) async {
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<LogListCubit>.value(value: logListCubit),
      ],
      child: const MaterialApp(
        locale: Locale('ko'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: CoffeeLogListScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void _bindStates({
  required _MockAuthCubit authCubit,
  required _MockLogListCubit logListCubit,
}) {
  final authState = AuthState.authenticated(user: _testUser('log-user'));
  final logState = LogListState.loaded(
    logs: const [],
    filters: const LogFilters(),
  );

  when(() => authCubit.state).thenReturn(authState);
  when(() => logListCubit.state).thenReturn(logState);

  whenListen(
    authCubit,
    Stream<AuthState>.fromIterable([authState]),
    initialState: authState,
  );
  whenListen(
    logListCubit,
    Stream<LogListState>.fromIterable([logState]),
    initialState: logState,
  );
}

User _testUser(String id) {
  return User(
    id: id,
    appMetadata: const {},
    userMetadata: const {},
    aud: 'authenticated',
    email: '$id@example.com',
    createdAt: '2026-02-26T00:00:00.000Z',
  );
}

void _setSmallViewport(WidgetTester tester) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(360, 520);
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
