// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bean_filters.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BeanFilters {

 bool get onlyMine; String? get searchQuery; String? get sortBy; bool get ascending; double? get minRating; String? get roastLevel; int? get limit; int? get offset;
/// Create a copy of BeanFilters
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BeanFiltersCopyWith<BeanFilters> get copyWith => _$BeanFiltersCopyWithImpl<BeanFilters>(this as BeanFilters, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BeanFilters&&(identical(other.onlyMine, onlyMine) || other.onlyMine == onlyMine)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.ascending, ascending) || other.ascending == ascending)&&(identical(other.minRating, minRating) || other.minRating == minRating)&&(identical(other.roastLevel, roastLevel) || other.roastLevel == roastLevel)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.offset, offset) || other.offset == offset));
}


@override
int get hashCode => Object.hash(runtimeType,onlyMine,searchQuery,sortBy,ascending,minRating,roastLevel,limit,offset);

@override
String toString() {
  return 'BeanFilters(onlyMine: $onlyMine, searchQuery: $searchQuery, sortBy: $sortBy, ascending: $ascending, minRating: $minRating, roastLevel: $roastLevel, limit: $limit, offset: $offset)';
}


}

/// @nodoc
abstract mixin class $BeanFiltersCopyWith<$Res>  {
  factory $BeanFiltersCopyWith(BeanFilters value, $Res Function(BeanFilters) _then) = _$BeanFiltersCopyWithImpl;
@useResult
$Res call({
 bool onlyMine, String? searchQuery, String? sortBy, bool ascending, double? minRating, String? roastLevel, int? limit, int? offset
});




}
/// @nodoc
class _$BeanFiltersCopyWithImpl<$Res>
    implements $BeanFiltersCopyWith<$Res> {
  _$BeanFiltersCopyWithImpl(this._self, this._then);

  final BeanFilters _self;
  final $Res Function(BeanFilters) _then;

/// Create a copy of BeanFilters
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? onlyMine = null,Object? searchQuery = freezed,Object? sortBy = freezed,Object? ascending = null,Object? minRating = freezed,Object? roastLevel = freezed,Object? limit = freezed,Object? offset = freezed,}) {
  return _then(_self.copyWith(
onlyMine: null == onlyMine ? _self.onlyMine : onlyMine // ignore: cast_nullable_to_non_nullable
as bool,searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,sortBy: freezed == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String?,ascending: null == ascending ? _self.ascending : ascending // ignore: cast_nullable_to_non_nullable
as bool,minRating: freezed == minRating ? _self.minRating : minRating // ignore: cast_nullable_to_non_nullable
as double?,roastLevel: freezed == roastLevel ? _self.roastLevel : roastLevel // ignore: cast_nullable_to_non_nullable
as String?,limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,offset: freezed == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [BeanFilters].
extension BeanFiltersPatterns on BeanFilters {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BeanFilters value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BeanFilters() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BeanFilters value)  $default,){
final _that = this;
switch (_that) {
case _BeanFilters():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BeanFilters value)?  $default,){
final _that = this;
switch (_that) {
case _BeanFilters() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool onlyMine,  String? searchQuery,  String? sortBy,  bool ascending,  double? minRating,  String? roastLevel,  int? limit,  int? offset)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BeanFilters() when $default != null:
return $default(_that.onlyMine,_that.searchQuery,_that.sortBy,_that.ascending,_that.minRating,_that.roastLevel,_that.limit,_that.offset);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool onlyMine,  String? searchQuery,  String? sortBy,  bool ascending,  double? minRating,  String? roastLevel,  int? limit,  int? offset)  $default,) {final _that = this;
switch (_that) {
case _BeanFilters():
return $default(_that.onlyMine,_that.searchQuery,_that.sortBy,_that.ascending,_that.minRating,_that.roastLevel,_that.limit,_that.offset);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool onlyMine,  String? searchQuery,  String? sortBy,  bool ascending,  double? minRating,  String? roastLevel,  int? limit,  int? offset)?  $default,) {final _that = this;
switch (_that) {
case _BeanFilters() when $default != null:
return $default(_that.onlyMine,_that.searchQuery,_that.sortBy,_that.ascending,_that.minRating,_that.roastLevel,_that.limit,_that.offset);case _:
  return null;

}
}

}

/// @nodoc


class _BeanFilters implements BeanFilters {
  const _BeanFilters({this.onlyMine = true, this.searchQuery, this.sortBy, this.ascending = false, this.minRating, this.roastLevel, this.limit, this.offset});
  

@override@JsonKey() final  bool onlyMine;
@override final  String? searchQuery;
@override final  String? sortBy;
@override@JsonKey() final  bool ascending;
@override final  double? minRating;
@override final  String? roastLevel;
@override final  int? limit;
@override final  int? offset;

/// Create a copy of BeanFilters
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BeanFiltersCopyWith<_BeanFilters> get copyWith => __$BeanFiltersCopyWithImpl<_BeanFilters>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BeanFilters&&(identical(other.onlyMine, onlyMine) || other.onlyMine == onlyMine)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.ascending, ascending) || other.ascending == ascending)&&(identical(other.minRating, minRating) || other.minRating == minRating)&&(identical(other.roastLevel, roastLevel) || other.roastLevel == roastLevel)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.offset, offset) || other.offset == offset));
}


@override
int get hashCode => Object.hash(runtimeType,onlyMine,searchQuery,sortBy,ascending,minRating,roastLevel,limit,offset);

@override
String toString() {
  return 'BeanFilters(onlyMine: $onlyMine, searchQuery: $searchQuery, sortBy: $sortBy, ascending: $ascending, minRating: $minRating, roastLevel: $roastLevel, limit: $limit, offset: $offset)';
}


}

/// @nodoc
abstract mixin class _$BeanFiltersCopyWith<$Res> implements $BeanFiltersCopyWith<$Res> {
  factory _$BeanFiltersCopyWith(_BeanFilters value, $Res Function(_BeanFilters) _then) = __$BeanFiltersCopyWithImpl;
@override @useResult
$Res call({
 bool onlyMine, String? searchQuery, String? sortBy, bool ascending, double? minRating, String? roastLevel, int? limit, int? offset
});




}
/// @nodoc
class __$BeanFiltersCopyWithImpl<$Res>
    implements _$BeanFiltersCopyWith<$Res> {
  __$BeanFiltersCopyWithImpl(this._self, this._then);

  final _BeanFilters _self;
  final $Res Function(_BeanFilters) _then;

/// Create a copy of BeanFilters
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? onlyMine = null,Object? searchQuery = freezed,Object? sortBy = freezed,Object? ascending = null,Object? minRating = freezed,Object? roastLevel = freezed,Object? limit = freezed,Object? offset = freezed,}) {
  return _then(_BeanFilters(
onlyMine: null == onlyMine ? _self.onlyMine : onlyMine // ignore: cast_nullable_to_non_nullable
as bool,searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,sortBy: freezed == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String?,ascending: null == ascending ? _self.ascending : ascending // ignore: cast_nullable_to_non_nullable
as bool,minRating: freezed == minRating ? _self.minRating : minRating // ignore: cast_nullable_to_non_nullable
as double?,roastLevel: freezed == roastLevel ? _self.roastLevel : roastLevel // ignore: cast_nullable_to_non_nullable
as String?,limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,offset: freezed == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
