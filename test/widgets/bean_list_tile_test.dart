import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:coffee_note_app/models/coffee_bean.dart';
import 'package:coffee_note_app/widgets/bean_list_tile.dart';
import 'package:coffee_note_app/widgets/common/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ko');
  });

  testWidgets('BeanListTile에 원두 정보와 평점이 표시된다', (tester) async {
    final bean = CoffeeBean(
      id: 'bean-1',
      userId: 'user-1',
      name: '에티오피아 예가체프',
      roastery: '테스트 로스터리',
      purchaseDate: DateTime(2026, 2, 14),
      rating: 4.5,
      tastingNotes: '자스민, 복숭아, 홍차',
      roastLevel: 'light',
      purchaseLocation: '성수 로스터리',
      createdAt: DateTime(2026, 2, 14),
      updatedAt: DateTime(2026, 2, 14),
    );

    await tester.pumpWidget(
      _TestApp(
        child: Scaffold(body: BeanListTile(bean: bean)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(RatingStars), findsOneWidget);
    expect(find.text(bean.name), findsOneWidget);
    expect(find.text(bean.purchaseLocation!), findsOneWidget);
    expect(find.text(bean.tastingNotes!), findsOneWidget);
    expect(find.text('4.5'), findsNothing);

    final notesText = tester.widget<Text>(find.text(bean.tastingNotes!));
    expect(notesText.maxLines, 1);
    expect(notesText.overflow, TextOverflow.ellipsis);
  });

  testWidgets('BeanListTile 이미지는 카드의 좌측과 상하에 여백 없이 붙는다', (tester) async {
    final bean = CoffeeBean(
      id: 'bean-1',
      userId: 'user-1',
      name: '에티오피아 예가체프',
      roastery: '테스트 로스터리',
      purchaseDate: DateTime(2026, 2, 14),
      rating: 4.5,
      createdAt: DateTime(2026, 2, 14),
      updatedAt: DateTime(2026, 2, 14),
    );

    await tester.pumpWidget(
      _TestApp(
        child: Scaffold(body: BeanListTile(bean: bean)),
      ),
    );
    await tester.pumpAndSettle();

    final cardRect = tester.getRect(find.byType(Card));
    final imageRect = tester.getRect(
      find.byKey(const Key('bean-list-tile-image')),
    );

    expect(imageRect.left, cardRect.left);
    expect(imageRect.top, cardRect.top);
    expect(imageRect.bottom, cardRect.bottom);
  });

  testWidgets('BeanListTile은 이미지 유무와 상관없이 같은 내용이면 높이가 같다', (tester) async {
    final baseBean = CoffeeBean(
      id: 'bean-1',
      userId: 'user-1',
      name: '에티오피아 예가체프',
      roastery: '테스트 로스터리',
      purchaseDate: DateTime(2026, 2, 14),
      rating: 4.5,
      tastingNotes: '자스민, 복숭아, 홍차',
      roastLevel: 'light',
      purchaseLocation: '성수 로스터리',
      createdAt: DateTime(2026, 2, 14),
      updatedAt: DateTime(2026, 2, 14),
    );

    await tester.pumpWidget(
      _TestApp(
        child: Scaffold(
          body: Column(
            children: [
              BeanListTile(
                bean: baseBean.copyWith(
                  imageUrl: 'https://example.com/bean.jpg',
                ),
              ),
              const SizedBox(height: 12),
              BeanListTile(bean: baseBean),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final withImageRect = tester.getRect(find.byType(Card).at(0));
    final withoutImageRect = tester.getRect(find.byType(Card).at(1));

    expect(withImageRect.height, closeTo(withoutImageRect.height, 0.01));
  });

  testWidgets('BeanListTile은 큰 글자에서도 overflow 없이 높이가 늘어난다', (tester) async {
    final bean = CoffeeBean(
      id: 'bean-1',
      userId: 'user-1',
      name: '에티오피아 예가체프 워시드',
      roastery: '테스트 로스터리',
      purchaseDate: DateTime(2026, 2, 14),
      rating: 4.5,
      tastingNotes: '자스민, 복숭아, 홍차',
      roastLevel: 'medium',
      purchaseLocation: '성수 로스터리',
      createdAt: DateTime(2026, 2, 14),
      updatedAt: DateTime(2026, 2, 14),
    );

    await tester.pumpWidget(
      _TestApp(
        child: MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 640),
            textScaler: TextScaler.linear(1.4),
          ),
          child: Scaffold(
            body: SizedBox(width: 360, child: BeanListTile(bean: bean)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    final cardRect = tester.getRect(find.byType(Card));
    expect(cardRect.height, greaterThan(96));
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('ko'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }
}
