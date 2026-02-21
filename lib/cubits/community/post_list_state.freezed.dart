// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostListState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostListState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PostListState()';
}


}

/// @nodoc
class $PostListStateCopyWith<$Res>  {
$PostListStateCopyWith(PostListState _, $Res Function(PostListState) __);
}


/// Adds pattern-matching-related methods to [PostListState].
extension PostListStatePatterns on PostListState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PostListInitial value)?  initial,TResult Function( PostListLoading value)?  loading,TResult Function( PostListLoaded value)?  loaded,TResult Function( PostListError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PostListInitial() when initial != null:
return initial(_that);case PostListLoading() when loading != null:
return loading(_that);case PostListLoaded() when loaded != null:
return loaded(_that);case PostListError() when error != null:
return error(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PostListInitial value)  initial,required TResult Function( PostListLoading value)  loading,required TResult Function( PostListLoaded value)  loaded,required TResult Function( PostListError value)  error,}){
final _that = this;
switch (_that) {
case PostListInitial():
return initial(_that);case PostListLoading():
return loading(_that);case PostListLoaded():
return loaded(_that);case PostListError():
return error(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PostListInitial value)?  initial,TResult? Function( PostListLoading value)?  loading,TResult? Function( PostListLoaded value)?  loaded,TResult? Function( PostListError value)?  error,}){
final _that = this;
switch (_that) {
case PostListInitial() when initial != null:
return initial(_that);case PostListLoading() when loading != null:
return loading(_that);case PostListLoaded() when loaded != null:
return loaded(_that);case PostListError() when error != null:
return error(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function( PostFilters filters)?  loading,TResult Function( List<CommunityPost> posts,  PostFilters filters,  bool isLoadingMore,  bool hasMore)?  loaded,TResult Function( String message,  PostFilters filters)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PostListInitial() when initial != null:
return initial();case PostListLoading() when loading != null:
return loading(_that.filters);case PostListLoaded() when loaded != null:
return loaded(_that.posts,_that.filters,_that.isLoadingMore,_that.hasMore);case PostListError() when error != null:
return error(_that.message,_that.filters);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function( PostFilters filters)  loading,required TResult Function( List<CommunityPost> posts,  PostFilters filters,  bool isLoadingMore,  bool hasMore)  loaded,required TResult Function( String message,  PostFilters filters)  error,}) {final _that = this;
switch (_that) {
case PostListInitial():
return initial();case PostListLoading():
return loading(_that.filters);case PostListLoaded():
return loaded(_that.posts,_that.filters,_that.isLoadingMore,_that.hasMore);case PostListError():
return error(_that.message,_that.filters);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function( PostFilters filters)?  loading,TResult? Function( List<CommunityPost> posts,  PostFilters filters,  bool isLoadingMore,  bool hasMore)?  loaded,TResult? Function( String message,  PostFilters filters)?  error,}) {final _that = this;
switch (_that) {
case PostListInitial() when initial != null:
return initial();case PostListLoading() when loading != null:
return loading(_that.filters);case PostListLoaded() when loaded != null:
return loaded(_that.posts,_that.filters,_that.isLoadingMore,_that.hasMore);case PostListError() when error != null:
return error(_that.message,_that.filters);case _:
  return null;

}
}

}

/// @nodoc


class PostListInitial implements PostListState {
  const PostListInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostListInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PostListState.initial()';
}


}




/// @nodoc


class PostListLoading implements PostListState {
  const PostListLoading({required this.filters});
  

 final  PostFilters filters;

/// Create a copy of PostListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostListLoadingCopyWith<PostListLoading> get copyWith => _$PostListLoadingCopyWithImpl<PostListLoading>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostListLoading&&(identical(other.filters, filters) || other.filters == filters));
}


@override
int get hashCode => Object.hash(runtimeType,filters);

@override
String toString() {
  return 'PostListState.loading(filters: $filters)';
}


}

/// @nodoc
abstract mixin class $PostListLoadingCopyWith<$Res> implements $PostListStateCopyWith<$Res> {
  factory $PostListLoadingCopyWith(PostListLoading value, $Res Function(PostListLoading) _then) = _$PostListLoadingCopyWithImpl;
@useResult
$Res call({
 PostFilters filters
});


$PostFiltersCopyWith<$Res> get filters;

}
/// @nodoc
class _$PostListLoadingCopyWithImpl<$Res>
    implements $PostListLoadingCopyWith<$Res> {
  _$PostListLoadingCopyWithImpl(this._self, this._then);

  final PostListLoading _self;
  final $Res Function(PostListLoading) _then;

/// Create a copy of PostListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? filters = null,}) {
  return _then(PostListLoading(
filters: null == filters ? _self.filters : filters // ignore: cast_nullable_to_non_nullable
as PostFilters,
  ));
}

