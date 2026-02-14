// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bean_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BeanDetailState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BeanDetailState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BeanDetailState()';
}


}

/// @nodoc
class $BeanDetailStateCopyWith<$Res>  {
$BeanDetailStateCopyWith(BeanDetailState _, $Res Function(BeanDetailState) __);
}


/// Adds pattern-matching-related methods to [BeanDetailState].
extension BeanDetailStatePatterns on BeanDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( BeanDetailInitial value)?  initial,TResult Function( BeanDetailLoading value)?  loading,TResult Function( BeanDetailLoaded value)?  loaded,TResult Function( BeanDetailError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case BeanDetailInitial() when initial != null:
return initial(_that);case BeanDetailLoading() when loading != null:
return loading(_that);case BeanDetailLoaded() when loaded != null:
return loaded(_that);case BeanDetailError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( BeanDetailInitial value)  initial,required TResult Function( BeanDetailLoading value)  loading,required TResult Function( BeanDetailLoaded value)  loaded,required TResult Function( BeanDetailError value)  error,}){
final _that = this;
switch (_that) {
case BeanDetailInitial():
return initial(_that);case BeanDetailLoading():
return loading(_that);case BeanDetailLoaded():
return loaded(_that);case BeanDetailError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( BeanDetailInitial value)?  initial,TResult? Function( BeanDetailLoading value)?  loading,TResult? Function( BeanDetailLoaded value)?  loaded,TResult? Function( BeanDetailError value)?  error,}){
final _that = this;
switch (_that) {
case BeanDetailInitial() when initial != null:
return initial(_that);case BeanDetailLoading() when loading != null:
return loading(_that);case BeanDetailLoaded() when loaded != null:
return loaded(_that);case BeanDetailError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( CoffeeBean bean)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case BeanDetailInitial() when initial != null:
return initial();case BeanDetailLoading() when loading != null:
return loading();case BeanDetailLoaded() when loaded != null:
return loaded(_that.bean);case BeanDetailError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( CoffeeBean bean)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case BeanDetailInitial():
return initial();case BeanDetailLoading():
return loading();case BeanDetailLoaded():
return loaded(_that.bean);case BeanDetailError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( CoffeeBean bean)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case BeanDetailInitial() when initial != null:
return initial();case BeanDetailLoading() when loading != null:
return loading();case BeanDetailLoaded() when loaded != null:
return loaded(_that.bean);case BeanDetailError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class BeanDetailInitial implements BeanDetailState {
  const BeanDetailInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BeanDetailInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BeanDetailState.initial()';
}


}




/// @nodoc


class BeanDetailLoading implements BeanDetailState {
  const BeanDetailLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BeanDetailLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BeanDetailState.loading()';
}


}




/// @nodoc


class BeanDetailLoaded implements BeanDetailState {
  const BeanDetailLoaded({required this.bean});
  

 final  CoffeeBean bean;

/// Create a copy of BeanDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BeanDetailLoadedCopyWith<BeanDetailLoaded> get copyWith => _$BeanDetailLoadedCopyWithImpl<BeanDetailLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BeanDetailLoaded&&(identical(other.bean, bean) || other.bean == bean));
}


@override
int get hashCode => Object.hash(runtimeType,bean);

@override
String toString() {
  return 'BeanDetailState.loaded(bean: $bean)';
}


}

/// @nodoc
abstract mixin class $BeanDetailLoadedCopyWith<$Res> implements $BeanDetailStateCopyWith<$Res> {
  factory $BeanDetailLoadedCopyWith(BeanDetailLoaded value, $Res Function(BeanDetailLoaded) _then) = _$BeanDetailLoadedCopyWithImpl;
@useResult
$Res call({
 CoffeeBean bean
});




}
/// @nodoc
class _$BeanDetailLoadedCopyWithImpl<$Res>
    implements $BeanDetailLoadedCopyWith<$Res> {
  _$BeanDetailLoadedCopyWithImpl(this._self, this._then);

  final BeanDetailLoaded _self;
  final $Res Function(BeanDetailLoaded) _then;

/// Create a copy of BeanDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? bean = null,}) {
  return _then(BeanDetailLoaded(
bean: null == bean ? _self.bean : bean // ignore: cast_nullable_to_non_nullable
as CoffeeBean,
  ));
}


}

/// @nodoc


class BeanDetailError implements BeanDetailState {
  const BeanDetailError({required this.message});
  

 final  String message;

/// Create a copy of BeanDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BeanDetailErrorCopyWith<BeanDetailError> get copyWith => _$BeanDetailErrorCopyWithImpl<BeanDetailError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BeanDetailError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'BeanDetailState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $BeanDetailErrorCopyWith<$Res> implements $BeanDetailStateCopyWith<$Res> {
  factory $BeanDetailErrorCopyWith(BeanDetailError value, $Res Function(BeanDetailError) _then) = _$BeanDetailErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$BeanDetailErrorCopyWithImpl<$Res>
    implements $BeanDetailErrorCopyWith<$Res> {
  _$BeanDetailErrorCopyWithImpl(this._self, this._then);

  final BeanDetailError _self;
  final $Res Function(BeanDetailError) _then;

/// Create a copy of BeanDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(BeanDetailError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
