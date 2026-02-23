enum AppEnvironment {
  dev('dev'),
  prod('prod');

  const AppEnvironment(this.value);

  final String value;

  static const String _rawValue = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  static AppEnvironment get current {
    for (final environment in AppEnvironment.values) {
      if (environment.value == _rawValue) {
        return environment;
      }
    }
    throw Exception(
      'APP_ENV 값이 유효하지 않습니다: "$_rawValue". '
      '--dart-define=APP_ENV=dev 또는 --dart-define=APP_ENV=prod를 사용하세요.',
    );
  }

  static String get currentValue => current.value;
}
