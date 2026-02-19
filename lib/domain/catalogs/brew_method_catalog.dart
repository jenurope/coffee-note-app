import 'package:coffee_note_app/l10n/app_localizations.dart';

abstract final class BrewMethodCatalog {
  static const String espresso = 'espresso';
  static const String pourOver = 'pour_over';
  static const String frenchPress = 'french_press';
  static const String mokaPot = 'moka_pot';
  static const String aeroPress = 'aeropress';
  static const String coldBrew = 'cold_brew';
  static const String siphon = 'siphon';
  static const String turkish = 'turkish';
  static const String other = 'other';

  static const List<String> codes = <String>[
    espresso,
    pourOver,
    frenchPress,
    mokaPot,
    aeroPress,
    coldBrew,
    siphon,
    turkish,
    other,
  ];

  static String label(AppLocalizations l10n, String code) {
    return switch (code) {
      espresso => l10n.brewMethodEspresso,
      pourOver => l10n.brewMethodPourOver,
      frenchPress => l10n.brewMethodFrenchPress,
      mokaPot => l10n.brewMethodMokaPot,
      aeroPress => l10n.brewMethodAeroPress,
      coldBrew => l10n.brewMethodColdBrew,
      siphon => l10n.brewMethodSiphon,
      turkish => l10n.brewMethodTurkish,
      _ => l10n.brewMethodOther,
    };
  }
}
