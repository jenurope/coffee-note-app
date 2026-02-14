// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bean_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BeanListState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BeanListState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BeanListState()';
}


}

/// @nodoc
class $BeanListStateCopyWith<$Res>  {
$BeanListStateCopyWith(BeanListState _, $Res Function(BeanListState) __);
}


/// Adds pattern-matching-related methods to [BeanListState].
extension BeanListStatePatterns on BeanListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( BeanListInitial value)?  initial,TResult Function( BeanListLoading value)?  loading,TResult Function( BeanListLoaded value)?  loaded,TResult Function( BeanListError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case BeanListInitial() when initial != null:
return initial(_that);case BeanListLoading() when loading != null:
return loading(_that);case BeanListLoaded() when loaded != null:
return loaded(_that);case BeanListError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( BeanListInitial value)  initial,required TResult Function( BeanListLoading value)  loading,required TResult Function( BeanListLoaded value)  loaded,required TResult Function( BeanListError value)  error,}){
final _that = this;
switch (_that) {
case BeanListInitial():
return initial(_that);case BeanListLoading():
return loading(_that);case BeanListLoaded():
return loaded(_that);case BeanListError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( BeanListInitial value)?  initial,TResult? Function( BeanListLoading value)?  loading,TResult? Function( BeanListLoaded value)?  loaded,TResult? Function( BeanListError value)?  error,}){
final _that = this;
switch (_that) {
case BeanListInitial() when initial != null:
return initial(_that);case BeanListLoading() when loading != null:
return loading(_that);case BeanListLoaded() when loaded != null:
return loaded(_that);case BeanListError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function( BeanFilters filters)?  loading,TResult Function( List<CoffeeBean> beans,  BeanFilters filters)?  loaded,TResult Function( String message,  BeanFilters filters)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case BeanListInitial() when initial != null:
return initial();case BeanListLoading() when loading != null:
return loading(_that.filters);case BeanListLoaded() when loaded != null:
return loaded(_that.beans,_that.filters);case BeanListError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function( BeanFilters filters)  loading,required TResult Function( List<CoffeeBean> beans,  BeanFilters filters)  loaded,required TResult Function( String message,  BeanFilters filters)  error,}) {final _that = this;
switch (_that) {
case BeanListInitial():
return initial();case BeanListLoading():
return loading(_that.filters);case BeanListLoaded():
return loaded(_that.beans,_that.filters);case BeanListError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function( BeanFilters filters)?  loading,TResult? Function( List<CoffeeBean> beans,  BeanFilters filters)?  loaded,TResult? Function( String message,  BeanFilters filters)?  error,}) {final _that = this;
switch (_that) {
case BeanListInitial() when initial != null:
return initial();case BeanListLoading() when loading != null:
return loading(_that.filters);case BeanListLoaded() when loaded != null:
return loaded(_that.beans,_that.filters);case BeanListError() when error != null:
return error(_that.message,_that.filters);case _:
  return null;

}
}

}

/// @nodoc


class BeanListInitial implements BeanListState {
  const BeanListInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BeanListInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BeanListState.initial()';
}


}




/// @nodoc


class BeanListLoading implements BeanListState {
  const BeanListLoading({required this.filters});
  

 final  BeanFilters filters;

/// Create a copy of BeanListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BeanListLoadingCopyWith<BeanListLoading> get copyWith => _$BeanListLoadingCopyWithImpl<BeanListLoading>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BeanListLoading&&(identical(other.filters, filters) || other.filters == filters));
}


@override
int get hashCode => Object.hash(runtimeType,filters);

@override
String toString() {
  return 'BeanListState.loading(filters: $filters)';
}


}

/// @nodoc
abstract mixin class $BeanListLoadingCopyWith<$Res> implements $BeanListStateCopyWith<$Res> {
  factory $BeanListLoadingCopyWith(BeanListLoading value, $Res Function(BeanListLoading) _then) = _$BeanListLoadingCopyWithImpl;
@useResult
$Res call({
 BeanFilters filters
});


$BeanFiltersCopyWith<$Res> get filters;

}
/// @nodoc
class _$BeanListLoadingCopyWithImpl<$Res>
    implements $BeanListLoadingCopyWith<$Res> {
  _$BeanListLoadingCopyWithImpl(this._self, this._then);

  final BeanListLoading _self;
  final $Res Function(BeanListLoading) _then;

/// Create a copy of BeanListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? filters = null,}) {
  return _then(BeanListLoading(
filters: null == filters ? _self.filters : filters // ignore: cast_nullable_to_non_nullable
as BeanFilters,
  ));
}

