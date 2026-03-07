import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_note_app/ads/ad_placement.dart';
import 'package:coffee_note_app/ads/ads_slot_factory.dart';
import 'package:coffee_note_app/core/di/service_locator.dart';
import 'package:coffee_note_app/cubits/auth/auth_cubit.dart';
import 'package:coffee_note_app/cubits/auth/auth_state.dart';
import 'package:coffee_note_app/cubits/bean/bean_filters.dart';
import 'package:coffee_note_app/cubits/bean/bean_list_cubit.dart';
import 'package:coffee_note_app/cubits/bean/bean_list_state.dart';
import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:coffee_note_app/models/coffee_bean.dart';
import 'package:coffee_note_app/screens/beans/bean_list_screen.dart';
import 'package:coffee_note_app/widgets/common/common_widgets.dart';
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
      getIt.allowReassignment = true;

      when(() => beanListCubit.updateFilters(any())).thenAnswer((_) async {});
      when(() => beanListCubit.hasMore).thenReturn(false);
    });

    tearDown(() async {
      await authCubit.close();
      await beanListCubit.close();
      await getIt.reset();
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

    testWidgets('빈 상태에서는 중앙 등록 버튼 없이 FAB에 원두 텍스트를 노출한다', (tester) async {
      _bindStates(authCubit: authCubit, beanListCubit: beanListCubit);

      await _pumpBeanListScreen(
        tester,
        authCubit: authCubit,
        beanListCubit: beanListCubit,
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
        find.descendant(of: fab, matching: find.text('원두 추가')),
        findsOneWidget,
      );
    });

    testWidgets('loaded + non-empty 상태에서 하단 배너 슬롯을 노출한다', (tester) async {
      getIt.registerSingleton<AdsSlotFactory>(const _FakeAdsSlotFactory());
      _bindStates(
        authCubit: authCubit,
        beanListCubit: beanListCubit,
        beanState: BeanListState.loaded(
          beans: [_testBean()],
          filters: const BeanFilters(),
        ),
      );

      await _pumpBeanListScreen(
        tester,
        authCubit: authCubit,
        beanListCubit: beanListCubit,
      );

      expect(
        find.byKey(const ValueKey('fake-banner-beanListBanner')),
        findsOneWidget,
      );
    });

    testWidgets('빈 상태에서는 광고 슬롯을 노출하지 않는다', (tester) async {
      getIt.registerSingleton<AdsSlotFactory>(const _FakeAdsSlotFactory());
      _bindStates(authCubit: authCubit, beanListCubit: beanListCubit);

      await _pumpBeanListScreen(
        tester,
        authCubit: authCubit,
        beanListCubit: beanListCubit,
      );

      expect(
        find.byKey(const ValueKey('fake-banner-beanListBanner')),
        findsNothing,
      );
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
  BeanListState? beanState,
}) {
  final authState = AuthState.authenticated(user: _testUser('bean-user'));
  final resolvedBeanState =
      beanState ??
      BeanListState.loaded(beans: const [], filters: const BeanFilters());

  when(() => authCubit.state).thenReturn(authState);
  when(() => beanListCubit.state).thenReturn(resolvedBeanState);

  whenListen(
    authCubit,
    Stream<AuthState>.fromIterable([authState]),
    initialState: authState,
  );
  whenListen(
    beanListCubit,
    Stream<BeanListState>.fromIterable([resolvedBeanState]),
    initialState: resolvedBeanState,
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

CoffeeBean _testBean() {
  final now = DateTime(2026, 3, 7, 9);
  return CoffeeBean(
    id: 'bean-1',
    userId: 'bean-user',
    name: '에티오피아',
    roastery: '테스트 로스터리',
    purchaseDate: now,
    rating: 4.5,
    createdAt: now,
    updatedAt: now,
  );
}
