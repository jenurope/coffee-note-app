// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DashboardState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DashboardState()';
}


}

/// @nodoc
class $DashboardStateCopyWith<$Res>  {
$DashboardStateCopyWith(DashboardState _, $Res Function(DashboardState) __);
}


/// Adds pattern-matching-related methods to [DashboardState].
extension DashboardStatePatterns on DashboardState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DashboardInitial value)?  initial,TResult Function( DashboardLoading value)?  loading,TResult Function( DashboardLoaded value)?  loaded,TResult Function( DashboardError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DashboardInitial() when initial != null:
return initial(_that);case DashboardLoading() when loading != null:
return loading(_that);case DashboardLoaded() when loaded != null:
return loaded(_that);case DashboardError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DashboardInitial value)  initial,required TResult Function( DashboardLoading value)  loading,required TResult Function( DashboardLoaded value)  loaded,required TResult Function( DashboardError value)  error,}){
final _that = this;
switch (_that) {
case DashboardInitial():
return initial(_that);case DashboardLoading():
return loading(_that);case DashboardLoaded():
return loaded(_that);case DashboardError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DashboardInitial value)?  initial,TResult? Function( DashboardLoading value)?  loading,TResult? Function( DashboardLoaded value)?  loaded,TResult? Function( DashboardError value)?  error,}){
final _that = this;
switch (_that) {
case DashboardInitial() when initial != null:
return initial(_that);case DashboardLoading() when loading != null:
return loading(_that);case DashboardLoaded() when loaded != null:
return loaded(_that);case DashboardError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( int totalBeans,  double averageBeanRating,  int totalLogs,  double averageLogRating,  Map<String, int> coffeeTypeCount,  List<CoffeeBean> recentBeans,  List<CoffeeLog> recentLogs,  UserProfile? userProfile)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DashboardInitial() when initial != null:
return initial();case DashboardLoading() when loading != null:
return loading();case DashboardLoaded() when loaded != null:
return loaded(_that.totalBeans,_that.averageBeanRating,_that.totalLogs,_that.averageLogRating,_that.coffeeTypeCount,_that.recentBeans,_that.recentLogs,_that.userProfile);case DashboardError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( int totalBeans,  double averageBeanRating,  int totalLogs,  double averageLogRating,  Map<String, int> coffeeTypeCount,  List<CoffeeBean> recentBeans,  List<CoffeeLog> recentLogs,  UserProfile? userProfile)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case DashboardInitial():
return initial();case DashboardLoading():
return loading();case DashboardLoaded():
return loaded(_that.totalBeans,_that.averageBeanRating,_that.totalLogs,_that.averageLogRating,_that.coffeeTypeCount,_that.recentBeans,_that.recentLogs,_that.userProfile);case DashboardError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( int totalBeans,  double averageBeanRating,  int totalLogs,  double averageLogRating,  Map<String, int> coffeeTypeCount,  List<CoffeeBean> recentBeans,  List<CoffeeLog> recentLogs,  UserProfile? userProfile)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case DashboardInitial() when initial != null:
return initial();case DashboardLoading() when loading != null:
return loading();case DashboardLoaded() when loaded != null:
return loaded(_that.totalBeans,_that.averageBeanRating,_that.totalLogs,_that.averageLogRating,_that.coffeeTypeCount,_that.recentBeans,_that.recentLogs,_that.userProfile);case DashboardError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class DashboardInitial implements DashboardState {
  const DashboardInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DashboardState.initial()';
}


}




/// @nodoc


class DashboardLoading implements DashboardState {
  const DashboardLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DashboardState.loading()';
}


}




/// @nodoc


class DashboardLoaded implements DashboardState {
  const DashboardLoaded({required this.totalBeans, required this.averageBeanRating, required this.totalLogs, required this.averageLogRating, required final  Map<String, int> coffeeTypeCount, required final  List<CoffeeBean> recentBeans, required final  List<CoffeeLog> recentLogs, this.userProfile}): _coffeeTypeCount = coffeeTypeCount,_recentBeans = recentBeans,_recentLogs = recentLogs;
  

