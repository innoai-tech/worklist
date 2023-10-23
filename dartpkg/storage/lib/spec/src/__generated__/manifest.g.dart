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
    Map<String, String>? annotations,
    String? artifactType,
    Descriptor? config,
    List<Descriptor>? layers,
    String? mediaType,
    int? schemaVersion,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfImageManifest.copyWith(...)`.
class _$ImageManifestCWProxyImpl implements _$ImageManifestCWProxy {
  final ImageManifest _value;

  const _$ImageManifestCWProxyImpl(this._value);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// ImageManifest(...).copyWith(id: 12, name: "My name")
  /// ````
  ImageManifest call({
    Object? annotations = const $CopyWithPlaceholder(),
    Object? artifactType = const $CopyWithPlaceholder(),
    Object? config = const $CopyWithPlaceholder(),
    Object? layers = const $CopyWithPlaceholder(),
    Object? mediaType = const $CopyWithPlaceholder(),
    Object? schemaVersion = const $CopyWithPlaceholder(),
  }) {
    return ImageManifest(
      annotations: annotations == const $CopyWithPlaceholder()
          ? _value.annotations
          // ignore: cast_nullable_to_non_nullable
          : annotations as Map<String, String>?,
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
      mediaType: mediaType == const $CopyWithPlaceholder() || mediaType == null
          ? _value.mediaType
          // ignore: cast_nullable_to_non_nullable
          : mediaType as String,
      schemaVersion:
          schemaVersion == const $CopyWithPlaceholder() || schemaVersion == null
              ? _value.schemaVersion
              // ignore: cast_nullable_to_non_nullable
              : schemaVersion as int,
    );
  }
}

extension $ImageManifestCopyWith on ImageManifest {
  /// Returns a callable class that can be used as follows: `instanceOfImageManifest.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$ImageManifestCWProxy get copyWith => _$ImageManifestCWProxyImpl(this);
}

abstract class _$ImageIndexCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// ImageIndex(...).copyWith(id: 12, name: "My name")
  /// ````
  ImageIndex call({
    Map<String, String>? annotations,
    String? artifactType,
    List<Descriptor>? manifests,
    String? mediaType,
    int? schemaVersion,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfImageIndex.copyWith(...)`.
class _$ImageIndexCWProxyImpl implements _$ImageIndexCWProxy {
  final ImageIndex _value;

  const _$ImageIndexCWProxyImpl(this._value);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// ImageIndex(...).copyWith(id: 12, name: "My name")
  /// ````
  ImageIndex call({
    Object? annotations = const $CopyWithPlaceholder(),
    Object? artifactType = const $CopyWithPlaceholder(),
    Object? manifests = const $CopyWithPlaceholder(),
    Object? mediaType = const $CopyWithPlaceholder(),
    Object? schemaVersion = const $CopyWithPlaceholder(),
  }) {
    return ImageIndex(
      annotations: annotations == const $CopyWithPlaceholder()
          ? _value.annotations
          // ignore: cast_nullable_to_non_nullable
          : annotations as Map<String, String>?,
      artifactType: artifactType == const $CopyWithPlaceholder()
          ? _value.artifactType
          // ignore: cast_nullable_to_non_nullable
          : artifactType as String?,
      manifests: manifests == const $CopyWithPlaceholder()
          ? _value.manifests
          // ignore: cast_nullable_to_non_nullable
          : manifests as List<Descriptor>?,
      mediaType: mediaType == const $CopyWithPlaceholder() || mediaType == null
          ? _value.mediaType
          // ignore: cast_nullable_to_non_nullable
          : mediaType as String,
      schemaVersion:
          schemaVersion == const $CopyWithPlaceholder() || schemaVersion == null
              ? _value.schemaVersion
              // ignore: cast_nullable_to_non_nullable
              : schemaVersion as int,
    );
  }
}

extension $ImageIndexCopyWith on ImageIndex {
  /// Returns a callable class that can be used as follows: `instanceOfImageIndex.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$ImageIndexCWProxy get copyWith => _$ImageIndexCWProxyImpl(this);
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
