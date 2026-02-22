import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:coffee_note_app/widgets/navigation/form_leave_confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('showFormLeaveConfirmDialog', () {
    testWidgets('등록 모드 문구와 나가기 버튼을 표시한다', (tester) async {
      await _pumpLauncher(tester, isEditing: false);

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('작성 중인 내용이 사라집니다. 나가시겠습니까?'), findsOneWidget);
      expect(find.text('취소'), findsOneWidget);
      expect(find.text('나가기'), findsOneWidget);
    });

    testWidgets('수정 모드 문구를 표시한다', (tester) async {
      await _pumpLauncher(tester, isEditing: true);

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('수정한 내용이 사라집니다. 나가시겠습니까?'), findsOneWidget);
      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();

      expect(find.text('수정한 내용이 사라집니다. 나가시겠습니까?'), findsNothing);
    });
  });
}

Future<void> _pumpLauncher(
  WidgetTester tester, {
  required bool isEditing,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ko'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () {
                  showFormLeaveConfirmDialog(context, isEditing: isEditing);
                },
                child: const Text('open'),
              );
            },
          ),
        ),
      ),
    ),
  );
}
