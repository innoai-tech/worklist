// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../worklist.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorklistCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// Worklist(...).copyWith(id: 12, name: "My name")
  /// ````
  Worklist call({
    String? id,
    WorklistSchemaIdentity? schema,
    Map<String, dynamic>? latestValues,
    Map<String, dynamic>? validValues,
    Digest? digest,
    Digest? latestSynced,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorklist.copyWith(...)`.
class _$WorklistCWProxyImpl implements _$WorklistCWProxy {
  const _$WorklistCWProxyImpl(this._value);

  final Worklist _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// Worklist(...).copyWith(id: 12, name: "My name")
  /// ````
  Worklist call({
    Object? id = const $CopyWithPlaceholder(),
    Object? schema = const $CopyWithPlaceholder(),
    Object? latestValues = const $CopyWithPlaceholder(),
    Object? validValues = const $CopyWithPlaceholder(),
    Object? digest = const $CopyWithPlaceholder(),
    Object? latestSynced = const $CopyWithPlaceholder(),
  }) {
    return Worklist(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      schema: schema == const $CopyWithPlaceholder() || schema == null
          ? _value.schema
          // ignore: cast_nullable_to_non_nullable
          : schema as WorklistSchemaIdentity,
      latestValues: latestValues == const $CopyWithPlaceholder()
          ? _value.latestValues
          // ignore: cast_nullable_to_non_nullable
          : latestValues as Map<String, dynamic>?,
      validValues: validValues == const $CopyWithPlaceholder()
          ? _value.validValues
          // ignore: cast_nullable_to_non_nullable
          : validValues as Map<String, dynamic>?,
      digest: digest == const $CopyWithPlaceholder()
          ? _value.digest
          // ignore: cast_nullable_to_non_nullable
          : digest as Digest?,
      latestSynced: latestSynced == const $CopyWithPlaceholder()
          ? _value.latestSynced
          // ignore: cast_nullable_to_non_nullable
          : latestSynced as Digest?,
    );
  }
}

extension $WorklistCopyWith on Worklist {
  /// Returns a callable class that can be used as follows: `instanceOfWorklist.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$WorklistCWProxy get copyWith => _$WorklistCWProxyImpl(this);

  /// Copies the object with the specific fields set to `null`. If you pass `false` as a parameter, nothing will be done and it will be ignored. Don't do it. Prefer `copyWith(field: null)`.
  ///
  /// Usage
  /// ```dart
  /// Worklist(...).copyWithNull(firstField: true, secondField: true)
  /// ````
  Worklist copyWithNull({
    bool latestValues = false,
    bool validValues = false,
    bool digest = false,
    bool latestSynced = false,
  }) {
    return Worklist(
      id: id,
      schema: schema,
      latestValues: latestValues == true ? null : this.latestValues,
      validValues: validValues == true ? null : this.validValues,
      digest: digest == true ? null : this.digest,
      latestSynced: latestSynced == true ? null : this.latestSynced,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Worklist _$WorklistFromJson(Map<String, dynamic> json) => Worklist(
      id: json['id'] as String,
      schema: WorklistSchemaIdentity.fromJson(
          json['schema'] as Map<String, dynamic>),
      latestValues: json['latestValues'] as Map<String, dynamic>?,
      validValues: json['validValues'] as Map<String, dynamic>?,
      digest: json['digest'] == null
          ? null
          : Digest.fromJson(json['digest'] as String),
      latestSynced: json['latestSynced'] == null
          ? null
          : Digest.fromJson(json['latestSynced'] as String),
    );

Map<String, dynamic> _$WorklistToJson(Worklist instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'schema': instance.schema,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('latestValues', instance.latestValues);
  writeNotNull('validValues', instance.validValues);
  writeNotNull('digest', instance.digest);
  writeNotNull('latestSynced', instance.latestSynced);
  return val;
}
