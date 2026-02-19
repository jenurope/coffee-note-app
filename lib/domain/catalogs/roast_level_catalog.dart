import 'package:coffee_note_app/l10n/app_localizations.dart';

abstract final class RoastLevelCatalog {
  static const String light = 'light';
  static const String mediumLight = 'medium_light';
  static const String medium = 'medium';
  static const String mediumDark = 'medium_dark';
  static const String dark = 'dark';

  static const List<String> codes = <String>[
    light,
    mediumLight,
    medium,
    mediumDark,
    dark,
  ];

  static String label(AppLocalizations l10n, String code) {
    return switch (code) {
      light => l10n.roastLight,
      mediumLight => l10n.roastMediumLight,
      medium => l10n.roastMedium,
      mediumDark => l10n.roastMediumDark,
      _ => l10n.roastDark,
    };
  }
}