/// Create a copy of PostListState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostFiltersCopyWith<$Res> get filters {
  
  return $PostFiltersCopyWith<$Res>(_self.filters, (value) {
    return _then(_self.copyWith(filters: value));
  });
}
}

/// @nodoc


class PostListLoaded implements PostListState {
  const PostListLoaded({required final  List<CommunityPost> posts, required this.filters, this.isLoadingMore = false, this.hasMore = true}): _posts = posts;
  

 final  List<CommunityPost> _posts;
 List<CommunityPost> get posts {
  if (_posts is EqualUnmodifiableListView) return _posts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_posts);
}

 final  PostFilters filters;
@JsonKey() final  bool isLoadingMore;
@JsonKey() final  bool hasMore;

/// Create a copy of PostListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostListLoadedCopyWith<PostListLoaded> get copyWith => _$PostListLoadedCopyWithImpl<PostListLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostListLoaded&&const DeepCollectionEquality().equals(other._posts, _posts)&&(identical(other.filters, filters) || other.filters == filters)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_posts),filters,isLoadingMore,hasMore);

@override
String toString() {
  return 'PostListState.loaded(posts: $posts, filters: $filters, isLoadingMore: $isLoadingMore, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class $PostListLoadedCopyWith<$Res> implements $PostListStateCopyWith<$Res> {
  factory $PostListLoadedCopyWith(PostListLoaded value, $Res Function(PostListLoaded) _then) = _$PostListLoadedCopyWithImpl;
@useResult
$Res call({
 List<CommunityPost> posts, PostFilters filters, bool isLoadingMore, bool hasMore
});


$PostFiltersCopyWith<$Res> get filters;

}
/// @nodoc
class _$PostListLoadedCopyWithImpl<$Res>
    implements $PostListLoadedCopyWith<$Res> {
  _$PostListLoadedCopyWithImpl(this._self, this._then);

  final PostListLoaded _self;
  final $Res Function(PostListLoaded) _then;

/// Create a copy of PostListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? posts = null,Object? filters = null,Object? isLoadingMore = null,Object? hasMore = null,}) {
  return _then(PostListLoaded(
posts: null == posts ? _self._posts : posts // ignore: cast_nullable_to_non_nullable
as List<CommunityPost>,filters: null == filters ? _self.filters : filters // ignore: cast_nullable_to_non_nullable
as PostFilters,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of PostListState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostFiltersCopyWith<$Res> get filters {
  
  return $PostFiltersCopyWith<$Res>(_self.filters, (value) {
    return _then(_self.copyWith(filters: value));
  });
}
}

/// @nodoc


class PostListError implements PostListState {
  const PostListError({required this.message, required this.filters});
  

 final  String message;
 final  PostFilters filters;

/// Create a copy of PostListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostListErrorCopyWith<PostListError> get copyWith => _$PostListErrorCopyWithImpl<PostListError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostListError&&(identical(other.message, message) || other.message == message)&&(identical(other.filters, filters) || other.filters == filters));
}


@override
int get hashCode => Object.hash(runtimeType,message,filters);

@override
String toString() {
  return 'PostListState.error(message: $message, filters: $filters)';
}


}

/// @nodoc
abstract mixin class $PostListErrorCopyWith<$Res> implements $PostListStateCopyWith<$Res> {
  factory $PostListErrorCopyWith(PostListError value, $Res Function(PostListError) _then) = _$PostListErrorCopyWithImpl;
@useResult
$Res call({
 String message, PostFilters filters
});


$PostFiltersCopyWith<$Res> get filters;

}
/// @nodoc
class _$PostListErrorCopyWithImpl<$Res>
    implements $PostListErrorCopyWith<$Res> {
  _$PostListErrorCopyWithImpl(this._self, this._then);

  final PostListError _self;
  final $Res Function(PostListError) _then;

/// Create a copy of PostListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? filters = null,}) {
  return _then(PostListError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,filters: null == filters ? _self.filters : filters // ignore: cast_nullable_to_non_nullable
as PostFilters,
  ));
}

/// Create a copy of PostListState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostFiltersCopyWith<$Res> get filters {
  
  return $PostFiltersCopyWith<$Res>(_self.filters, (value) {
    return _then(_self.copyWith(filters: value));
  });
}
}

// dart format on
