import 'package:coffee_note_app/l10n/app_localizations.dart';

abstract final class CaffeineTypeCatalog {
  static const String caffeinated = 'caffeinated';
  static const String halfCaf = 'half_caf';
  static const String decaf = 'decaf';

  static const List<String> codes = <String>[caffeinated, halfCaf, decaf];

  static String label(AppLocalizations l10n, String code) {
    return switch (code) {
      caffeinated => l10n.caffeineTypeCaffeinated,
      halfCaf => l10n.caffeineTypeHalfCaf,
      decaf => l10n.caffeineTypeDecaf,
      _ => l10n.caffeineTypeCaffeinated,
    };
  }
}