/// Create a copy of BeanListState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BeanFiltersCopyWith<$Res> get filters {
  
  return $BeanFiltersCopyWith<$Res>(_self.filters, (value) {
    return _then(_self.copyWith(filters: value));
  });
}
}

/// @nodoc


class BeanListLoaded implements BeanListState {
  const BeanListLoaded({required final  List<CoffeeBean> beans, required this.filters}): _beans = beans;
  

 final  List<CoffeeBean> _beans;
 List<CoffeeBean> get beans {
  if (_beans is EqualUnmodifiableListView) return _beans;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_beans);
}

 final  BeanFilters filters;

/// Create a copy of BeanListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BeanListLoadedCopyWith<BeanListLoaded> get copyWith => _$BeanListLoadedCopyWithImpl<BeanListLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BeanListLoaded&&const DeepCollectionEquality().equals(other._beans, _beans)&&(identical(other.filters, filters) || other.filters == filters));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_beans),filters);

@override
String toString() {
  return 'BeanListState.loaded(beans: $beans, filters: $filters)';
}


}

/// @nodoc
abstract mixin class $BeanListLoadedCopyWith<$Res> implements $BeanListStateCopyWith<$Res> {
  factory $BeanListLoadedCopyWith(BeanListLoaded value, $Res Function(BeanListLoaded) _then) = _$BeanListLoadedCopyWithImpl;
@useResult
$Res call({
 List<CoffeeBean> beans, BeanFilters filters
});


$BeanFiltersCopyWith<$Res> get filters;

}
/// @nodoc
class _$BeanListLoadedCopyWithImpl<$Res>
    implements $BeanListLoadedCopyWith<$Res> {
  _$BeanListLoadedCopyWithImpl(this._self, this._then);

  final BeanListLoaded _self;
  final $Res Function(BeanListLoaded) _then;

/// Create a copy of BeanListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? beans = null,Object? filters = null,}) {
  return _then(BeanListLoaded(
beans: null == beans ? _self._beans : beans // ignore: cast_nullable_to_non_nullable
as List<CoffeeBean>,filters: null == filters ? _self.filters : filters // ignore: cast_nullable_to_non_nullable
as BeanFilters,
  ));
}

/// Create a copy of BeanListState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BeanFiltersCopyWith<$Res> get filters {
  
  return $BeanFiltersCopyWith<$Res>(_self.filters, (value) {
    return _then(_self.copyWith(filters: value));
  });
}
}

/// @nodoc


class BeanListError implements BeanListState {
  const BeanListError({required this.message, required this.filters});
  

 final  String message;
 final  BeanFilters filters;

/// Create a copy of BeanListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BeanListErrorCopyWith<BeanListError> get copyWith => _$BeanListErrorCopyWithImpl<BeanListError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BeanListError&&(identical(other.message, message) || other.message == message)&&(identical(other.filters, filters) || other.filters == filters));
}


@override
int get hashCode => Object.hash(runtimeType,message,filters);

@override
String toString() {
  return 'BeanListState.error(message: $message, filters: $filters)';
}


}

/// @nodoc
abstract mixin class $BeanListErrorCopyWith<$Res> implements $BeanListStateCopyWith<$Res> {
  factory $BeanListErrorCopyWith(BeanListError value, $Res Function(BeanListError) _then) = _$BeanListErrorCopyWithImpl;
@useResult
$Res call({
 String message, BeanFilters filters
});


$BeanFiltersCopyWith<$Res> get filters;

}
/// @nodoc
class _$BeanListErrorCopyWithImpl<$Res>
    implements $BeanListErrorCopyWith<$Res> {
  _$BeanListErrorCopyWithImpl(this._self, this._then);

  final BeanListError _self;
  final $Res Function(BeanListError) _then;

/// Create a copy of BeanListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? filters = null,}) {
  return _then(BeanListError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,filters: null == filters ? _self.filters : filters // ignore: cast_nullable_to_non_nullable
as BeanFilters,
  ));
}

/// Create a copy of BeanListState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BeanFiltersCopyWith<$Res> get filters {
  
  return $BeanFiltersCopyWith<$Res>(_self.filters, (value) {
    return _then(_self.copyWith(filters: value));
  });
}
}

// dart format on
