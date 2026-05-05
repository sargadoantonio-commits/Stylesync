// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ar_usage_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ArUsageDoc {
  String get userId => throw _privateConstructorUsedError;
  int get usageCount => throw _privateConstructorUsedError;
  DateTime get lastResetDate => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Create a copy of ArUsageDoc
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ArUsageDocCopyWith<ArUsageDoc> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ArUsageDocCopyWith<$Res> {
  factory $ArUsageDocCopyWith(
          ArUsageDoc value, $Res Function(ArUsageDoc) then) =
      _$ArUsageDocCopyWithImpl<$Res, ArUsageDoc>;
  @useResult
  $Res call(
      {String userId,
      int usageCount,
      DateTime lastResetDate,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$ArUsageDocCopyWithImpl<$Res, $Val extends ArUsageDoc>
    implements $ArUsageDocCopyWith<$Res> {
  _$ArUsageDocCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ArUsageDoc
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? usageCount = null,
    Object? lastResetDate = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      usageCount: null == usageCount
          ? _value.usageCount
          : usageCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastResetDate: null == lastResetDate
          ? _value.lastResetDate
          : lastResetDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ArUsageDocImplCopyWith<$Res>
    implements $ArUsageDocCopyWith<$Res> {
  factory _$$ArUsageDocImplCopyWith(
          _$ArUsageDocImpl value, $Res Function(_$ArUsageDocImpl) then) =
      __$$ArUsageDocImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      int usageCount,
      DateTime lastResetDate,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$ArUsageDocImplCopyWithImpl<$Res>
    extends _$ArUsageDocCopyWithImpl<$Res, _$ArUsageDocImpl>
    implements _$$ArUsageDocImplCopyWith<$Res> {
  __$$ArUsageDocImplCopyWithImpl(
      _$ArUsageDocImpl _value, $Res Function(_$ArUsageDocImpl) _then)
      : super(_value, _then);

  /// Create a copy of ArUsageDoc
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? usageCount = null,
    Object? lastResetDate = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$ArUsageDocImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      usageCount: null == usageCount
          ? _value.usageCount
          : usageCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastResetDate: null == lastResetDate
          ? _value.lastResetDate
          : lastResetDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$ArUsageDocImpl extends _ArUsageDoc {
  const _$ArUsageDocImpl(
      {required this.userId,
      required this.usageCount,
      required this.lastResetDate,
      required this.createdAt,
      required this.updatedAt})
      : super._();

  @override
  final String userId;
  @override
  final int usageCount;
  @override
  final DateTime lastResetDate;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'ArUsageDoc(userId: $userId, usageCount: $usageCount, lastResetDate: $lastResetDate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ArUsageDocImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.usageCount, usageCount) ||
                other.usageCount == usageCount) &&
            (identical(other.lastResetDate, lastResetDate) ||
                other.lastResetDate == lastResetDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, userId, usageCount, lastResetDate, createdAt, updatedAt);

  /// Create a copy of ArUsageDoc
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ArUsageDocImplCopyWith<_$ArUsageDocImpl> get copyWith =>
      __$$ArUsageDocImplCopyWithImpl<_$ArUsageDocImpl>(this, _$identity);
}

abstract class _ArUsageDoc extends ArUsageDoc {
  const factory _ArUsageDoc(
      {required final String userId,
      required final int usageCount,
      required final DateTime lastResetDate,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$ArUsageDocImpl;
  const _ArUsageDoc._() : super._();

  @override
  String get userId;
  @override
  int get usageCount;
  @override
  DateTime get lastResetDate;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of ArUsageDoc
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ArUsageDocImplCopyWith<_$ArUsageDocImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
