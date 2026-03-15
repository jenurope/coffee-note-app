import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_note_app/ads/ad_placement.dart';
import 'package:coffee_note_app/ads/ads_slot_factory.dart';
import 'package:coffee_note_app/core/di/service_locator.dart';
import 'package:coffee_note_app/cubits/auth/auth_cubit.dart';
import 'package:coffee_note_app/cubits/auth/auth_state.dart';
import 'package:coffee_note_app/cubits/log/log_filters.dart';
import 'package:coffee_note_app/cubits/log/log_list_cubit.dart';
import 'package:coffee_note_app/cubits/log/log_list_state.dart';
import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:coffee_note_app/models/coffee_log.dart';
import 'package:coffee_note_app/screens/logs/coffee_log_list_screen.dart';
import 'package:coffee_note_app/widgets/coffee_log_list_tile.dart';
import 'package:coffee_note_app/widgets/common/common_widgets.dart';
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

  group('CoffeeLogListScreen', () {
    late _MockAuthCubit authCubit;
    late _MockLogListCubit logListCubit;

    setUp(() {
      authCubit = _MockAuthCubit();
      logListCubit = _MockLogListCubit();
      getIt.allowReassignment = true;

      when(() => logListCubit.updateFilters(any())).thenAnswer((_) async {});
      when(() => logListCubit.hasMore).thenReturn(false);
    });

    tearDown(() async {
      await authCubit.close();
      await logListCubit.close();
      await getIt.reset();
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

    testWidgets('빈 상태에서는 중앙 등록 버튼 없이 FAB에 커피 텍스트를 노출한다', (tester) async {
      _bindStates(authCubit: authCubit, logListCubit: logListCubit);

      await _pumpCoffeeLogListScreen(
        tester,
        authCubit: authCubit,
        logListCubit: logListCubit,
      );

      final emptyState = find.byType(EmptyState);
      expect(emptyState, findsOneWidget);
      expect(
        find.descendant(of: emptyState, matching: find.byType(CustomButton)),
        findsNothing,
      );

      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);
      expect(
        find.descendant(of: fab, matching: find.text('커피 추가')),
        findsOneWidget,
      );
    });

    testWidgets('loaded + non-empty 상태에서 하단 배너 슬롯을 노출한다', (tester) async {
      getIt.registerSingleton<AdsSlotFactory>(const _FakeAdsSlotFactory());
      _bindStates(
        authCubit: authCubit,
        logListCubit: logListCubit,
        logState: LogListState.loaded(
          logs: [_testLog()],
          filters: const LogFilters(),
        ),
      );

      await _pumpCoffeeLogListScreen(
        tester,
        authCubit: authCubit,
        logListCubit: logListCubit,
      );

      expect(
        find.byKey(const ValueKey('fake-banner-coffeeLogListBanner')),
        findsOneWidget,
      );
    });

    testWidgets('loaded 상태에서는 리스트 타일만 노출하고 보기 전환 아이콘은 숨긴다', (tester) async {
      _bindStates(
        authCubit: authCubit,
        logListCubit: logListCubit,
        logState: LogListState.loaded(
          logs: [_testLog()],
          filters: const LogFilters(),
        ),
      );

      await _pumpCoffeeLogListScreen(
        tester,
        authCubit: authCubit,
        logListCubit: logListCubit,
      );

      expect(find.byType(CoffeeLogListTile), findsOneWidget);
      expect(find.byIcon(Icons.grid_view), findsNothing);
      expect(find.byIcon(Icons.view_list), findsNothing);
    });

    testWidgets('loaded + empty 상태에서도 하단 배너 슬롯을 노출한다', (tester) async {
      getIt.registerSingleton<AdsSlotFactory>(const _FakeAdsSlotFactory());
      _bindStates(authCubit: authCubit, logListCubit: logListCubit);

      await _pumpCoffeeLogListScreen(
        tester,
        authCubit: authCubit,
        logListCubit: logListCubit,
      );

      expect(
        find.byKey(const ValueKey('fake-banner-coffeeLogListBanner')),
        findsOneWidget,
      );
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
  LogListState? logState,
}) {
  final authState = AuthState.authenticated(user: _testUser('log-user'));
  final resolvedLogState =
      logState ??
      LogListState.loaded(logs: const [], filters: const LogFilters());

  when(() => authCubit.state).thenReturn(authState);
  when(() => logListCubit.state).thenReturn(resolvedLogState);

  whenListen(
    authCubit,
    Stream<AuthState>.fromIterable([authState]),
    initialState: authState,
  );
  whenListen(
    logListCubit,
    Stream<LogListState>.fromIterable([resolvedLogState]),
    initialState: resolvedLogState,
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

class _FakeAdsSlotFactory extends AdsSlotFactory {
  const _FakeAdsSlotFactory();

  @override
  Widget buildBannerSlot({Key? key, required AdPlacement placement}) {
    return SizedBox(
      key: ValueKey('fake-banner-${placement.slotName}'),
      height: 50,
    );
  }

  @override
  Widget buildCommunityNativeSlot({Key? key, required int slotIndex}) {
    return SizedBox(key: ValueKey('fake-community-native-$slotIndex'));
  }
}

CoffeeLog _testLog() {
  final now = DateTime(2026, 3, 7, 9);
  return CoffeeLog(
    id: 'log-1',
    userId: 'log-user',
    cafeVisitDate: now,
    coffeeType: 'espresso',
    cafeName: '테스트 카페',
    rating: 4.0,
    createdAt: now,
    updatedAt: now,
  );
}