 final  int totalBeans;
 final  double averageBeanRating;
 final  int totalLogs;
 final  double averageLogRating;
 final  Map<String, int> _coffeeTypeCount;
 Map<String, int> get coffeeTypeCount {
  if (_coffeeTypeCount is EqualUnmodifiableMapView) return _coffeeTypeCount;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_coffeeTypeCount);
}

 final  List<CoffeeBean> _recentBeans;
 List<CoffeeBean> get recentBeans {
  if (_recentBeans is EqualUnmodifiableListView) return _recentBeans;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentBeans);
}

 final  List<CoffeeLog> _recentLogs;
 List<CoffeeLog> get recentLogs {
  if (_recentLogs is EqualUnmodifiableListView) return _recentLogs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentLogs);
}

 final  UserProfile? userProfile;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardLoadedCopyWith<DashboardLoaded> get copyWith => _$DashboardLoadedCopyWithImpl<DashboardLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardLoaded&&(identical(other.totalBeans, totalBeans) || other.totalBeans == totalBeans)&&(identical(other.averageBeanRating, averageBeanRating) || other.averageBeanRating == averageBeanRating)&&(identical(other.totalLogs, totalLogs) || other.totalLogs == totalLogs)&&(identical(other.averageLogRating, averageLogRating) || other.averageLogRating == averageLogRating)&&const DeepCollectionEquality().equals(other._coffeeTypeCount, _coffeeTypeCount)&&const DeepCollectionEquality().equals(other._recentBeans, _recentBeans)&&const DeepCollectionEquality().equals(other._recentLogs, _recentLogs)&&(identical(other.userProfile, userProfile) || other.userProfile == userProfile));
}


@override
int get hashCode => Object.hash(runtimeType,totalBeans,averageBeanRating,totalLogs,averageLogRating,const DeepCollectionEquality().hash(_coffeeTypeCount),const DeepCollectionEquality().hash(_recentBeans),const DeepCollectionEquality().hash(_recentLogs),userProfile);

@override
String toString() {
  return 'DashboardState.loaded(totalBeans: $totalBeans, averageBeanRating: $averageBeanRating, totalLogs: $totalLogs, averageLogRating: $averageLogRating, coffeeTypeCount: $coffeeTypeCount, recentBeans: $recentBeans, recentLogs: $recentLogs, userProfile: $userProfile)';
}


}

/// @nodoc
abstract mixin class $DashboardLoadedCopyWith<$Res> implements $DashboardStateCopyWith<$Res> {
  factory $DashboardLoadedCopyWith(DashboardLoaded value, $Res Function(DashboardLoaded) _then) = _$DashboardLoadedCopyWithImpl;
@useResult
$Res call({
 int totalBeans, double averageBeanRating, int totalLogs, double averageLogRating, Map<String, int> coffeeTypeCount, List<CoffeeBean> recentBeans, List<CoffeeLog> recentLogs, UserProfile? userProfile
});




}
/// @nodoc
class _$DashboardLoadedCopyWithImpl<$Res>
    implements $DashboardLoadedCopyWith<$Res> {
  _$DashboardLoadedCopyWithImpl(this._self, this._then);

  final DashboardLoaded _self;
  final $Res Function(DashboardLoaded) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? totalBeans = null,Object? averageBeanRating = null,Object? totalLogs = null,Object? averageLogRating = null,Object? coffeeTypeCount = null,Object? recentBeans = null,Object? recentLogs = null,Object? userProfile = freezed,}) {
  return _then(DashboardLoaded(
totalBeans: null == totalBeans ? _self.totalBeans : totalBeans // ignore: cast_nullable_to_non_nullable
as int,averageBeanRating: null == averageBeanRating ? _self.averageBeanRating : averageBeanRating // ignore: cast_nullable_to_non_nullable
as double,totalLogs: null == totalLogs ? _self.totalLogs : totalLogs // ignore: cast_nullable_to_non_nullable
as int,averageLogRating: null == averageLogRating ? _self.averageLogRating : averageLogRating // ignore: cast_nullable_to_non_nullable
as double,coffeeTypeCount: null == coffeeTypeCount ? _self._coffeeTypeCount : coffeeTypeCount // ignore: cast_nullable_to_non_nullable
as Map<String, int>,recentBeans: null == recentBeans ? _self._recentBeans : recentBeans // ignore: cast_nullable_to_non_nullable
as List<CoffeeBean>,recentLogs: null == recentLogs ? _self._recentLogs : recentLogs // ignore: cast_nullable_to_non_nullable
as List<CoffeeLog>,userProfile: freezed == userProfile ? _self.userProfile : userProfile // ignore: cast_nullable_to_non_nullable
as UserProfile?,
  ));
}


}

/// @nodoc


class DashboardError implements DashboardState {
  const DashboardError({required this.message});
  

 final  String message;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardErrorCopyWith<DashboardError> get copyWith => _$DashboardErrorCopyWithImpl<DashboardError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'DashboardState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $DashboardErrorCopyWith<$Res> implements $DashboardStateCopyWith<$Res> {
  factory $DashboardErrorCopyWith(DashboardError value, $Res Function(DashboardError) _then) = _$DashboardErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$DashboardErrorCopyWithImpl<$Res>
    implements $DashboardErrorCopyWith<$Res> {
  _$DashboardErrorCopyWithImpl(this._self, this._then);

  final DashboardError _self;
  final $Res Function(DashboardError) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(DashboardError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
