import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_note_app/cubits/auth/auth_cubit.dart';
import 'package:coffee_note_app/cubits/auth/auth_state.dart';
import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:coffee_note_app/models/service_inquiry.dart';
import 'package:coffee_note_app/screens/inquiries/service_inquiry_form_screen.dart';
import 'package:coffee_note_app/services/service_inquiry_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _MockServiceInquiryService extends Mock
    implements ServiceInquiryService {}

class _FakeServiceInquiry extends Fake implements ServiceInquiry {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeServiceInquiry());
  });

  group('ServiceInquiryFormScreen', () {
    late _MockAuthCubit authCubit;
    late _MockServiceInquiryService inquiryService;

    setUp(() {
      authCubit = _MockAuthCubit();
      inquiryService = _MockServiceInquiryService();
    });

    tearDown(() async {
      await authCubit.close();
    });

    testWidgets('비로그인 사용자는 이메일 미입력 시 제출할 수 없다', (tester) async {
      const authState = AuthState.unauthenticated();
      when(() => authCubit.state).thenReturn(authState);
      whenListen(
        authCubit,
        Stream<AuthState>.fromIterable([authState]),
        initialState: authState,
      );

      await _pumpScreen(
        tester,
        authCubit: authCubit,
        inquiryService: inquiryService,
        allowGuest: true,
      );

      await tester.enterText(find.byType(TextFormField).at(0), '문의 제목');
      await tester.enterText(find.byType(TextFormField).at(1), '문의 본문입니다.');
      await tester.tap(find.text('문의 등록'));
      await tester.pump();

      expect(find.text('이메일을 입력해주세요.'), findsOneWidget);
      verifyNever(() => inquiryService.createInquiry(any()));
    });

    testWidgets('비로그인 사용자는 동의 체크 없이 제출할 수 없다', (tester) async {
      const authState = AuthState.unauthenticated();
      when(() => authCubit.state).thenReturn(authState);
      whenListen(
        authCubit,
        Stream<AuthState>.fromIterable([authState]),
        initialState: authState,
      );

      await _pumpScreen(
        tester,
        authCubit: authCubit,
        inquiryService: inquiryService,
        allowGuest: true,
      );

      await tester.enterText(find.byType(TextFormField).at(0), '문의 제목');
      await tester.enterText(find.byType(TextFormField).at(1), '문의 본문입니다.');
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'guest@example.com',
      );

      await tester.tap(find.text('문의 등록'));
      await tester.pump();

      expect(find.text('개인정보 수집 동의가 필요합니다.'), findsOneWidget);
      verifyNever(() => inquiryService.createInquiry(any()));
    });

    testWidgets('비로그인 문의 제출 성공 시 서비스 호출 payload가 올바르다', (tester) async {
      const authState = AuthState.unauthenticated();
      when(() => authCubit.state).thenReturn(authState);
      whenListen(
        authCubit,
        Stream<AuthState>.fromIterable([authState]),
        initialState: authState,
      );
      when(() => inquiryService.createInquiry(any())).thenAnswer((
        invocation,
      ) async {
        final inquiry = invocation.positionalArguments.first as ServiceInquiry;
        return inquiry.copyWith(
          id: 'created-id',
          createdAt: DateTime(2026, 2, 22),
          updatedAt: DateTime(2026, 2, 22),
        );
      });

      await _pumpScreen(
        tester,
        authCubit: authCubit,
        inquiryService: inquiryService,
        allowGuest: true,
      );

      await tester.enterText(find.byType(TextFormField).at(0), '문의 제목');
      await tester.enterText(find.byType(TextFormField).at(1), '문의 본문입니다.');
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'guest@example.com',
      );
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      await tester.tap(find.text('문의 등록'));
      await tester.pumpAndSettle();

      final captured =
          verify(
                () => inquiryService.createInquiry(captureAny()),
              ).captured.single
              as ServiceInquiry;
      expect(captured.userId, isNull);
      expect(captured.email, 'guest@example.com');
      expect(captured.personalInfoConsent, isTrue);
      expect(captured.inquiryType, InquiryType.general);
      expect(find.text('문의가 등록되었습니다.'), findsOneWidget);
    });

    testWidgets('로그인 사용자는 계정 이메일이 자동 적용된다', (tester) async {
      final authState = AuthState.authenticated(user: _testUser('authed-user'));
      when(() => authCubit.state).thenReturn(authState);
      whenListen(
        authCubit,
        Stream<AuthState>.fromIterable([authState]),
        initialState: authState,
      );
      when(() => inquiryService.createInquiry(any())).thenAnswer((
        invocation,
      ) async {
        final inquiry = invocation.positionalArguments.first as ServiceInquiry;
        return inquiry.copyWith(
          id: 'created-id',
          createdAt: DateTime(2026, 2, 22),
          updatedAt: DateTime(2026, 2, 22),
        );
      });

      await _pumpScreen(
        tester,
        authCubit: authCubit,
        inquiryService: inquiryService,
        allowGuest: false,
      );

      expect(find.text('authed-user@example.com'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), '로그인 문의');
      await tester.enterText(find.byType(TextFormField).at(1), '로그인 문의 본문입니다.');
      await tester.tap(find.text('문의 등록'));
      await tester.pumpAndSettle();

      final captured =
          verify(
                () => inquiryService.createInquiry(captureAny()),
              ).captured.single
              as ServiceInquiry;
      expect(captured.userId, 'authed-user');
      expect(captured.email, 'authed-user@example.com');
      expect(captured.personalInfoConsent, isTrue);
    });
  });
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required AuthCubit authCubit,
  required ServiceInquiryService inquiryService,
  required bool allowGuest,
}) async {
  await tester.pumpWidget(
    BlocProvider<AuthCubit>.value(
      value: authCubit,
      child: MaterialApp(
        locale: const Locale('ko'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ko'), Locale('en'), Locale('ja')],
        home: ServiceInquiryFormScreen(
          service: inquiryService,
          allowGuest: allowGuest,
        ),
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
    createdAt: '2026-02-22T00:00:00.000Z',
  );
}
