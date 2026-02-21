import 'package:coffee_note_app/screens/community/widgets/post_markdown_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PostMarkdownView', () {
    testWidgets('마크다운 텍스트를 렌더링한다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PostMarkdownView(
              content: '# 제목\n\n- 항목1\n- 항목2\n\n**강조** 텍스트',
            ),
          ),
        ),
      );

      expect(find.text('제목'), findsOneWidget);
      expect(find.text('항목1'), findsOneWidget);
      expect(find.text('항목2'), findsOneWidget);
      expect(find.textContaining('강조'), findsOneWidget);
    });

    testWidgets('원격 이미지 노드를 렌더링한다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PostMarkdownView(
              content: '![cover](https://example.com/cover.jpg)',
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('pending 이미지는 로컬 경로를 사용한다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PostMarkdownView(
              content: '![pending](pending://temp-1)',
              pendingImagePaths: {'pending://temp-1': '/tmp/pending-image.png'},
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsWidgets);
    });
  });
}
