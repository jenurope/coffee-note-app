// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'log_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LogListState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogListState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LogListState()';
}


}

/// @nodoc
class $LogListStateCopyWith<$Res>  {
$LogListStateCopyWith(LogListState _, $Res Function(LogListState) __);
}


/// Adds pattern-matching-related methods to [LogListState].
extension LogListStatePatterns on LogListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LogListInitial value)?  initial,TResult Function( LogListLoading value)?  loading,TResult Function( LogListLoaded value)?  loaded,TResult Function( LogListError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LogListInitial() when initial != null:
return initial(_that);case LogListLoading() when loading != null:
return loading(_that);case LogListLoaded() when loaded != null:
return loaded(_that);case LogListError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LogListInitial value)  initial,required TResult Function( LogListLoading value)  loading,required TResult Function( LogListLoaded value)  loaded,required TResult Function( LogListError value)  error,}){
final _that = this;
switch (_that) {
case LogListInitial():
return initial(_that);case LogListLoading():
return loading(_that);case LogListLoaded():
return loaded(_that);case LogListError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LogListInitial value)?  initial,TResult? Function( LogListLoading value)?  loading,TResult? Function( LogListLoaded value)?  loaded,TResult? Function( LogListError value)?  error,}){
final _that = this;
switch (_that) {
case LogListInitial() when initial != null:
return initial(_that);case LogListLoading() when loading != null:
return loading(_that);case LogListLoaded() when loaded != null:
return loaded(_that);case LogListError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function( LogFilters filters)?  loading,TResult Function( List<CoffeeLog> logs,  LogFilters filters)?  loaded,TResult Function( String message,  LogFilters filters)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LogListInitial() when initial != null:
return initial();case LogListLoading() when loading != null:
return loading(_that.filters);case LogListLoaded() when loaded != null:
return loaded(_that.logs,_that.filters);case LogListError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function( LogFilters filters)  loading,required TResult Function( List<CoffeeLog> logs,  LogFilters filters)  loaded,required TResult Function( String message,  LogFilters filters)  error,}) {final _that = this;
switch (_that) {
case LogListInitial():
return initial();case LogListLoading():
return loading(_that.filters);case LogListLoaded():
return loaded(_that.logs,_that.filters);case LogListError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function( LogFilters filters)?  loading,TResult? Function( List<CoffeeLog> logs,  LogFilters filters)?  loaded,TResult? Function( String message,  LogFilters filters)?  error,}) {final _that = this;
switch (_that) {
case LogListInitial() when initial != null:
return initial();case LogListLoading() when loading != null:
return loading(_that.filters);case LogListLoaded() when loaded != null:
return loaded(_that.logs,_that.filters);case LogListError() when error != null:
return error(_that.message,_that.filters);case _:
  return null;

}
}

}

/// @nodoc


class LogListInitial implements LogListState {
  const LogListInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogListInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LogListState.initial()';
}


}




/// @nodoc


class LogListLoading implements LogListState {
  const LogListLoading({required this.filters});
  

 final  LogFilters filters;

/// Create a copy of LogListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LogListLoadingCopyWith<LogListLoading> get copyWith => _$LogListLoadingCopyWithImpl<LogListLoading>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogListLoading&&(identical(other.filters, filters) || other.filters == filters));
}


@override
int get hashCode => Object.hash(runtimeType,filters);

@override
String toString() {
  return 'LogListState.loading(filters: $filters)';
}


}

/// @nodoc
abstract mixin class $LogListLoadingCopyWith<$Res> implements $LogListStateCopyWith<$Res> {
  factory $LogListLoadingCopyWith(LogListLoading value, $Res Function(LogListLoading) _then) = _$LogListLoadingCopyWithImpl;
@useResult
$Res call({
 LogFilters filters
});


$LogFiltersCopyWith<$Res> get filters;

}
/// @nodoc
class _$LogListLoadingCopyWithImpl<$Res>
    implements $LogListLoadingCopyWith<$Res> {
  _$LogListLoadingCopyWithImpl(this._self, this._then);

  final LogListLoading _self;
  final $Res Function(LogListLoading) _then;

/// Create a copy of LogListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? filters = null,}) {
  return _then(LogListLoading(
filters: null == filters ? _self.filters : filters // ignore: cast_nullable_to_non_nullable
as LogFilters,
  ));
}

