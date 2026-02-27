import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:coffee_note_app/models/coffee_bean.dart';
import 'package:coffee_note_app/widgets/bean_card.dart';
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

  testWidgets('BeanCard에 별점 하단 구매일이 표시된다', (tester) async {
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
    final expectedDate = DateFormat.yMd('ko').format(bean.purchaseDate);

    await tester.pumpWidget(
      _TestApp(
        child: Scaffold(body: BeanCard(bean: bean)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(RatingStars), findsOneWidget);
    expect(find.text(expectedDate), findsOneWidget);

    final hasRatingDateColumn = tester
        .widgetList<Column>(find.byType(Column))
        .any((column) {
          final hasRatingRow = column.children.any((child) {
            if (child is! Row) {
              return false;
            }
            return child.children.any((rowChild) => rowChild is RatingStars);
          });
          final hasDateText = column.children.any(
            (child) => child is Text && child.data == expectedDate,
          );
          return hasRatingRow && hasDateText;
        });
    expect(hasRatingDateColumn, isTrue);
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
