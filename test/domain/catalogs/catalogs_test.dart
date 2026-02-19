import 'package:coffee_note_app/domain/catalogs/brew_method_catalog.dart';
import 'package:coffee_note_app/domain/catalogs/coffee_type_catalog.dart';
import 'package:coffee_note_app/domain/catalogs/grind_size_catalog.dart';
import 'package:coffee_note_app/domain/catalogs/roast_level_catalog.dart';
import 'package:flutter/widgets.dart';
import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Catalogs', () {
    test('code 목록이 플랜 정의와 일치한다', () {
      expect(CoffeeTypeCatalog.codes, const <String>[
        'espresso',
        'americano',
        'latte',
        'cappuccino',
        'mocha',
        'macchiato',
        'flat_white',
        'cold_brew',
        'affogato',
        'other',
      ]);

      expect(RoastLevelCatalog.codes, const <String>[
        'light',
        'medium_light',
        'medium',
        'medium_dark',
        'dark',
      ]);

      expect(BrewMethodCatalog.codes, const <String>[
        'espresso',
        'pour_over',
        'french_press',
        'moka_pot',
        'aeropress',
        'cold_brew',
        'siphon',
        'turkish',
        'other',
      ]);

      expect(GrindSizeCatalog.codes, const <String>[
        'extra_fine',
        'fine',
        'medium_fine',
        'medium',
        'medium_coarse',
        'coarse',
        'extra_coarse',
      ]);
    });

    test('label은 locale에 맞게 반환되고 미지원 코드는 fallback 처리한다', () async {
      final ko = await AppLocalizations.delegate.load(const Locale('ko'));
      final en = await AppLocalizations.delegate.load(const Locale('en'));

      expect(CoffeeTypeCatalog.label(ko, 'americano'), '아메리카노');
      expect(CoffeeTypeCatalog.label(en, 'americano'), 'Americano');
      expect(CoffeeTypeCatalog.label(en, 'unknown_code'), 'Other');

      expect(RoastLevelCatalog.label(ko, 'light'), '라이트');
      expect(BrewMethodCatalog.label(en, 'pour_over'), 'Pour Over');
      expect(GrindSizeCatalog.label(ko, 'medium_coarse'), '중굵');
    });
  });
}
