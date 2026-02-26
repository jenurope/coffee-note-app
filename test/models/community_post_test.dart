import 'package:coffee_note_app/models/community_post.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommunityPost.fromJson', () {
    test('is_deleted_content가 true면 삭제 상태를 파싱한다', () {
      final post = CommunityPost.fromJson(
        _baseJson({'is_deleted_content': true}),
      );

      expect(post.isDeletedContent, isTrue);
    });

    test('is_deleted_content가 없으면 기본값 false를 유지한다', () {
      final post = CommunityPost.fromJson(_baseJson({}));

      expect(post.isDeletedContent, isFalse);
    });

    test('comment_count가 있으면 comment_stats보다 우선한다', () {
      final post = CommunityPost.fromJson(
        _baseJson({
          'comment_count': 5,
          'comment_stats': [
            {'count': 3},
          ],
        }),
      );

      expect(post.commentCount, 5);
    });

    test('comment_count가 없으면 comment_stats 리스트의 count를 파싱한다', () {
      final post = CommunityPost.fromJson(
        _baseJson({
          'comment_stats': [
            {'count': 3},
          ],
        }),
      );

      expect(post.commentCount, 3);
    });

    test('comment_stats 맵의 문자열 count도 정수로 파싱한다', () {
      final post = CommunityPost.fromJson(
        _baseJson({
          'comment_stats': {'count': '7'},
        }),
      );

      expect(post.commentCount, 7);
    });

    test('comment_count와 comment_stats가 모두 없으면 null을 유지한다', () {
      final post = CommunityPost.fromJson(_baseJson({}));

      expect(post.commentCount, isNull);
    });
  });

  group('CommunityComment.fromJson', () {
    test('parent_id가 있으면 대댓글 parentId를 파싱한다', () {
      final comment = CommunityComment.fromJson(
        _baseCommentJson({'parent_id': 'comment-parent'}),
      );

      expect(comment.parentId, 'comment-parent');
    });

    test('is_deleted_content가 true면 삭제 상태를 파싱한다', () {
      final comment = CommunityComment.fromJson(
        _baseCommentJson({'is_deleted_content': true}),
      );

      expect(comment.isDeletedContent, isTrue);
    });

    test('is_deleted_content가 없으면 기본값 false를 유지한다', () {
      final comment = CommunityComment.fromJson(_baseCommentJson({}));

      expect(comment.isDeletedContent, isFalse);
    });

    test('toInsertJson은 parent_id를 포함한다', () {
      final comment = CommunityComment.fromJson(
        _baseCommentJson({'parent_id': 'comment-parent'}),
      );

      expect(comment.toInsertJson()['parent_id'], 'comment-parent');
    });
  });
}

Map<String, dynamic> _baseJson(Map<String, dynamic> extra) {
  return {
    'id': 'post-1',
    'user_id': 'user-1',
    'title': '테스트 제목',
    'content': '테스트 내용',
    'created_at': '2026-02-22T00:00:00.000Z',
    'updated_at': '2026-02-22T00:00:00.000Z',
    ...extra,
  };
}

Map<String, dynamic> _baseCommentJson(Map<String, dynamic> extra) {
  return {
    'id': 'comment-1',
    'post_id': 'post-1',
    'user_id': 'user-1',
    'content': '테스트 댓글',
    'parent_id': null,
    'created_at': '2026-02-22T00:00:00.000Z',
    'updated_at': '2026-02-22T00:00:00.000Z',
    ...extra,
  };
}
