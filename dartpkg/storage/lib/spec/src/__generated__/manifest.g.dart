// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../manifest.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ImageManifestCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// ImageManifest(...).copyWith(id: 12, name: "My name")
  /// ````
  ImageManifest call({
    int? schemaVersion,
    String? mediaType,
    String? artifactType,
    Descriptor? config,
    List<Descriptor>? layers,
    Map<String, String>? annotations,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfImageManifest.copyWith(...)`.
class _$ImageManifestCWProxyImpl implements _$ImageManifestCWProxy {
  const _$ImageManifestCWProxyImpl(this._value);

  final ImageManifest _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// ImageManifest(...).copyWith(id: 12, name: "My name")
  /// ````
  ImageManifest call({
    Object? schemaVersion = const $CopyWithPlaceholder(),
    Object? mediaType = const $CopyWithPlaceholder(),
    Object? artifactType = const $CopyWithPlaceholder(),
    Object? config = const $CopyWithPlaceholder(),
    Object? layers = const $CopyWithPlaceholder(),
    Object? annotations = const $CopyWithPlaceholder(),
  }) {
    return ImageManifest(
      schemaVersion:
          schemaVersion == const $CopyWithPlaceholder() || schemaVersion == null
              ? _value.schemaVersion
              // ignore: cast_nullable_to_non_nullable
              : schemaVersion as int,
      mediaType: mediaType == const $CopyWithPlaceholder() || mediaType == null
          ? _value.mediaType
          // ignore: cast_nullable_to_non_nullable
          : mediaType as String,
      artifactType: artifactType == const $CopyWithPlaceholder()
          ? _value.artifactType
          // ignore: cast_nullable_to_non_nullable
          : artifactType as String?,
      config: config == const $CopyWithPlaceholder()
          ? _value.config
          // ignore: cast_nullable_to_non_nullable
          : config as Descriptor?,
      layers: layers == const $CopyWithPlaceholder()
          ? _value.layers
          // ignore: cast_nullable_to_non_nullable
          : layers as List<Descriptor>?,
      annotations: annotations == const $CopyWithPlaceholder()
          ? _value.annotations
          // ignore: cast_nullable_to_non_nullable
          : annotations as Map<String, String>?,
    );
  }
}

extension $ImageManifestCopyWith on ImageManifest {
  /// Returns a callable class that can be used as follows: `instanceOfImageManifest.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$ImageManifestCWProxy get copyWith => _$ImageManifestCWProxyImpl(this);

  /// Copies the object with the specific fields set to `null`. If you pass `false` as a parameter, nothing will be done and it will be ignored. Don't do it. Prefer `copyWith(field: null)`.
  ///
  /// Usage
  /// ```dart
  /// ImageManifest(...).copyWithNull(firstField: true, secondField: true)
  /// ````
  ImageManifest copyWithNull({
    bool artifactType = false,
    bool config = false,
    bool layers = false,
    bool annotations = false,
  }) {
    return ImageManifest(
      schemaVersion: schemaVersion,
      mediaType: mediaType,
      artifactType: artifactType == true ? null : this.artifactType,
      config: config == true ? null : this.config,
      layers: layers == true ? null : this.layers,
      annotations: annotations == true ? null : this.annotations,
    );
  }
}

abstract class _$ImageIndexCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// ImageIndex(...).copyWith(id: 12, name: "My name")
  /// ````
  ImageIndex call({
    int? schemaVersion,
    String? mediaType,
    String? artifactType,
    List<Descriptor>? manifests,
    Map<String, String>? annotations,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfImageIndex.copyWith(...)`.
class _$ImageIndexCWProxyImpl implements _$ImageIndexCWProxy {
  const _$ImageIndexCWProxyImpl(this._value);

  final ImageIndex _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// ImageIndex(...).copyWith(id: 12, name: "My name")
  /// ````
  ImageIndex call({
    Object? schemaVersion = const $CopyWithPlaceholder(),
    Object? mediaType = const $CopyWithPlaceholder(),
    Object? artifactType = const $CopyWithPlaceholder(),
    Object? manifests = const $CopyWithPlaceholder(),
    Object? annotations = const $CopyWithPlaceholder(),
  }) {
    return ImageIndex(
      schemaVersion:
          schemaVersion == const $CopyWithPlaceholder() || schemaVersion == null
              ? _value.schemaVersion
              // ignore: cast_nullable_to_non_nullable
              : schemaVersion as int,
      mediaType: mediaType == const $CopyWithPlaceholder() || mediaType == null
          ? _value.mediaType
          // ignore: cast_nullable_to_non_nullable
          : mediaType as String,
      artifactType: artifactType == const $CopyWithPlaceholder()
          ? _value.artifactType
          // ignore: cast_nullable_to_non_nullable
          : artifactType as String?,
      manifests: manifests == const $CopyWithPlaceholder()
          ? _value.manifests
          // ignore: cast_nullable_to_non_nullable
          : manifests as List<Descriptor>?,
      annotations: annotations == const $CopyWithPlaceholder()
          ? _value.annotations
          // ignore: cast_nullable_to_non_nullable
          : annotations as Map<String, String>?,
    );
  }
}

extension $ImageIndexCopyWith on ImageIndex {
  /// Returns a callable class that can be used as follows: `instanceOfImageIndex.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$ImageIndexCWProxy get copyWith => _$ImageIndexCWProxyImpl(this);

  /// Copies the object with the specific fields set to `null`. If you pass `false` as a parameter, nothing will be done and it will be ignored. Don't do it. Prefer `copyWith(field: null)`.
  ///
  /// Usage
  /// ```dart
  /// ImageIndex(...).copyWithNull(firstField: true, secondField: true)
  /// ````
  ImageIndex copyWithNull({
    bool artifactType = false,
    bool manifests = false,
    bool annotations = false,
  }) {
    return ImageIndex(
      schemaVersion: schemaVersion,
      mediaType: mediaType,
      artifactType: artifactType == true ? null : this.artifactType,
      manifests: manifests == true ? null : this.manifests,
      annotations: annotations == true ? null : this.annotations,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageManifest _$ImageManifestFromJson(Map<String, dynamic> json) =>
    ImageManifest(
      schemaVersion: json['schemaVersion'] as int? ?? 2,
      mediaType: json['mediaType'] as String? ?? ImageManifest.type,
      artifactType: json['artifactType'] as String?,
      config: json['config'] == null
          ? null
          : Descriptor.fromJson(json['config'] as Map<String, dynamic>),
      layers: (json['layers'] as List<dynamic>?)
          ?.map((e) => Descriptor.fromJson(e as Map<String, dynamic>))
          .toList(),
      annotations: (json['annotations'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$ImageManifestToJson(ImageManifest instance) {
  final val = <String, dynamic>{
    'mediaType': instance.mediaType,
    'schemaVersion': instance.schemaVersion,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('config', instance.config);
  writeNotNull('layers', instance.layers);
  writeNotNull('annotations', instance.annotations);
  writeNotNull('artifactType', instance.artifactType);
  return val;
}

ImageIndex _$ImageIndexFromJson(Map<String, dynamic> json) => ImageIndex(
      schemaVersion: json['schemaVersion'] as int? ?? 2,
      mediaType: json['mediaType'] as String? ?? ImageIndex.type,
      artifactType: json['artifactType'] as String?,
      manifests: (json['manifests'] as List<dynamic>?)
          ?.map((e) => Descriptor.fromJson(e as Map<String, dynamic>))
          .toList(),
      annotations: (json['annotations'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$ImageIndexToJson(ImageIndex instance) {
  final val = <String, dynamic>{
    'mediaType': instance.mediaType,
    'schemaVersion': instance.schemaVersion,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('artifactType', instance.artifactType);
  writeNotNull('manifests', instance.manifests);
  writeNotNull('annotations', instance.annotations);
  return val;
}
