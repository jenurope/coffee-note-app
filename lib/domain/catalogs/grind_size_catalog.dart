import 'package:coffee_note_app/l10n/app_localizations.dart';

abstract final class GrindSizeCatalog {
  static const String extraFine = 'extra_fine';
  static const String fine = 'fine';
  static const String mediumFine = 'medium_fine';
  static const String medium = 'medium';
  static const String mediumCoarse = 'medium_coarse';
  static const String coarse = 'coarse';
  static const String extraCoarse = 'extra_coarse';

  static const List<String> codes = <String>[
    extraFine,
    fine,
    mediumFine,
    medium,
    mediumCoarse,
    coarse,
    extraCoarse,
  ];

  static String label(AppLocalizations l10n, String code) {
    return switch (code) {
      extraFine => l10n.grindExtraFine,
      fine => l10n.grindFine,
      mediumFine => l10n.grindMediumFine,
      medium => l10n.grindMedium,
      mediumCoarse => l10n.grindMediumCoarse,
      coarse => l10n.grindCoarse,
      _ => l10n.grindExtraCoarse,
    };
  }
}
