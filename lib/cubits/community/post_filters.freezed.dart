// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_filters.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostFilters {

 String? get searchQuery; String? get sortBy; bool get ascending; int? get limit; int? get offset;
/// Create a copy of PostFilters
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostFiltersCopyWith<PostFilters> get copyWith => _$PostFiltersCopyWithImpl<PostFilters>(this as PostFilters, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostFilters&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.ascending, ascending) || other.ascending == ascending)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.offset, offset) || other.offset == offset));
}


@override
int get hashCode => Object.hash(runtimeType,searchQuery,sortBy,ascending,limit,offset);

@override
String toString() {
  return 'PostFilters(searchQuery: $searchQuery, sortBy: $sortBy, ascending: $ascending, limit: $limit, offset: $offset)';
}


}

/// @nodoc
abstract mixin class $PostFiltersCopyWith<$Res>  {
  factory $PostFiltersCopyWith(PostFilters value, $Res Function(PostFilters) _then) = _$PostFiltersCopyWithImpl;
@useResult
$Res call({
 String? searchQuery, String? sortBy, bool ascending, int? limit, int? offset
});




}
/// @nodoc
class _$PostFiltersCopyWithImpl<$Res>
    implements $PostFiltersCopyWith<$Res> {
  _$PostFiltersCopyWithImpl(this._self, this._then);

  final PostFilters _self;
  final $Res Function(PostFilters) _then;

/// Create a copy of PostFilters
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? searchQuery = freezed,Object? sortBy = freezed,Object? ascending = null,Object? limit = freezed,Object? offset = freezed,}) {
  return _then(_self.copyWith(
searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,sortBy: freezed == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String?,ascending: null == ascending ? _self.ascending : ascending // ignore: cast_nullable_to_non_nullable
as bool,limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,offset: freezed == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [PostFilters].
extension PostFiltersPatterns on PostFilters {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostFilters value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostFilters() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostFilters value)  $default,){
final _that = this;
switch (_that) {
case _PostFilters():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostFilters value)?  $default,){
final _that = this;
switch (_that) {
case _PostFilters() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? searchQuery,  String? sortBy,  bool ascending,  int? limit,  int? offset)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostFilters() when $default != null:
return $default(_that.searchQuery,_that.sortBy,_that.ascending,_that.limit,_that.offset);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? searchQuery,  String? sortBy,  bool ascending,  int? limit,  int? offset)  $default,) {final _that = this;
switch (_that) {
case _PostFilters():
return $default(_that.searchQuery,_that.sortBy,_that.ascending,_that.limit,_that.offset);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? searchQuery,  String? sortBy,  bool ascending,  int? limit,  int? offset)?  $default,) {final _that = this;
switch (_that) {
case _PostFilters() when $default != null:
return $default(_that.searchQuery,_that.sortBy,_that.ascending,_that.limit,_that.offset);case _:
  return null;

}
}

}

/// @nodoc


class _PostFilters implements PostFilters {
  const _PostFilters({this.searchQuery, this.sortBy, this.ascending = false, this.limit, this.offset});
  

@override final  String? searchQuery;
@override final  String? sortBy;
@override@JsonKey() final  bool ascending;
@override final  int? limit;
@override final  int? offset;

/// Create a copy of PostFilters
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostFiltersCopyWith<_PostFilters> get copyWith => __$PostFiltersCopyWithImpl<_PostFilters>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostFilters&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.ascending, ascending) || other.ascending == ascending)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.offset, offset) || other.offset == offset));
}


@override
int get hashCode => Object.hash(runtimeType,searchQuery,sortBy,ascending,limit,offset);

@override
String toString() {
  return 'PostFilters(searchQuery: $searchQuery, sortBy: $sortBy, ascending: $ascending, limit: $limit, offset: $offset)';
}


}

/// @nodoc
abstract mixin class _$PostFiltersCopyWith<$Res> implements $PostFiltersCopyWith<$Res> {
  factory _$PostFiltersCopyWith(_PostFilters value, $Res Function(_PostFilters) _then) = __$PostFiltersCopyWithImpl;
@override @useResult
$Res call({
 String? searchQuery, String? sortBy, bool ascending, int? limit, int? offset
});




}
/// @nodoc
class __$PostFiltersCopyWithImpl<$Res>
    implements _$PostFiltersCopyWith<$Res> {
  __$PostFiltersCopyWithImpl(this._self, this._then);

  final _PostFilters _self;
  final $Res Function(_PostFilters) _then;

/// Create a copy of PostFilters
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? searchQuery = freezed,Object? sortBy = freezed,Object? ascending = null,Object? limit = freezed,Object? offset = freezed,}) {
  return _then(_PostFilters(
searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,sortBy: freezed == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String?,ascending: null == ascending ? _self.ascending : ascending // ignore: cast_nullable_to_non_nullable
as bool,limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,offset: freezed == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
