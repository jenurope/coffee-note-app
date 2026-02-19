import 'package:coffee_note_app/core/errors/user_error_message.dart';
import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('UserErrorMessage.from', () {
    test('AuthException 네트워크 오류를 사용자 메시지로 변환한다', () {
      const error = AuthException('Socket timeout while fetching session');

      final message = UserErrorMessage.from(error);

      expect(message, 'errNetwork');
    });

    test('AuthException 토큰 오류를 사용자 메시지로 변환한다', () {
      const error = AuthException('Invalid refresh token');

      final message = UserErrorMessage.from(error);

      expect(message, 'errAuthExpired');
    });

    test('AuthException 로그인 자격 증명 오류를 사용자 메시지로 변환한다', () {
      const error = AuthException('Invalid login credentials');

      final message = UserErrorMessage.from(error);

      expect(message, 'errInvalidCredentials');
    });

    test('AuthException 미분류 오류는 fallback 메시지를 사용한다', () {
      const error = AuthException('Unexpected auth failure');
      const fallback = 'errLoginFailed';

      final message = UserErrorMessage.from(error, fallbackKey: fallback);

      expect(message, fallback);
    });

    test('PostgrestException 23503은 계정 유효성 메시지로 변환한다', () {
      const error = PostgrestException(message: 'fk violation', code: '23503');

      final message = UserErrorMessage.from(error);

      expect(message, 'errAccountInvalid');
    });

    test('PostgrestException 42501은 권한 메시지로 변환한다', () {
      const error = PostgrestException(
        message: 'permission denied',
        code: '42501',
      );

      final message = UserErrorMessage.from(error);

      expect(message, 'errPermissionDenied');
    });

    test('PostgrestException 코드가 없어도 foreign key 문구를 변환한다', () {
      const error = PostgrestException(
        message: 'insert violates foreign key constraint',
      );

      final message = UserErrorMessage.from(error);

      expect(message, 'errAccountInvalid');
      expect(message.toLowerCase(), isNot(contains('foreign key')));
      expect(message, isNot(contains('PostgrestException')));
    });

    test('PostgrestException 미분류 오류는 fallback 메시지를 사용한다', () {
      const error = PostgrestException(
        message: 'unknown db error',
        code: 'XX000',
      );
      const fallback = 'errRequestFailed';

      final message = UserErrorMessage.from(error, fallbackKey: fallback);

      expect(message, fallback);
    });

    test('일반 예외의 permission 문구를 권한 메시지로 변환한다', () {
      final error = Exception('permission denied for table profiles');

      final message = UserErrorMessage.from(error);

      expect(message, 'errPermissionDenied');
    });

    test('일반 예외 미분류 오류는 fallback 메시지를 사용한다', () {
      final error = Exception('totally unknown failure');
      const fallback = 'errRequestFailed';

      final message = UserErrorMessage.from(error, fallbackKey: fallback);

      expect(message, fallback);
      expect(message, isNot(contains('Exception')));
    });

    test('localize는 locale에 맞는 문구를 반환한다', () async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      final ko = await AppLocalizations.delegate.load(const Locale('ko'));
      final ja = await AppLocalizations.delegate.load(const Locale('ja'));

      expect(UserErrorMessage.localize(en, 'errNetwork'), contains('network'));
      expect(UserErrorMessage.localize(ko, 'errNetwork'), contains('네트워크'));
      expect(UserErrorMessage.localize(ja, 'errNetwork'), contains('ネットワーク'));
    });
  });
}
