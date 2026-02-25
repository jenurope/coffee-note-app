// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_comment_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MyCommentListState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyCommentListState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MyCommentListState()';
}


}

/// @nodoc
class $MyCommentListStateCopyWith<$Res>  {
$MyCommentListStateCopyWith(MyCommentListState _, $Res Function(MyCommentListState) __);
}


/// Adds pattern-matching-related methods to [MyCommentListState].
extension MyCommentListStatePatterns on MyCommentListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( MyCommentListInitial value)?  initial,TResult Function( MyCommentListLoading value)?  loading,TResult Function( MyCommentListLoaded value)?  loaded,TResult Function( MyCommentListError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case MyCommentListInitial() when initial != null:
return initial(_that);case MyCommentListLoading() when loading != null:
return loading(_that);case MyCommentListLoaded() when loaded != null:
return loaded(_that);case MyCommentListError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( MyCommentListInitial value)  initial,required TResult Function( MyCommentListLoading value)  loading,required TResult Function( MyCommentListLoaded value)  loaded,required TResult Function( MyCommentListError value)  error,}){
final _that = this;
switch (_that) {
case MyCommentListInitial():
return initial(_that);case MyCommentListLoading():
return loading(_that);case MyCommentListLoaded():
return loaded(_that);case MyCommentListError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( MyCommentListInitial value)?  initial,TResult? Function( MyCommentListLoading value)?  loading,TResult? Function( MyCommentListLoaded value)?  loaded,TResult? Function( MyCommentListError value)?  error,}){
final _that = this;
switch (_that) {
case MyCommentListInitial() when initial != null:
return initial(_that);case MyCommentListLoading() when loading != null:
return loading(_that);case MyCommentListLoaded() when loaded != null:
return loaded(_that);case MyCommentListError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<CommunityComment> comments,  bool isLoadingMore,  bool hasMore)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case MyCommentListInitial() when initial != null:
return initial();case MyCommentListLoading() when loading != null:
return loading();case MyCommentListLoaded() when loaded != null:
return loaded(_that.comments,_that.isLoadingMore,_that.hasMore);case MyCommentListError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<CommunityComment> comments,  bool isLoadingMore,  bool hasMore)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case MyCommentListInitial():
return initial();case MyCommentListLoading():
return loading();case MyCommentListLoaded():
return loaded(_that.comments,_that.isLoadingMore,_that.hasMore);case MyCommentListError():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<CommunityComment> comments,  bool isLoadingMore,  bool hasMore)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case MyCommentListInitial() when initial != null:
return initial();case MyCommentListLoading() when loading != null:
return loading();case MyCommentListLoaded() when loaded != null:
return loaded(_that.comments,_that.isLoadingMore,_that.hasMore);case MyCommentListError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class MyCommentListInitial implements MyCommentListState {
  const MyCommentListInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyCommentListInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MyCommentListState.initial()';
}


}




/// @nodoc


class MyCommentListLoading implements MyCommentListState {
  const MyCommentListLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyCommentListLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MyCommentListState.loading()';
}


}




/// @nodoc


class MyCommentListLoaded implements MyCommentListState {
  const MyCommentListLoaded({required final  List<CommunityComment> comments, this.isLoadingMore = false, this.hasMore = true}): _comments = comments;
  

 final  List<CommunityComment> _comments;
 List<CommunityComment> get comments {
  if (_comments is EqualUnmodifiableListView) return _comments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_comments);
}

@JsonKey() final  bool isLoadingMore;
@JsonKey() final  bool hasMore;

/// Create a copy of MyCommentListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MyCommentListLoadedCopyWith<MyCommentListLoaded> get copyWith => _$MyCommentListLoadedCopyWithImpl<MyCommentListLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyCommentListLoaded&&const DeepCollectionEquality().equals(other._comments, _comments)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_comments),isLoadingMore,hasMore);

@override
String toString() {
  return 'MyCommentListState.loaded(comments: $comments, isLoadingMore: $isLoadingMore, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class $MyCommentListLoadedCopyWith<$Res> implements $MyCommentListStateCopyWith<$Res> {
  factory $MyCommentListLoadedCopyWith(MyCommentListLoaded value, $Res Function(MyCommentListLoaded) _then) = _$MyCommentListLoadedCopyWithImpl;
@useResult
$Res call({
 List<CommunityComment> comments, bool isLoadingMore, bool hasMore
});




}
/// @nodoc
class _$MyCommentListLoadedCopyWithImpl<$Res>
    implements $MyCommentListLoadedCopyWith<$Res> {
  _$MyCommentListLoadedCopyWithImpl(this._self, this._then);

  final MyCommentListLoaded _self;
  final $Res Function(MyCommentListLoaded) _then;

/// Create a copy of MyCommentListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? comments = null,Object? isLoadingMore = null,Object? hasMore = null,}) {
  return _then(MyCommentListLoaded(
comments: null == comments ? _self._comments : comments // ignore: cast_nullable_to_non_nullable
as List<CommunityComment>,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class MyCommentListError implements MyCommentListState {
  const MyCommentListError({required this.message});
  

 final  String message;

/// Create a copy of MyCommentListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MyCommentListErrorCopyWith<MyCommentListError> get copyWith => _$MyCommentListErrorCopyWithImpl<MyCommentListError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyCommentListError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'MyCommentListState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $MyCommentListErrorCopyWith<$Res> implements $MyCommentListStateCopyWith<$Res> {
  factory $MyCommentListErrorCopyWith(MyCommentListError value, $Res Function(MyCommentListError) _then) = _$MyCommentListErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$MyCommentListErrorCopyWithImpl<$Res>
    implements $MyCommentListErrorCopyWith<$Res> {
  _$MyCommentListErrorCopyWithImpl(this._self, this._then);

  final MyCommentListError _self;
  final $Res Function(MyCommentListError) _then;

/// Create a copy of MyCommentListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(MyCommentListError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
