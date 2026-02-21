import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserErrorMessage {
  static const String defaultKey = 'errRequestFailed';

  static String from(Object error, {String fallbackKey = defaultKey}) {
    if (error is AuthException) {
      final message = error.message.toLowerCase();

      if (_containsAny(message, ['network', 'socket', 'timeout'])) {
        return 'errNetwork';
      }
      if (_containsAny(message, ['cancel', 'canceled', 'cancelled'])) {
        return 'errCanceled';
      }
      if (_containsAny(message, ['token', 'session', 'jwt'])) {
        return 'errAuthExpired';
      }
      if (_containsAny(message, [
        'invalid login credentials',
        'invalid grant',
      ])) {
        return 'errInvalidCredentials';
      }
      if (_containsAny(message, ['user not found', 'does not exist'])) {
        return 'errUserNotFound';
      }
      if (_containsAny(message, ['already registered', 'already exists'])) {
        return 'errAlreadyRegistered';
      }

      return fallbackKey;
    }

    if (error is PostgrestException) {
      final message =
          '${error.message} ${error.details ?? ''} ${error.hint ?? ''}'
              .toLowerCase();
      if (_containsAny(message, [
        'community_post_hourly_limit_exceeded',
        '시간당 게시글 작성 제한',
      ])) {
        return 'errPostHourlyLimitExceeded';
      }
      if (_containsAny(message, [
        'community_comment_hourly_limit_exceeded',
        'comment_hourly_limit_exceeded',
        '시간당 댓글 작성 제한',
      ])) {
        return 'errCommentHourlyLimitExceeded';
      }

      switch (error.code) {
        case '23503':
          return 'errAccountInvalid';
        case '23505':
          return 'errAlreadyExists';
        case '23502':
        case '23514':
        case '22P02':
          return 'errInvalidInput';
        case '42501':
          return 'errPermissionDenied';
        case 'PGRST116':
          return 'errNotFound';
      }

      if (_containsAny(message, ['foreign key', '23503'])) {
        return 'errAccountInvalid';
      }
      if (_containsAny(message, ['permission', 'forbidden', 'rls', '42501'])) {
        return 'errPermissionDenied';
      }
      if (_containsAny(message, ['not null', 'null value', 'constraint'])) {
        return 'errInvalidInput';
      }

      return fallbackKey;
    }

    final message = error.toString().toLowerCase();
    if (_containsAny(message, [
      'invalid photo image',
      'unsupported image format',
      'image upload failed',
      'imageuploadexception',
      'heic',
      'heif',
    ])) {
      return 'errInvalidInput';
    }
    if (_containsAny(message, ['storageexception']) &&
        _containsAny(message, ['statuscode: 401', 'statuscode: 403'])) {
      return 'errPermissionDenied';
    }
    if (_containsAny(message, ['storageexception']) &&
        _containsAny(message, ['statuscode: 413', 'too large'])) {
      return 'errInvalidInput';
    }
    if (_containsAny(message, ['network', 'socket', 'timeout', 'connection'])) {
      return 'errNetwork';
    }
    if (_containsAny(message, ['cancel', 'canceled', 'cancelled'])) {
      return 'errCanceled';
    }
    if (_containsAny(message, ['token', 'session', 'jwt', 'auth'])) {
      return 'errAuthExpired';
    }
    if (_containsAny(message, [
      'permission',
      'forbidden',
      'unauthorized',
      'rls',
    ])) {
      return 'errPermissionDenied';
    }
    if (_containsAny(message, ['foreign key', 'constraint', '23503'])) {
      return 'errReauthRequired';
    }

    return fallbackKey;
  }

  static String localize(AppLocalizations l10n, String key) {
    return switch (key) {
      'errNetwork' => l10n.errNetwork,
      'errCanceled' => l10n.errCanceled,
      'errAuthExpired' => l10n.errAuthExpired,
      'errInvalidCredentials' => l10n.errInvalidCredentials,
      'errUserNotFound' => l10n.errUserNotFound,
      'errAlreadyRegistered' => l10n.errAlreadyRegistered,
      'errAccountInvalid' => l10n.errAccountInvalid,
      'errAlreadyExists' => l10n.errAlreadyExists,
      'errInvalidInput' => l10n.errInvalidInput,
      'errPermissionDenied' => l10n.errPermissionDenied,
      'errNotFound' => l10n.errNotFound,
      'errPostHourlyLimitExceeded' => l10n.errPostHourlyLimitExceeded,
      'errCommentHourlyLimitExceeded' => l10n.errCommentHourlyLimitExceeded,
      'errReauthRequired' => l10n.errReauthRequired,
      'errGoogleLoginCanceled' => l10n.errGoogleLoginCanceled,
      'errGoogleTokenUnavailable' => l10n.errGoogleTokenUnavailable,
      'errLoginFailed' => l10n.errLoginFailed,
      'errServiceNotInitialized' => l10n.errServiceNotInitialized,
      'errLoadBeans' => l10n.errLoadBeans,
      'errLoadBeanDetail' => l10n.errLoadBeanDetail,
      'errLoadLogs' => l10n.errLoadLogs,
      'errLoadLogDetail' => l10n.errLoadLogDetail,
      'errLoadPosts' => l10n.errLoadPosts,
      'errLoadPostDetail' => l10n.errLoadPostDetail,
      'errLoadDashboard' => l10n.errLoadDashboard,
      'errBeanNotFound' => l10n.errBeanNotFound,
      'errSampleBeanNotFound' => l10n.errSampleBeanNotFound,
      'errLogNotFound' => l10n.errLogNotFound,
      'errSampleLogNotFound' => l10n.errSampleLogNotFound,
      'errPostNotFound' => l10n.errPostNotFound,
      'appStartUnavailable' => l10n.appStartUnavailable,
      _ => l10n.errRequestFailed,
    };
  }

  static bool _containsAny(String source, List<String> patterns) {
    return patterns.any(source.contains);
  }
}
