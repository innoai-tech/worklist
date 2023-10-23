// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../worklist_schema.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

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
    );
  }
}

extension $WorklistSchemaCopyWith on WorklistSchema {
  /// Returns a callable class that can be used as follows: `instanceOfWorklistSchema.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$WorklistSchemaCWProxy get copyWith => _$WorklistSchemaCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorklistSchema _$WorklistSchemaFromJson(Map<String, dynamic> json) =>
    WorklistSchema(
      endpoint: json['endpoint'] as String,
      name: json['name'] as String,
      version: json['version'] as String?,
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
  return val;
}
