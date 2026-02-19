import 'user_profile.dart';

class CommunityPost {
  final String id;
  final String userId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 관계 데이터
  final UserProfile? author;
  final List<CommunityComment>? comments;
  final int? commentCount;

  CommunityPost({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    this.comments,
    this.commentCount,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      author: json['profiles'] != null
          ? UserProfile.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
      comments: json['community_comments'] != null
          ? (json['community_comments'] as List)
                .map(
                  (e) => CommunityComment.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
      commentCount: json['comment_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {'user_id': userId, 'title': title, 'content': content};
  }

  CommunityPost copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserProfile? author,
    List<CommunityComment>? comments,
    int? commentCount,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      comments: comments ?? this.comments,
      commentCount: commentCount ?? this.commentCount,
    );
  }
}

class CommunityComment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final String? parentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 관계 데이터
  final UserProfile? author;
  final List<CommunityComment>? replies;

  CommunityComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    this.parentId,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    this.replies,
  });

  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    return CommunityComment(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      parentId: json['parent_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      author: json['profiles'] != null
          ? UserProfile.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'parent_id': parentId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'parent_id': parentId,
    };
  }

  CommunityComment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? content,
    String? parentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserProfile? author,
    List<CommunityComment>? replies,
  }) {
    return CommunityComment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      replies: replies ?? this.replies,
    );
  }
}
