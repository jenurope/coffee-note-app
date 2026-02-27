import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:coffee_note_app/models/coffee_log.dart';
import 'package:coffee_note_app/widgets/coffee_log_card.dart';
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

  testWidgets('CoffeeLogCard에 별점 하단 방문일이 표시된다', (tester) async {
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
    final expectedDate = DateFormat.yMd('ko').format(log.cafeVisitDate);
    final expectedRating = log.rating.toStringAsFixed(1);

    await tester.pumpWidget(
      _TestApp(
        child: Scaffold(body: CoffeeLogCard(log: log)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(RatingStars), findsOneWidget);
    expect(find.text(expectedRating), findsOneWidget);
    expect(find.text(expectedDate), findsOneWidget);

    final hasVerticalRatingDate = tester
        .widgetList<Column>(find.byType(Column))
        .any((column) {
          final hasRatingRow = column.children.any((child) {
            if (child is! Row) {
              return false;
            }
            final hasRatingStars = child.children.any(
              (rowChild) => rowChild is RatingStars,
            );
            final hasRatingText = child.children.any(
              (rowChild) => rowChild is Text && rowChild.data == expectedRating,
            );
            return hasRatingStars && hasRatingText;
          });
          final hasDateText = column.children.any(
            (child) => child is Text && child.data == expectedDate,
          );
          return hasRatingRow && hasDateText;
        });
    expect(hasVerticalRatingDate, isTrue);

    final hasHorizontalRatingDate = tester
        .widgetList<Row>(find.byType(Row))
        .any((row) {
          final hasRating = row.children.any((child) => child is RatingStars);
          final hasDateText = row.children.any(
            (child) => child is Text && child.data == expectedDate,
          );
          return hasRating && hasDateText;
        });
    expect(hasHorizontalRatingDate, isFalse);
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
