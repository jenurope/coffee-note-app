import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_note_app/cubits/auth/auth_cubit.dart';
import 'package:coffee_note_app/cubits/auth/auth_state.dart';
import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:coffee_note_app/models/service_inquiry.dart';
import 'package:coffee_note_app/screens/inquiries/service_inquiry_list_screen.dart';
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

void main() {
  group('ServiceInquiryListScreen', () {
    late _MockAuthCubit authCubit;
    late _MockServiceInquiryService inquiryService;

    setUp(() {
      authCubit = _MockAuthCubit();
      inquiryService = _MockServiceInquiryService();
    });

    tearDown(() async {
      await authCubit.close();
    });

    testWidgets('로그인 사용자는 자신의 문의 목록을 조회하고 상태/답변을 본다', (tester) async {
      final authState = AuthState.authenticated(user: _testUser('list-user'));
      when(() => authCubit.state).thenReturn(authState);
      whenListen(
        authCubit,
        Stream<AuthState>.fromIterable([authState]),
        initialState: authState,
      );
      when(() => inquiryService.getMyInquiries('list-user')).thenAnswer(
        (_) async => [
          ServiceInquiry(
            id: 'inq-1',
            userId: 'list-user',
            inquiryType: InquiryType.feature,
            status: InquiryStatus.inProgress,
            title: '요청 제목',
            content: '요청 본문',
            email: 'list-user@example.com',
            adminResponse: '확인 후 반영 예정입니다.',
            createdAt: DateTime(2026, 2, 22),
            updatedAt: DateTime(2026, 2, 22),
          ),
        ],
      );

      await _pumpScreen(
        tester,
        authCubit: authCubit,
        inquiryService: inquiryService,
      );

      verify(() => inquiryService.getMyInquiries('list-user')).called(1);
      expect(find.text('내 문의 내역'), findsOneWidget);
      expect(find.text('요청 제목'), findsOneWidget);
      expect(find.text('처리중'), findsOneWidget);
      expect(find.textContaining('운영팀 답변'), findsOneWidget);
      expect(find.textContaining('확인 후 반영 예정입니다.'), findsOneWidget);
    });

    testWidgets('비로그인 사용자는 목록 대신 로그인 안내를 본다', (tester) async {
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
      );

      expect(find.text('로그인이 필요합니다.'), findsOneWidget);
      expect(find.text('로그인한 사용자만 문의 내역을 확인할 수 있습니다.'), findsOneWidget);
      verifyNever(() => inquiryService.getMyInquiries(any()));
    });

    testWidgets('문의가 없을 때는 우측 하단 문의 작성 FAB만 노출한다', (tester) async {
      final authState = AuthState.authenticated(user: _testUser('empty-user'));
      when(() => authCubit.state).thenReturn(authState);
      whenListen(
        authCubit,
        Stream<AuthState>.fromIterable([authState]),
        initialState: authState,
      );
      when(
        () => inquiryService.getMyInquiries('empty-user'),
      ).thenAnswer((_) async => const <ServiceInquiry>[]);

      await _pumpScreen(
        tester,
        authCubit: authCubit,
        inquiryService: inquiryService,
      );

      expect(find.text('등록된 문의가 없습니다.'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('문의 작성'), findsOneWidget);
    });
  });
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required AuthCubit authCubit,
  required ServiceInquiryService inquiryService,
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
        home: ServiceInquiryListScreen(service: inquiryService),
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
