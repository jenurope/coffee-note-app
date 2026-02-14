// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'log_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LogDetailState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogDetailState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LogDetailState()';
}


}

/// @nodoc
class $LogDetailStateCopyWith<$Res>  {
$LogDetailStateCopyWith(LogDetailState _, $Res Function(LogDetailState) __);
}


/// Adds pattern-matching-related methods to [LogDetailState].
extension LogDetailStatePatterns on LogDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LogDetailInitial value)?  initial,TResult Function( LogDetailLoading value)?  loading,TResult Function( LogDetailLoaded value)?  loaded,TResult Function( LogDetailError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LogDetailInitial() when initial != null:
return initial(_that);case LogDetailLoading() when loading != null:
return loading(_that);case LogDetailLoaded() when loaded != null:
return loaded(_that);case LogDetailError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LogDetailInitial value)  initial,required TResult Function( LogDetailLoading value)  loading,required TResult Function( LogDetailLoaded value)  loaded,required TResult Function( LogDetailError value)  error,}){
final _that = this;
switch (_that) {
case LogDetailInitial():
return initial(_that);case LogDetailLoading():
return loading(_that);case LogDetailLoaded():
return loaded(_that);case LogDetailError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LogDetailInitial value)?  initial,TResult? Function( LogDetailLoading value)?  loading,TResult? Function( LogDetailLoaded value)?  loaded,TResult? Function( LogDetailError value)?  error,}){
final _that = this;
switch (_that) {
case LogDetailInitial() when initial != null:
return initial(_that);case LogDetailLoading() when loading != null:
return loading(_that);case LogDetailLoaded() when loaded != null:
return loaded(_that);case LogDetailError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( CoffeeLog log)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LogDetailInitial() when initial != null:
return initial();case LogDetailLoading() when loading != null:
return loading();case LogDetailLoaded() when loaded != null:
return loaded(_that.log);case LogDetailError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( CoffeeLog log)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case LogDetailInitial():
return initial();case LogDetailLoading():
return loading();case LogDetailLoaded():
return loaded(_that.log);case LogDetailError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( CoffeeLog log)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case LogDetailInitial() when initial != null:
return initial();case LogDetailLoading() when loading != null:
return loading();case LogDetailLoaded() when loaded != null:
return loaded(_that.log);case LogDetailError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class LogDetailInitial implements LogDetailState {
  const LogDetailInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogDetailInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LogDetailState.initial()';
}


}




/// @nodoc


class LogDetailLoading implements LogDetailState {
  const LogDetailLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogDetailLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LogDetailState.loading()';
}


}




/// @nodoc


class LogDetailLoaded implements LogDetailState {
  const LogDetailLoaded({required this.log});
  

 final  CoffeeLog log;

/// Create a copy of LogDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LogDetailLoadedCopyWith<LogDetailLoaded> get copyWith => _$LogDetailLoadedCopyWithImpl<LogDetailLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogDetailLoaded&&(identical(other.log, log) || other.log == log));
}


@override
int get hashCode => Object.hash(runtimeType,log);

@override
String toString() {
  return 'LogDetailState.loaded(log: $log)';
}


}

/// @nodoc
abstract mixin class $LogDetailLoadedCopyWith<$Res> implements $LogDetailStateCopyWith<$Res> {
  factory $LogDetailLoadedCopyWith(LogDetailLoaded value, $Res Function(LogDetailLoaded) _then) = _$LogDetailLoadedCopyWithImpl;
@useResult
$Res call({
 CoffeeLog log
});




}
/// @nodoc
class _$LogDetailLoadedCopyWithImpl<$Res>
    implements $LogDetailLoadedCopyWith<$Res> {
  _$LogDetailLoadedCopyWithImpl(this._self, this._then);

  final LogDetailLoaded _self;
  final $Res Function(LogDetailLoaded) _then;

/// Create a copy of LogDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? log = null,}) {
  return _then(LogDetailLoaded(
log: null == log ? _self.log : log // ignore: cast_nullable_to_non_nullable
as CoffeeLog,
  ));
}


}

/// @nodoc


class LogDetailError implements LogDetailState {
  const LogDetailError({required this.message});
  

 final  String message;

/// Create a copy of LogDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LogDetailErrorCopyWith<LogDetailError> get copyWith => _$LogDetailErrorCopyWithImpl<LogDetailError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogDetailError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'LogDetailState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $LogDetailErrorCopyWith<$Res> implements $LogDetailStateCopyWith<$Res> {
  factory $LogDetailErrorCopyWith(LogDetailError value, $Res Function(LogDetailError) _then) = _$LogDetailErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$LogDetailErrorCopyWithImpl<$Res>
    implements $LogDetailErrorCopyWith<$Res> {
  _$LogDetailErrorCopyWithImpl(this._self, this._then);

  final LogDetailError _self;
  final $Res Function(LogDetailError) _then;

/// Create a copy of LogDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(LogDetailError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
