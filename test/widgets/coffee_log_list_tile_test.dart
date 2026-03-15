import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:coffee_note_app/models/coffee_log.dart';
import 'package:coffee_note_app/widgets/coffee_log_list_tile.dart';
import 'package:coffee_note_app/widgets/common/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ko');
  });

  testWidgets('CoffeeLogListTile에 커피 정보와 방문일이 표시된다', (tester) async {
    final log = CoffeeLog(
      id: 'log-1',
      userId: 'user-1',
      cafeVisitDate: DateTime(2026, 2, 15),
      coffeeType: 'latte',
      coffeeName: '바닐라 라떼',
      cafeName: '테스트 카페',
      rating: 4.0,
      notes: '바닐라 향이 진하고 피니시가 길다',
      createdAt: DateTime(2026, 2, 15),
      updatedAt: DateTime(2026, 2, 15),
    );
    final expectedDate = DateFormat.Md('ko').format(log.cafeVisitDate);
    final expectedRating = log.rating.toStringAsFixed(1);

    await tester.pumpWidget(
      _TestApp(
        child: Scaffold(body: CoffeeLogListTile(log: log)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(RatingStars), findsOneWidget);
    expect(find.text(log.coffeeName!), findsOneWidget);
    expect(find.text(log.cafeName), findsOneWidget);
    expect(find.text(log.notes!), findsOneWidget);
    expect(find.text(expectedDate), findsOneWidget);
    expect(find.text(expectedRating), findsNothing);

    final notesText = tester.widget<Text>(find.text(log.notes!));
    expect(notesText.maxLines, 1);
    expect(notesText.overflow, TextOverflow.ellipsis);
  });

  testWidgets('CoffeeLogListTile 이미지는 카드의 좌측과 상하에 여백 없이 붙는다', (tester) async {
    final log = CoffeeLog(
      id: 'log-1',
      userId: 'user-1',
      cafeVisitDate: DateTime(2026, 2, 15),
      coffeeType: 'latte',
      coffeeName: '바닐라 라떼',
      cafeName: '테스트 카페',
      rating: 4.0,
      createdAt: DateTime(2026, 2, 15),
      updatedAt: DateTime(2026, 2, 15),
    );

    await tester.pumpWidget(
      _TestApp(
        child: Scaffold(body: CoffeeLogListTile(log: log)),
      ),
    );
    await tester.pumpAndSettle();

    final cardRect = tester.getRect(find.byType(Card));
    final imageRect = tester.getRect(
      find.byKey(const Key('coffee-log-list-tile-image')),
    );

    expect(imageRect.left, cardRect.left);
    expect(imageRect.top, cardRect.top);
    expect(imageRect.bottom, cardRect.bottom);
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
