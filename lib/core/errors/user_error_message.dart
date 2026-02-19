import 'package:supabase_flutter/supabase_flutter.dart';

class UserErrorMessage {
  static const String defaultMessage = '요청을 처리하지 못했습니다. 잠시 후 다시 시도해주세요.';

  static String from(Object error, {String fallback = defaultMessage}) {
    if (error is AuthException) {
      final message = error.message.toLowerCase();

      if (_containsAny(message, ['network', 'socket', 'timeout'])) {
        return '네트워크 연결을 확인해주세요.';
      }
      if (_containsAny(message, ['cancel', 'canceled', 'cancelled'])) {
        return '작업이 취소되었습니다.';
      }
      if (_containsAny(message, ['token', 'session', 'jwt'])) {
        return '인증이 만료되었습니다. 다시 로그인해주세요.';
      }
      if (_containsAny(message, [
        'invalid login credentials',
        'invalid grant',
      ])) {
        return '로그인 정보를 확인해주세요.';
      }
      if (_containsAny(message, ['user not found', 'does not exist'])) {
        return '계정을 찾을 수 없습니다.';
      }
      if (_containsAny(message, ['already registered', 'already exists'])) {
        return '이미 가입된 계정입니다.';
      }

      return fallback;
    }

    if (error is PostgrestException) {
      switch (error.code) {
        case '23503':
          return '계정 정보가 유효하지 않습니다. 다시 로그인 후 시도해주세요.';
        case '23505':
          return '이미 등록된 데이터입니다.';
        case '23502':
        case '23514':
        case '22P02':
          return '입력값을 다시 확인해주세요.';
        case '42501':
          return '이 작업을 수행할 권한이 없습니다.';
        case 'PGRST116':
          return '요청한 데이터를 찾을 수 없습니다.';
      }

      final message =
          '${error.message} ${error.details ?? ''} ${error.hint ?? ''}'
              .toLowerCase();
      if (_containsAny(message, ['foreign key', '23503'])) {
        return '계정 정보가 유효하지 않습니다. 다시 로그인 후 시도해주세요.';
      }
      if (_containsAny(message, ['permission', 'forbidden', 'rls', '42501'])) {
        return '이 작업을 수행할 권한이 없습니다.';
      }
      if (_containsAny(message, ['not null', 'null value', 'constraint'])) {
        return '입력값을 다시 확인해주세요.';
      }

      return fallback;
    }

    final message = error.toString().toLowerCase();
    if (_containsAny(message, ['network', 'socket', 'timeout', 'connection'])) {
      return '네트워크 연결을 확인해주세요.';
    }
    if (_containsAny(message, ['cancel', 'canceled', 'cancelled'])) {
      return '작업이 취소되었습니다.';
    }
    if (_containsAny(message, ['token', 'session', 'jwt', 'auth'])) {
      return '인증이 만료되었습니다. 다시 로그인해주세요.';
    }
    if (_containsAny(message, [
      'permission',
      'forbidden',
      'unauthorized',
      'rls',
    ])) {
      return '이 작업을 수행할 권한이 없습니다.';
    }
    if (_containsAny(message, ['foreign key', 'constraint', '23503'])) {
      return '요청을 처리할 수 없습니다. 다시 로그인 후 시도해주세요.';
    }

    return fallback;
  }

  static bool _containsAny(String source, List<String> patterns) {
    return patterns.any(source.contains);
  }
}
