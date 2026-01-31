import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/community_post.dart';
import '../services/community_service.dart';

// Service Provider
final communityServiceProvider =
    Provider<CommunityService>((ref) => CommunityService());

// 커뮤니티 게시글 목록 Provider
final communityPostsProvider =
    FutureProvider.family<List<CommunityPost>, PostFilters>(
  (ref, filters) async {
    final service = ref.watch(communityServiceProvider);
    return await service.getPosts(
      searchQuery: filters.searchQuery,
      sortBy: filters.sortBy,
      ascending: filters.ascending,
      limit: filters.limit,
      offset: filters.offset,
    );
  },
);

// 커뮤니티 게시글 상세 Provider
final communityPostDetailProvider =
    FutureProvider.family<CommunityPost?, String>(
  (ref, id) async {
    final service = ref.watch(communityServiceProvider);
    return await service.getPost(id);
  },
);

// Filter 클래스
class PostFilters {
  final String? searchQuery;
  final String? sortBy;
  final bool ascending;
  final int? limit;
  final int? offset;

  const PostFilters({
    this.searchQuery,
    this.sortBy,
    this.ascending = false,
    this.limit,
    this.offset,
  });

  PostFilters copyWith({
    String? searchQuery,
    String? sortBy,
    bool? ascending,
    int? limit,
    int? offset,
  }) {
    return PostFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PostFilters &&
        other.searchQuery == searchQuery &&
        other.sortBy == sortBy &&
        other.ascending == ascending &&
        other.limit == limit &&
        other.offset == offset;
  }

  @override
  int get hashCode => Object.hash(
        searchQuery,
        sortBy,
        ascending,
        limit,
        offset,
      );
}
