// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'log_filters.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LogFilters {

 bool get onlyMine; String? get searchQuery; String? get sortBy; bool get ascending; double? get minRating; String? get coffeeType; int? get limit; int? get offset;
/// Create a copy of LogFilters
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LogFiltersCopyWith<LogFilters> get copyWith => _$LogFiltersCopyWithImpl<LogFilters>(this as LogFilters, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogFilters&&(identical(other.onlyMine, onlyMine) || other.onlyMine == onlyMine)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.ascending, ascending) || other.ascending == ascending)&&(identical(other.minRating, minRating) || other.minRating == minRating)&&(identical(other.coffeeType, coffeeType) || other.coffeeType == coffeeType)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.offset, offset) || other.offset == offset));
}


@override
int get hashCode => Object.hash(runtimeType,onlyMine,searchQuery,sortBy,ascending,minRating,coffeeType,limit,offset);

@override
String toString() {
  return 'LogFilters(onlyMine: $onlyMine, searchQuery: $searchQuery, sortBy: $sortBy, ascending: $ascending, minRating: $minRating, coffeeType: $coffeeType, limit: $limit, offset: $offset)';
}


}

/// @nodoc
abstract mixin class $LogFiltersCopyWith<$Res>  {
  factory $LogFiltersCopyWith(LogFilters value, $Res Function(LogFilters) _then) = _$LogFiltersCopyWithImpl;
@useResult
$Res call({
 bool onlyMine, String? searchQuery, String? sortBy, bool ascending, double? minRating, String? coffeeType, int? limit, int? offset
});




}
/// @nodoc
class _$LogFiltersCopyWithImpl<$Res>
    implements $LogFiltersCopyWith<$Res> {
  _$LogFiltersCopyWithImpl(this._self, this._then);

  final LogFilters _self;
  final $Res Function(LogFilters) _then;

/// Create a copy of LogFilters
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? onlyMine = null,Object? searchQuery = freezed,Object? sortBy = freezed,Object? ascending = null,Object? minRating = freezed,Object? coffeeType = freezed,Object? limit = freezed,Object? offset = freezed,}) {
  return _then(_self.copyWith(
onlyMine: null == onlyMine ? _self.onlyMine : onlyMine // ignore: cast_nullable_to_non_nullable
as bool,searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,sortBy: freezed == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String?,ascending: null == ascending ? _self.ascending : ascending // ignore: cast_nullable_to_non_nullable
as bool,minRating: freezed == minRating ? _self.minRating : minRating // ignore: cast_nullable_to_non_nullable
as double?,coffeeType: freezed == coffeeType ? _self.coffeeType : coffeeType // ignore: cast_nullable_to_non_nullable
as String?,limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,offset: freezed == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [LogFilters].
extension LogFiltersPatterns on LogFilters {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LogFilters value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LogFilters() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LogFilters value)  $default,){
final _that = this;
switch (_that) {
case _LogFilters():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LogFilters value)?  $default,){
final _that = this;
switch (_that) {
case _LogFilters() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool onlyMine,  String? searchQuery,  String? sortBy,  bool ascending,  double? minRating,  String? coffeeType,  int? limit,  int? offset)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LogFilters() when $default != null:
return $default(_that.onlyMine,_that.searchQuery,_that.sortBy,_that.ascending,_that.minRating,_that.coffeeType,_that.limit,_that.offset);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool onlyMine,  String? searchQuery,  String? sortBy,  bool ascending,  double? minRating,  String? coffeeType,  int? limit,  int? offset)  $default,) {final _that = this;
switch (_that) {
case _LogFilters():
return $default(_that.onlyMine,_that.searchQuery,_that.sortBy,_that.ascending,_that.minRating,_that.coffeeType,_that.limit,_that.offset);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool onlyMine,  String? searchQuery,  String? sortBy,  bool ascending,  double? minRating,  String? coffeeType,  int? limit,  int? offset)?  $default,) {final _that = this;
switch (_that) {
case _LogFilters() when $default != null:
return $default(_that.onlyMine,_that.searchQuery,_that.sortBy,_that.ascending,_that.minRating,_that.coffeeType,_that.limit,_that.offset);case _:
  return null;

}
}

}

/// @nodoc


class _LogFilters implements LogFilters {
  const _LogFilters({this.onlyMine = true, this.searchQuery, this.sortBy, this.ascending = false, this.minRating, this.coffeeType, this.limit, this.offset});
  

@override@JsonKey() final  bool onlyMine;
@override final  String? searchQuery;
@override final  String? sortBy;
@override@JsonKey() final  bool ascending;
@override final  double? minRating;
@override final  String? coffeeType;
@override final  int? limit;
@override final  int? offset;

/// Create a copy of LogFilters
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LogFiltersCopyWith<_LogFilters> get copyWith => __$LogFiltersCopyWithImpl<_LogFilters>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LogFilters&&(identical(other.onlyMine, onlyMine) || other.onlyMine == onlyMine)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.ascending, ascending) || other.ascending == ascending)&&(identical(other.minRating, minRating) || other.minRating == minRating)&&(identical(other.coffeeType, coffeeType) || other.coffeeType == coffeeType)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.offset, offset) || other.offset == offset));
}


@override
int get hashCode => Object.hash(runtimeType,onlyMine,searchQuery,sortBy,ascending,minRating,coffeeType,limit,offset);

@override
String toString() {
  return 'LogFilters(onlyMine: $onlyMine, searchQuery: $searchQuery, sortBy: $sortBy, ascending: $ascending, minRating: $minRating, coffeeType: $coffeeType, limit: $limit, offset: $offset)';
}


}

/// @nodoc
abstract mixin class _$LogFiltersCopyWith<$Res> implements $LogFiltersCopyWith<$Res> {
  factory _$LogFiltersCopyWith(_LogFilters value, $Res Function(_LogFilters) _then) = __$LogFiltersCopyWithImpl;
@override @useResult
$Res call({
 bool onlyMine, String? searchQuery, String? sortBy, bool ascending, double? minRating, String? coffeeType, int? limit, int? offset
});




}
/// @nodoc
class __$LogFiltersCopyWithImpl<$Res>
    implements _$LogFiltersCopyWith<$Res> {
  __$LogFiltersCopyWithImpl(this._self, this._then);

  final _LogFilters _self;
  final $Res Function(_LogFilters) _then;

/// Create a copy of LogFilters
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? onlyMine = null,Object? searchQuery = freezed,Object? sortBy = freezed,Object? ascending = null,Object? minRating = freezed,Object? coffeeType = freezed,Object? limit = freezed,Object? offset = freezed,}) {
  return _then(_LogFilters(
onlyMine: null == onlyMine ? _self.onlyMine : onlyMine // ignore: cast_nullable_to_non_nullable
as bool,searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,sortBy: freezed == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String?,ascending: null == ascending ? _self.ascending : ascending // ignore: cast_nullable_to_non_nullable
as bool,minRating: freezed == minRating ? _self.minRating : minRating // ignore: cast_nullable_to_non_nullable
as double?,coffeeType: freezed == coffeeType ? _self.coffeeType : coffeeType // ignore: cast_nullable_to_non_nullable
as String?,limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,offset: freezed == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
