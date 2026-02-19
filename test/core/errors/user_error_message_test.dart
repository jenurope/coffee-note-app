import 'package:coffee_note_app/core/errors/user_error_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('UserErrorMessage.from', () {
    test('AuthException 네트워크 오류를 사용자 메시지로 변환한다', () {
      const error = AuthException('Socket timeout while fetching session');

      final message = UserErrorMessage.from(error);

      expect(message, '네트워크 연결을 확인해주세요.');
    });

    test('AuthException 토큰 오류를 사용자 메시지로 변환한다', () {
      const error = AuthException('Invalid refresh token');

      final message = UserErrorMessage.from(error);

      expect(message, '인증이 만료되었습니다. 다시 로그인해주세요.');
    });

    test('AuthException 로그인 자격 증명 오류를 사용자 메시지로 변환한다', () {
      const error = AuthException('Invalid login credentials');

      final message = UserErrorMessage.from(error);

      expect(message, '로그인 정보를 확인해주세요.');
    });

    test('AuthException 미분류 오류는 fallback 메시지를 사용한다', () {
      const error = AuthException('Unexpected auth failure');
      const fallback = '로그인 처리 중 오류가 발생했습니다.';

      final message = UserErrorMessage.from(error, fallback: fallback);

      expect(message, fallback);
    });

    test('PostgrestException 23503은 계정 유효성 메시지로 변환한다', () {
      const error = PostgrestException(message: 'fk violation', code: '23503');

      final message = UserErrorMessage.from(error);

      expect(message, '계정 정보가 유효하지 않습니다. 다시 로그인 후 시도해주세요.');
    });

    test('PostgrestException 42501은 권한 메시지로 변환한다', () {
      const error = PostgrestException(
        message: 'permission denied',
        code: '42501',
      );

      final message = UserErrorMessage.from(error);

      expect(message, '이 작업을 수행할 권한이 없습니다.');
    });

    test('PostgrestException 코드가 없어도 foreign key 문구를 변환한다', () {
      const error = PostgrestException(
        message: 'insert violates foreign key constraint',
      );

      final message = UserErrorMessage.from(error);

      expect(message, '계정 정보가 유효하지 않습니다. 다시 로그인 후 시도해주세요.');
      expect(message.toLowerCase(), isNot(contains('foreign key')));
      expect(message, isNot(contains('PostgrestException')));
    });

    test('PostgrestException 미분류 오류는 fallback 메시지를 사용한다', () {
      const error = PostgrestException(
        message: 'unknown db error',
        code: 'XX000',
      );
      const fallback = '저장 중 오류가 발생했습니다.';

      final message = UserErrorMessage.from(error, fallback: fallback);

      expect(message, fallback);
    });

    test('일반 예외의 permission 문구를 권한 메시지로 변환한다', () {
      final error = Exception('permission denied for table profiles');

      final message = UserErrorMessage.from(error);

      expect(message, '이 작업을 수행할 권한이 없습니다.');
    });

    test('일반 예외 미분류 오류는 fallback 메시지를 사용한다', () {
      final error = Exception('totally unknown failure');
      const fallback = '처리 중 오류가 발생했습니다.';

      final message = UserErrorMessage.from(error, fallback: fallback);

      expect(message, fallback);
      expect(message, isNot(contains('Exception')));
    });
  });
}