/// Create a copy of LogListState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LogFiltersCopyWith<$Res> get filters {
  
  return $LogFiltersCopyWith<$Res>(_self.filters, (value) {
    return _then(_self.copyWith(filters: value));
  });
}
}

/// @nodoc


class LogListLoaded implements LogListState {
  const LogListLoaded({required final  List<CoffeeLog> logs, required this.filters}): _logs = logs;
  

 final  List<CoffeeLog> _logs;
 List<CoffeeLog> get logs {
  if (_logs is EqualUnmodifiableListView) return _logs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_logs);
}

 final  LogFilters filters;

/// Create a copy of LogListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LogListLoadedCopyWith<LogListLoaded> get copyWith => _$LogListLoadedCopyWithImpl<LogListLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogListLoaded&&const DeepCollectionEquality().equals(other._logs, _logs)&&(identical(other.filters, filters) || other.filters == filters));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_logs),filters);

@override
String toString() {
  return 'LogListState.loaded(logs: $logs, filters: $filters)';
}


}

/// @nodoc
abstract mixin class $LogListLoadedCopyWith<$Res> implements $LogListStateCopyWith<$Res> {
  factory $LogListLoadedCopyWith(LogListLoaded value, $Res Function(LogListLoaded) _then) = _$LogListLoadedCopyWithImpl;
@useResult
$Res call({
 List<CoffeeLog> logs, LogFilters filters
});


$LogFiltersCopyWith<$Res> get filters;

}
/// @nodoc
class _$LogListLoadedCopyWithImpl<$Res>
    implements $LogListLoadedCopyWith<$Res> {
  _$LogListLoadedCopyWithImpl(this._self, this._then);

  final LogListLoaded _self;
  final $Res Function(LogListLoaded) _then;

/// Create a copy of LogListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? logs = null,Object? filters = null,}) {
  return _then(LogListLoaded(
logs: null == logs ? _self._logs : logs // ignore: cast_nullable_to_non_nullable
as List<CoffeeLog>,filters: null == filters ? _self.filters : filters // ignore: cast_nullable_to_non_nullable
as LogFilters,
  ));
}

/// Create a copy of LogListState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LogFiltersCopyWith<$Res> get filters {
  
  return $LogFiltersCopyWith<$Res>(_self.filters, (value) {
    return _then(_self.copyWith(filters: value));
  });
}
}

/// @nodoc


class LogListError implements LogListState {
  const LogListError({required this.message, required this.filters});
  

 final  String message;
 final  LogFilters filters;

/// Create a copy of LogListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LogListErrorCopyWith<LogListError> get copyWith => _$LogListErrorCopyWithImpl<LogListError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogListError&&(identical(other.message, message) || other.message == message)&&(identical(other.filters, filters) || other.filters == filters));
}


@override
int get hashCode => Object.hash(runtimeType,message,filters);

@override
String toString() {
  return 'LogListState.error(message: $message, filters: $filters)';
}


}

/// @nodoc
abstract mixin class $LogListErrorCopyWith<$Res> implements $LogListStateCopyWith<$Res> {
  factory $LogListErrorCopyWith(LogListError value, $Res Function(LogListError) _then) = _$LogListErrorCopyWithImpl;
@useResult
$Res call({
 String message, LogFilters filters
});


$LogFiltersCopyWith<$Res> get filters;

}
/// @nodoc
class _$LogListErrorCopyWithImpl<$Res>
    implements $LogListErrorCopyWith<$Res> {
  _$LogListErrorCopyWithImpl(this._self, this._then);

  final LogListError _self;
  final $Res Function(LogListError) _then;

/// Create a copy of LogListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? filters = null,}) {
  return _then(LogListError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,filters: null == filters ? _self.filters : filters // ignore: cast_nullable_to_non_nullable
as LogFilters,
  ));
}

/// Create a copy of LogListState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LogFiltersCopyWith<$Res> get filters {
  
  return $LogFiltersCopyWith<$Res>(_self.filters, (value) {
    return _then(_self.copyWith(filters: value));
  });
}
}

// dart format on
