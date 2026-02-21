import 'package:coffee_note_app/screens/community/post_markdown_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('post_markdown_utils', () {
    test('이미지 URL을 추출하고 코드 영역은 카운트하지 않는다', () {
      const content = '''
# 제목

![cover](https://example.com/cover.jpg)

`![inline](https://example.com/ignored-inline.jpg)`

```md
![code](https://example.com/ignored-block.jpg)
```

![pending](pending://abc123)
''';

      final imageUrls = extractImageUrlsFromMarkdown(content);

      expect(imageUrls, hasLength(2));
      expect(imageUrls, contains('https://example.com/cover.jpg'));
      expect(imageUrls, contains('pending://abc123'));
      expect(countMarkdownImages(content), 2);
    });

    test('커뮤니티 버킷 URL만 추출한다', () {
      const content = '''
![a](https://sample.supabase.co/storage/v1/object/public/community/u1/1.jpg)
![b](https://sample.supabase.co/storage/v1/object/public/logs/u1/2.jpg)
![c](pending://temp)
''';

      final communityUrls = extractCommunityImageUrls(content);

      expect(communityUrls, hasLength(1));
      expect(
        communityUrls.first,
        'https://sample.supabase.co/storage/v1/object/public/community/u1/1.jpg',
      );
    });

    test('pending 토큰을 업로드 URL로 치환한다', () {
      const source = '본문 ![img](pending://abc) 와 ![img2](pending://def) 입니다.';

      final replaced = replacePendingImageTokens(source, {
        'pending://abc': 'https://cdn.example.com/a.jpg',
        'pending://def': 'https://cdn.example.com/b.jpg',
      });

      expect(replaced, contains('![img](https://cdn.example.com/a.jpg)'));
      expect(replaced, contains('![img2](https://cdn.example.com/b.jpg)'));
      expect(replaced, isNot(contains('pending://')));
    });

    test('목록 미리보기용 plain text로 변환한다', () {
      const content = '''
## 오늘의 커피
- 에티오피아 내추럴
- 향: 딸기, 꽃향

![photo](https://example.com/1.jpg)

> 오늘은 산미가 좋았습니다.
''';

      final snippet = markdownToPlainTextSnippet(content);

      expect(snippet, contains('오늘의 커피'));
      expect(snippet, contains('에티오피아 내추럴'));
      expect(snippet, contains('오늘은 산미가 좋았습니다.'));
      expect(snippet, isNot(contains('![')));
    });
  });
}
