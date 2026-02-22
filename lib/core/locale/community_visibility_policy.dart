import 'dart:ui' show Locale;

typedef DeviceLocaleProvider = Locale? Function();

bool isCommunityVisible({
  required Locale? appLocale,
  required Locale? deviceLocale,
}) {
  final appLanguageCode = appLocale?.languageCode.toLowerCase();
  if (appLanguageCode == 'ko') {
    return true;
  }

  final deviceCountryCode = deviceLocale?.countryCode?.toUpperCase();
  return deviceCountryCode == 'KR';
}

bool isCommunityPath(String location) {
  return location == '/community' || location.startsWith('/community/');
}
