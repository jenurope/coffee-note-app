import 'package:coffee_note_app/l10n/app_localizations.dart';

abstract final class CoffeeTypeCatalog {
  static const String espresso = 'espresso';
  static const String americano = 'americano';
  static const String latte = 'latte';
  static const String cappuccino = 'cappuccino';
  static const String mocha = 'mocha';
  static const String macchiato = 'macchiato';
  static const String flatWhite = 'flat_white';
  static const String handDrip = 'hand_drip';
  static const String brewedCoffee = 'brewed_coffee';
  static const String coldBrew = 'cold_brew';
  static const String decaf = 'decaf';
  static const String affogato = 'affogato';
  static const String other = 'other';

  static const List<String> codes = <String>[
    espresso,
    americano,
    latte,
    cappuccino,
    mocha,
    macchiato,
    flatWhite,
    handDrip,
    brewedCoffee,
    coldBrew,
    decaf,
    affogato,
    other,
  ];

  static String label(AppLocalizations l10n, String code) {
    return switch (code) {
      espresso => l10n.coffeeTypeEspresso,
      americano => l10n.coffeeTypeAmericano,
      latte => l10n.coffeeTypeLatte,
      cappuccino => l10n.coffeeTypeCappuccino,
      mocha => l10n.coffeeTypeMocha,
      macchiato => l10n.coffeeTypeMacchiato,
      flatWhite => l10n.coffeeTypeFlatWhite,
      handDrip => l10n.coffeeTypeHandDrip,
      brewedCoffee => l10n.coffeeTypeBrewedCoffee,
      coldBrew => l10n.coffeeTypeColdBrew,
      decaf => l10n.coffeeTypeDecaf,
      affogato => l10n.coffeeTypeAffogato,
      _ => l10n.coffeeTypeOther,
    };
  }
}
