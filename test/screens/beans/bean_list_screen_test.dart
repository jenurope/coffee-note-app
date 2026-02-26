import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_note_app/cubits/auth/auth_cubit.dart';
import 'package:coffee_note_app/cubits/auth/auth_state.dart';
import 'package:coffee_note_app/cubits/bean/bean_filters.dart';
import 'package:coffee_note_app/cubits/bean/bean_list_cubit.dart';
import 'package:coffee_note_app/cubits/bean/bean_list_state.dart';
import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:coffee_note_app/screens/beans/bean_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _MockBeanListCubit extends MockCubit<BeanListState>
    implements BeanListCubit {}

void main() {
  setUpAll(() {
    registerFallbackValue(const BeanFilters());
  });

  group('BeanListScreen 필터 바텀시트', () {
    late _MockAuthCubit authCubit;
    late _MockBeanListCubit beanListCubit;

    setUp(() {
      authCubit = _MockAuthCubit();
      beanListCubit = _MockBeanListCubit();

      when(() => beanListCubit.updateFilters(any())).thenAnswer((_) async {});
      when(() => beanListCubit.hasMore).thenReturn(false);
    });

    tearDown(() async {
      await authCubit.close();
      await beanListCubit.close();
    });

    testWidgets('작은 화면에서 overflow 없이 필터 시트를 스크롤할 수 있다', (tester) async {
      _setSmallViewport(tester);
      _bindStates(authCubit: authCubit, beanListCubit: beanListCubit);

      await _pumpBeanListScreen(
        tester,
        authCubit: authCubit,
        beanListCubit: beanListCubit,
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

      verify(() => beanListCubit.updateFilters(any())).called(1);
      expect(tester.takeException(), isNull);
    });
  });
}

Future<void> _pumpBeanListScreen(
  WidgetTester tester, {
  required AuthCubit authCubit,
  required BeanListCubit beanListCubit,
}) async {
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<BeanListCubit>.value(value: beanListCubit),
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
        home: BeanListScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void _bindStates({
  required _MockAuthCubit authCubit,
  required _MockBeanListCubit beanListCubit,
}) {
  final authState = AuthState.authenticated(user: _testUser('bean-user'));
  final beanState = BeanListState.loaded(
    beans: const [],
    filters: const BeanFilters(),
  );

  when(() => authCubit.state).thenReturn(authState);
  when(() => beanListCubit.state).thenReturn(beanState);

  whenListen(
    authCubit,
    Stream<AuthState>.fromIterable([authState]),
    initialState: authState,
  );
  whenListen(
    beanListCubit,
    Stream<BeanListState>.fromIterable([beanState]),
    initialState: beanState,
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
