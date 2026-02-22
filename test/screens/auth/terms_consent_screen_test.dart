import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_note_app/cubits/auth/auth_cubit.dart';
import 'package:coffee_note_app/cubits/auth/auth_state.dart';
import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:coffee_note_app/models/terms/term_policy.dart';
import 'package:coffee_note_app/screens/auth/terms_consent_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;
import 'dart:async';

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  group('TermsConsentScreen', () {
    late _MockAuthCubit authCubit;

    setUp(() {
      authCubit = _MockAuthCubit();

      final initialState = AuthState.termsRequired(
        user: _testUser('terms-user'),
      );
      whenListen(
        authCubit,
        Stream<AuthState>.fromIterable([initialState]),
        initialState: initialState,
      );

      when(
        () => authCubit.fetchActiveTerms(localeCode: any(named: 'localeCode')),
      ).thenAnswer(
        (_) async => const <TermPolicy>[
          TermPolicy(
            code: 'service_terms',
            title: '서비스 이용약관',
            content: '약관 본문 1',
            version: 1,
            isRequired: true,
            sortOrder: 10,
          ),
          TermPolicy(
            code: 'privacy_policy',
            title: '개인정보 처리 동의',
            content: '약관 본문 2',
            version: 1,
            isRequired: true,
            sortOrder: 20,
          ),
        ],
      );

      when(
        () => authCubit.acceptTermsConsents(any()),
      ).thenAnswer((_) async => null);
      when(() => authCubit.declineTerms()).thenAnswer((_) async {});
    });

    tearDown(() async {
      await authCubit.close();
    });

    testWidgets('필수 약관 미체크 상태에서는 동의 버튼이 비활성화된다', (tester) async {
      await _pumpScreen(tester, authCubit: authCubit);

      final acceptButton = tester.widget<ElevatedButton>(
        find.byKey(const Key('terms-accept-button')),
      );

      expect(acceptButton.onPressed, isNull);
    });

    testWidgets('필수 약관을 모두 체크하면 동의 버튼이 활성화된다', (tester) async {
      await _pumpScreen(tester, authCubit: authCubit);

      await tester.tap(find.byKey(const Key('term-checkbox-service_terms')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('term-checkbox-privacy_policy')));
      await tester.pump();

      final acceptButton = tester.widget<ElevatedButton>(
        find.byKey(const Key('terms-accept-button')),
      );

      expect(acceptButton.onPressed, isNotNull);
    });

    testWidgets('약관 동의 체크 시 해당 약관 본문이 자동으로 접힌다', (tester) async {
      await _pumpScreen(tester, authCubit: authCubit);

      expect(find.text('약관 본문 1'), findsOneWidget);

      await tester.tap(find.byKey(const Key('term-checkbox-service_terms')));
      await tester.pumpAndSettle();

      expect(find.text('약관 본문 1'), findsNothing);
    });

    testWidgets('동의 버튼 탭 시 프로그레스 인디케이터를 표시한다', (tester) async {
      final completer = Completer<String?>();
      when(
        () => authCubit.acceptTermsConsents(any()),
      ).thenAnswer((_) => completer.future);

      await _pumpScreen(tester, authCubit: authCubit);

      await tester.tap(find.byKey(const Key('term-checkbox-service_terms')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('term-checkbox-privacy_policy')));
      await tester.pump();

      await tester.tap(find.byKey(const Key('terms-accept-button')));
      await tester.pump();

      expect(find.byKey(const Key('terms-accept-progress')), findsOneWidget);

      completer.complete(null);
      await tester.pumpAndSettle();
    });

    testWidgets('동의하지 않고 나가기 버튼은 declineTerms를 호출한다', (tester) async {
      await _pumpScreen(tester, authCubit: authCubit);

      await tester.tap(find.byKey(const Key('terms-decline-button')));
      await tester.pumpAndSettle();

      verify(() => authCubit.declineTerms()).called(1);
    });

    testWidgets('약관 본문은 기본 펼침 상태이며 토글로 접기/펼치기가 가능하다', (tester) async {
      await _pumpScreen(tester, authCubit: authCubit);

      expect(find.text('약관 본문 1'), findsOneWidget);

      await tester.tap(find.byKey(const Key('term-toggle-service_terms')));
      await tester.pumpAndSettle();
      expect(find.text('약관 본문 1'), findsNothing);

      await tester.tap(find.byKey(const Key('term-toggle-service_terms')));
      await tester.pumpAndSettle();
      expect(find.text('약관 본문 1'), findsOneWidget);
    });
  });
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required AuthCubit authCubit,
}) async {
  await tester.pumpWidget(
    BlocProvider<AuthCubit>.value(
      value: authCubit,
      child: const MaterialApp(
        locale: Locale('ko'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('ko'), Locale('en'), Locale('ja')],
        home: TermsConsentScreen(),
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
    createdAt: '2026-02-20T00:00:00.000Z',
  );
}
