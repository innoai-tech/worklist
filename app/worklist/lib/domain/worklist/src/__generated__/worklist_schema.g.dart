// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../worklist_schema.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorklistSchemaIdentityCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// WorklistSchemaIdentity(...).copyWith(id: 12, name: "My name")
  /// ````
  WorklistSchemaIdentity call({
    String? endpoint,
    String? name,
    String? version,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorklistSchemaIdentity.copyWith(...)`.
class _$WorklistSchemaIdentityCWProxyImpl
    implements _$WorklistSchemaIdentityCWProxy {
  const _$WorklistSchemaIdentityCWProxyImpl(this._value);

  final WorklistSchemaIdentity _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// WorklistSchemaIdentity(...).copyWith(id: 12, name: "My name")
  /// ````
  WorklistSchemaIdentity call({
    Object? endpoint = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
  }) {
    return WorklistSchemaIdentity(
      endpoint: endpoint == const $CopyWithPlaceholder() || endpoint == null
          ? _value.endpoint
          // ignore: cast_nullable_to_non_nullable
          : endpoint as String,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as String?,
    );
  }
}

extension $WorklistSchemaIdentityCopyWith on WorklistSchemaIdentity {
  /// Returns a callable class that can be used as follows: `instanceOfWorklistSchemaIdentity.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$WorklistSchemaIdentityCWProxy get copyWith =>
      _$WorklistSchemaIdentityCWProxyImpl(this);

  /// Copies the object with the specific fields set to `null`. If you pass `false` as a parameter, nothing will be done and it will be ignored. Don't do it. Prefer `copyWith(field: null)`.
  ///
  /// Usage
  /// ```dart
  /// WorklistSchemaIdentity(...).copyWithNull(firstField: true, secondField: true)
  /// ````
  WorklistSchemaIdentity copyWithNull({
    bool version = false,
  }) {
    return WorklistSchemaIdentity(
      endpoint: endpoint,
      name: name,
      version: version == true ? null : this.version,
    );
  }
}

abstract class _$WorklistSchemaCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// WorklistSchema(...).copyWith(id: 12, name: "My name")
  /// ````
  WorklistSchema call({
    String? endpoint,
    String? name,
    String? version,
    String? description,
    Digest? digest,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorklistSchema.copyWith(...)`.
class _$WorklistSchemaCWProxyImpl implements _$WorklistSchemaCWProxy {
  const _$WorklistSchemaCWProxyImpl(this._value);

  final WorklistSchema _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// WorklistSchema(...).copyWith(id: 12, name: "My name")
  /// ````
  WorklistSchema call({
    Object? endpoint = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? digest = const $CopyWithPlaceholder(),
  }) {
    return WorklistSchema(
      endpoint: endpoint == const $CopyWithPlaceholder() || endpoint == null
          ? _value.endpoint
          // ignore: cast_nullable_to_non_nullable
          : endpoint as String,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as String?,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      digest: digest == const $CopyWithPlaceholder()
          ? _value.digest
          // ignore: cast_nullable_to_non_nullable
          : digest as Digest?,
    );
  }
}

extension $WorklistSchemaCopyWith on WorklistSchema {
  /// Returns a callable class that can be used as follows: `instanceOfWorklistSchema.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$WorklistSchemaCWProxy get copyWith => _$WorklistSchemaCWProxyImpl(this);

  /// Copies the object with the specific fields set to `null`. If you pass `false` as a parameter, nothing will be done and it will be ignored. Don't do it. Prefer `copyWith(field: null)`.
  ///
  /// Usage
  /// ```dart
  /// WorklistSchema(...).copyWithNull(firstField: true, secondField: true)
  /// ````
  WorklistSchema copyWithNull({
    bool version = false,
    bool description = false,
    bool digest = false,
  }) {
    return WorklistSchema(
      endpoint: endpoint,
      name: name,
      version: version == true ? null : this.version,
      description: description == true ? null : this.description,
      digest: digest == true ? null : this.digest,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorklistSchemaIdentity _$WorklistSchemaIdentityFromJson(
        Map<String, dynamic> json) =>
    WorklistSchemaIdentity(
      endpoint: json['endpoint'] as String,
      name: json['name'] as String,
      version: json['version'] as String?,
    );

Map<String, dynamic> _$WorklistSchemaIdentityToJson(
    WorklistSchemaIdentity instance) {
  final val = <String, dynamic>{
    'endpoint': instance.endpoint,
    'name': instance.name,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('version', instance.version);
  return val;
}

WorklistSchema _$WorklistSchemaFromJson(Map<String, dynamic> json) =>
    WorklistSchema(
      endpoint: json['endpoint'] as String,
      name: json['name'] as String,
      version: json['version'] as String?,
      description: json['description'] as String?,
      digest: json['digest'] == null
          ? null
          : Digest.fromJson(json['digest'] as String),
    );

Map<String, dynamic> _$WorklistSchemaToJson(WorklistSchema instance) {
  final val = <String, dynamic>{
    'endpoint': instance.endpoint,
    'name': instance.name,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('version', instance.version);
  writeNotNull('description', instance.description);
  writeNotNull('digest', instance.digest);
  return val;
}
